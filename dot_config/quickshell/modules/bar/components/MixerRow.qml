import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import "../../config"
import "../../services"

// Fila del mezclador: icono (click = mute), nombre, porcentaje y slider.
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

            MouseArea {
                id: muteArea
                implicitWidth: iconText.implicitWidth
                implicitHeight: iconText.implicitHeight
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Audio.toggleMute(mixerRow.node)

                Text {
                    id: iconText
                    anchors.centerIn: parent

                    text: mixerRow.icon
                    color: Audio.isMuted(mixerRow.node) ? Colors.alert : muteArea.containsMouse ? Colors.accent : Colors.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontMd
                }
            }

            Text {
                Layout.fillWidth: true

                text: mixerRow.label
                elide: Text.ElideRight
                color: Colors.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }

            Text {
                text: Audio.label(mixerRow.node)
                color: Colors.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSm
                font.bold: true
            }
        }

        VolumeSlider {
            Layout.fillWidth: true
            node: mixerRow.node
        }
    }
}
