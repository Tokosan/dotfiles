import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import "../../config"

Item {
    id: mixerRow

    required property string icon
    required property string label
    required property PwNode node

    implicitHeight: column.implicitHeight

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 3

        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            // Click en el icono: mutea este canal.
            MouseArea {
                implicitWidth: iconText.implicitWidth
                implicitHeight: iconText.implicitHeight
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    const audio = mixerRow.node?.audio;
                    if (audio)
                        audio.muted = !audio.muted;
                }

                Text {
                    id: iconText
                    anchors.centerIn: parent

                    text: mixerRow.icon
                    color: mixerRow.node?.audio?.muted ? Colors.alert : parent.containsMouse ? Colors.accent : Colors.foreground
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 12
                }
            }

            Text {
                Layout.fillWidth: true

                text: mixerRow.label
                elide: Text.ElideRight
                color: Colors.foreground
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 11
            }

            Text {
                text: mixerRow.node?.audio?.muted ? "---" : Math.round((mixerRow.node?.audio?.volume ?? 0) * 100) + "%"
                color: Qt.alpha(Colors.foreground, 0.7)
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 10
                font.bold: true
            }
        }

        VolumeSlider {
            Layout.fillWidth: true
            node: mixerRow.node
        }
    }
}
