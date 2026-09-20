import QtQuick
import QtQuick.Layouts

import "../../config"

MouseArea {
    id: entry

    required property string icon
    required property string label

    signal triggered

    implicitHeight: 26
    hoverEnabled: enabled
    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: entry.triggered()

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: entry.enabled && entry.containsMouse ? Qt.alpha(Colors.foreground, 0.1) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 9

        Text {
            text: entry.icon
            // Las entradas sin implementar se muestran atenuadas.
            color: entry.enabled ? (entry.containsMouse ? Colors.accent : Colors.foreground) : Qt.alpha(Colors.foreground, 0.3)
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 12

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
        }

        Text {
            Layout.fillWidth: true

            text: entry.label
            elide: Text.ElideRight
            color: entry.enabled ? Colors.foreground : Qt.alpha(Colors.foreground, 0.3)
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 11
        }
    }
}
