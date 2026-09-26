import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtMultimedia

import "../../config"

Item {
    id: grid

    signal back

    // La pantalla donde vive esta barra: el fondo se aplica donde se hizo
    // click, sin tener que elegir el monitor a mano.
    required property string monitor

    readonly property string home: Quickshell.env("HOME")
    readonly property string directory: `${home}/media/images/wallpapers/unsorted`
    readonly property string videoDirectory: `${home}/media/videos/wallpapers`
    readonly property string thumbDirectory: `${home}/.cache/wallpaper-thumbs`
    // Lo aplica el script del usuario, que ya hace symlink, awww, pywal y la
    // imagen de lockscreen. Acepta una imagen, un vídeo o el id de una scene.
    readonly property string script: `${home}/bin/change-wallpaper.sh`

    // Cada entrada es { path, thumb, kind }: `path` es lo que se le pasa al
    // script (ruta o id de scene) y `thumb` lo que se pinta en la grilla.
    property var statics: []
    property var videos: []
    property var scenes: []

    property string kind: "image"
    property string current: ""

    readonly property var entries: kind === "video" ? videos : kind === "scene" ? scenes : statics

    implicitHeight: header.implicitHeight + 6 + tabs.implicitHeight + 6 + view.height

    function apply(entry) {
        applyProcess.command = [grid.script, entry.path, "--monitor", grid.monitor, "--wal", "--lock-file"];
        applyProcess.running = true;
        grid.current = entry.path;
        applySound.play();
    }

    Process {
        id: applyProcess
    }

    // Mismo chime que el botón de la estrella, a distinto volumen y tono según
    // el peso de la acción: cambiar de pestaña pesa menos que aplicar un fondo.
    SoundEffect {
        id: tabSound
        source: Qt.resolvedUrl("../../../assets/chime.wav")
        volume: 0.18
    }

    SoundEffect {
        id: applySound
        source: Qt.resolvedUrl("../../../assets/chime.wav")
        volume: 0.4
    }

    // Lista las imágenes del directorio, excluyendo los symlinks que el propio
    // script mantiene (current-wallpaper, current-lockscreen).
    Process {
        id: listProcess
        running: true
        command: ["sh", "-c", `find '${grid.directory}' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort`]

        stdout: StdioCollector {
            onStreamFinished: {
                grid.statics = text.trim().split("\n").filter(p => p.length > 0).map(p => ({
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
        command: ["sh", "-c", `find '${grid.videoDirectory}' -maxdepth 1 -type f \\( -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' \\) | sort`]

        stdout: StdioCollector {
            onStreamFinished: {
                grid.videos = text.trim().split("\n").filter(p => p.length > 0).map(p => {
                    const base = p.split("/").pop().replace(/\.[^.]+$/, "");
                    return {
                        path: p,
                        thumb: `${grid.thumbDirectory}/video/${base}.jpg`,
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
        command: ["sh", "-c", `find '${grid.thumbDirectory}/scene' -maxdepth 1 -name '*.jpg' 2>/dev/null | sort`]

        stdout: StdioCollector {
            onStreamFinished: {
                grid.scenes = text.trim().split("\n").filter(p => p.length > 0).map(p => ({
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
        command: ["readlink", "-f", `${grid.directory}/current-wallpaper`]

        stdout: StdioCollector {
            onStreamFinished: grid.current = text.trim()
        }
    }

    RowLayout {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        MouseArea {
            implicitWidth: backIcon.implicitWidth + 8
            implicitHeight: 20
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: grid.back()

            Text {
                id: backIcon
                anchors.centerIn: parent

                text: "\u{f104}"
                color: parent.containsMouse ? Colors.accent : Colors.foreground
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 14
            }
        }

        Text {
            Layout.fillWidth: true

            // Nombrar la pantalla evita la duda de dónde va a aplicarse, ya
            // que el mismo panel existe en cada monitor.
            text: "Wallpapers · " + grid.monitor
            color: Qt.alpha(Colors.foreground, 0.5)
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1
        }

        Text {
            text: grid.entries.length
            color: Qt.alpha(Colors.foreground, 0.4)
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 9
        }
    }

    RowLayout {
        id: tabs
        anchors.top: header.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        spacing: 4

        Repeater {
            model: [
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

            MouseArea {
                required property var modelData

                readonly property bool active: grid.kind === modelData.id

                implicitWidth: tabLabel.implicitWidth + 16
                implicitHeight: 20
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (grid.kind !== modelData.id) {
                        grid.kind = modelData.id;
                        tabSound.play();
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: parent.active ? Qt.alpha(Colors.foreground, 0.14) : parent.containsMouse ? Qt.alpha(Colors.foreground, 0.07) : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                }

                Text {
                    id: tabLabel
                    anchors.centerIn: parent

                    text: parent.modelData.label
                    color: parent.active ? Colors.foreground : Qt.alpha(Colors.foreground, 0.45)
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 9
                    font.bold: parent.active
                }
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

        delegate: Item {
            required property var modelData

            width: view.cellWidth
            height: view.cellHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                radius: 6
                color: "transparent"
                border.width: 2
                border.color: thumbArea.containsMouse ? Colors.accent : modelData.path === grid.current ? Colors.foreground : "transparent"
                clip: true

                Behavior on border.color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Image {
                    id: thumb
                    anchors.fill: parent
                    anchors.margins: 2

                    source: "file://" + modelData.thumb
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    // Se decodifica al tamaño de la miniatura, no al original.
                    sourceSize.width: 96
                    sourceSize.height: 56
                    cache: true
                }

                // Distintivo para los animados: sin él, un vídeo y una imagen
                // se ven idénticos en la grilla.
                Rectangle {
                    visible: modelData.kind !== "image"
                    anchors.right: thumb.right
                    anchors.bottom: thumb.bottom
                    anchors.margins: 3

                    width: 14
                    height: 14
                    radius: 7
                    color: Qt.alpha("#000000", 0.55)

                    Text {
                        anchors.centerIn: parent
                        text: modelData.kind === "video" ? "\u{f04b}" : "\u{f0d0}"
                        color: "#ffffff"
                        font.family: "JetBrains Mono Nerd Font"
                        font.pixelSize: 7
                    }
                }

                MouseArea {
                    id: thumbArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: grid.apply(modelData)
                }
            }
        }
    }
}
