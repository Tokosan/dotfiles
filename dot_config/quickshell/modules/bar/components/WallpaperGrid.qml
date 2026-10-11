pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../config"
import "../../common"
import "../../services"

// Vista de wallpapers del menú global. Se crea al abrir la vista y se
// destruye al cerrarla: lista los directorios al nacer y no guarda nada que
// tenga que sobrevivir.
Item {
    id: grid

    signal back

    // La pantalla donde vive esta barra: el fondo se aplica donde se hizo
    // click, sin tener que elegir el monitor a mano.
    required property string monitor

    // Cada entrada es { path, thumb, kind }: `path` es lo que se le pasa al
    // script (ruta o id de scene) y `thumb` lo que se pinta en la grilla.
    property var statics: []
    property var videos: []
    property var scenes: []

    property string kind: "image"
    property string current: ""

    readonly property var entries: grid.kind === "video" ? grid.videos : grid.kind === "scene" ? grid.scenes : grid.statics

    implicitHeight: header.implicitHeight + 6 + tabs.implicitHeight + 6 + view.height

    function apply(entry) {
        // El script ya hace symlink, awww, pywal y la imagen de lockscreen.
        applyProcess.command = [Settings.wallpaperScript, entry.path, "--monitor", grid.monitor, "--wal", "--lock-file"];
        applyProcess.running = true;
        grid.current = entry.path;
        Sounds.play("strong");
    }

    Process {
        id: applyProcess
    }

    // Lista los archivos de `dir` cuyo nombre calza con algún patrón. find va
    // como array (sin sh -c: una comilla en la ruta rompía el comando) y con
    // -print0, porque un nombre puede llevar saltos de línea pero nunca un
    // NUL. El orden se hace aquí y no con `sort`, que exigiría un shell.
    component FileList: Process {
        id: lister

        required property string dir
        required property var patterns

        signal listed(var paths)

        running: true
        command: {
            // ( -iname a -o -iname b ... ): un patrón por extensión.
            const names = [];
            for (const pattern of lister.patterns) {
                if (names.length > 0)
                    names.push("-o");
                names.push("-iname", pattern);
            }
            return ["find", lister.dir, "-maxdepth", "1", "-type", "f", "(", ...names, ")", "-print0"];
        }

        stdout: StdioCollector {
            id: listOut
            onStreamFinished: lister.listed(listOut.text.split("\0").filter(p => p.length > 0).sort((a, b) => a.localeCompare(b)))
        }
    }

    // -type f deja fuera los symlinks que mantiene el propio script
    // (current-wallpaper, current-lockscreen).
    FileList {
        dir: Settings.wallpaperDir
        patterns: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        onListed: paths => grid.statics = paths.map(p => ({
                    path: p,
                    thumb: p,
                    kind: "image"
                }))
    }

    // Los vídeos se muestran con la miniatura que pregenera `pregenerate-thumbs`;
    // un QML no puede sacar un fotograma de un mp4 por sí solo.
    FileList {
        dir: Settings.videoWallpaperDir
        patterns: ["*.mp4", "*.webm", "*.mkv"]
        onListed: paths => grid.videos = paths.map(p => ({
                    path: p,
                    thumb: `${Settings.wallpaperThumbDir}/video/${p.split("/").pop().replace(/\.[^.]+$/, "")}.jpg`,
                    kind: "video"
                }))
    }

    // Una scene se aplica por su id del Workshop, no por una ruta, así que se
    // listan desde el directorio de miniaturas ya generadas.
    FileList {
        dir: `${Settings.wallpaperThumbDir}/scene`
        patterns: ["*.jpg"]
        onListed: paths => grid.scenes = paths.map(p => ({
                    path: p.split("/").pop().replace(/\.jpg$/, ""),
                    thumb: p,
                    kind: "scene"
                }))
    }

    // Resuelve a qué archivo apunta el symlink, para marcar el activo.
    Process {
        id: currentProcess
        running: true
        command: ["readlink", "-f", `${Settings.wallpaperDir}/current-wallpaper`]

        stdout: StdioCollector {
            id: currentOut

            onStreamFinished: grid.current = currentOut.text.trim()
        }
    }

    RowLayout {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        MouseArea {
            id: backButton
            implicitWidth: backIcon.implicitWidth + 8
            implicitHeight: 20
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: grid.back()

            Text {
                id: backIcon
                anchors.centerIn: parent

                text: "\u{f104}" // angle-left
                color: backButton.containsMouse ? Colors.accent : Colors.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontLg
            }
        }

        // Nombrar la pantalla evita la duda de dónde va a aplicarse, ya que
        // el mismo panel existe en cada monitor.
        SectionHeader {
            Layout.fillWidth: true
            text: "Wallpapers · " + grid.monitor
        }

        Text {
            text: grid.entries.length
            color: Colors.textFaint
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontXs
        }
    }

    TabBar {
        id: tabs
        anchors.top: header.bottom
        anchors.topMargin: 6
        anchors.left: parent.left

        tabs: [
            {
                id: "image",
                label: "Static"
            },
            {
                id: "video",
                label: "Video"
            },
            {
                id: "scene",
                label: "Scene"
            }
        ]
        current: grid.kind
        onSelected: id => {
            if (grid.kind !== id) {
                grid.kind = id;
                Sounds.play("subtle");
            }
        }
    }

    GridView {
        id: view
        anchors.top: tabs.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.right: parent.right

        height: 260
        clip: true
        cellWidth: 100
        cellHeight: 62

        model: grid.entries

        delegate: WallpaperTile {
            id: tile

            required property var modelData

            width: view.cellWidth
            height: view.cellHeight
            thumb: tile.modelData.thumb
            kind: tile.modelData.kind
            current: tile.modelData.path === grid.current
            onActivated: grid.apply(tile.modelData)
        }
    }
}
