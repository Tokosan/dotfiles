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

    // Lista las imágenes del directorio, excluyendo los symlinks que el propio
    // script mantiene (current-wallpaper, current-lockscreen).
    Process {
        id: listProcess
        running: true
        command: ["sh", "-c", `find '${Settings.wallpaperDir}' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort`]

        stdout: StdioCollector {
            id: staticsOut

            onStreamFinished: {
                grid.statics = staticsOut.text.trim().split("\n").filter(p => p.length > 0).map(p => ({
                            path: p,
                            thumb: p,
                            kind: "image"
                        }));
            }
        }
    }

    // Los vídeos se muestran con la miniatura que pregenera `pregenerate-thumbs`;
    // un QML no puede sacar un fotograma de un mp4 por sí solo.
    Process {
        id: listVideos
        running: true
        command: ["sh", "-c", `find '${Settings.videoWallpaperDir}' -maxdepth 1 -type f \\( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' \\) | sort`]

        stdout: StdioCollector {
            id: videosOut

            onStreamFinished: {
                grid.videos = videosOut.text.trim().split("\n").filter(p => p.length > 0).map(p => {
                    const base = p.split("/").pop().replace(/\.[^.]+$/, "");
                    return {
                        path: p,
                        thumb: `${Settings.wallpaperThumbDir}/video/${base}.jpg`,
                        kind: "video"
                    };
                });
            }
        }
    }

    // Una scene se aplica por su id del Workshop, no por una ruta, así que se
    // listan desde el directorio de miniaturas ya generadas.
    Process {
        id: listScenes
        running: true
        command: ["sh", "-c", `find '${Settings.wallpaperThumbDir}/scene' -maxdepth 1 -name '*.jpg' 2>/dev/null | sort`]

        stdout: StdioCollector {
            id: scenesOut

            onStreamFinished: {
                grid.scenes = scenesOut.text.trim().split("\n").filter(p => p.length > 0).map(p => ({
                            path: p.split("/").pop().replace(/\.jpg$/, ""),
                            thumb: p,
                            kind: "scene"
                        }));
            }
        }
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
