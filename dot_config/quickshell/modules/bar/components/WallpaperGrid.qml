import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../config"

Item {
    id: grid

    signal back

    readonly property string directory: `${Quickshell.env("HOME")}/media/images/wallpapers/unsorted`
    // Lo aplica el script del usuario, que ya hace symlink, awww, pywal y la
    // imagen de lockscreen.
    readonly property string script: `${Quickshell.env("HOME")}/bin/change-wallpaper.sh`

    property var wallpapers: []
    property string current: ""

    implicitHeight: header.implicitHeight + 6 + view.height

    function apply(path) {
        applyProcess.command = [grid.script, path, "--wal", "--lock-file"];
        applyProcess.running = true;
        grid.current = path;
    }

    Process {
        id: applyProcess
    }

    // Lista las imágenes del directorio, excluyendo los symlinks que el propio
    // script mantiene (current-wallpaper, current-lockscreen).
    Process {
        id: listProcess
        running: true
        command: ["sh", "-c", `find '${grid.directory}' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort`]

        stdout: StdioCollector {
            onStreamFinished: {
                grid.wallpapers = text.trim().split("\n").filter(p => p.length > 0);
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

            text: "Wallpapers"
            color: Qt.alpha(Colors.foreground, 0.5)
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 9
            font.bold: true
            font.letterSpacing: 1
        }

        Text {
            text: grid.wallpapers.length
            color: Qt.alpha(Colors.foreground, 0.4)
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 9
        }
    }

    GridView {
        id: view
        anchors.top: header.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.right: parent.right

        height: 260
        clip: true
        cellWidth: 100
        cellHeight: 62

        model: grid.wallpapers

        delegate: Item {
            required property string modelData

            width: view.cellWidth
            height: view.cellHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                radius: 6
                color: "transparent"
                border.width: 2
                border.color: thumbArea.containsMouse ? Colors.accent : modelData === grid.current ? Colors.foreground : "transparent"
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

                    source: "file://" + modelData
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    // Se decodifica al tamaño de la miniatura, no al original.
                    sourceSize.width: 96
                    sourceSize.height: 56
                    cache: true
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
