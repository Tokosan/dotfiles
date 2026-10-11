import QtQuick
import QtQuick.Layouts

import "../../config"

// Fila de menú: icono + texto. Emite `triggered` al hacer click; qué hace lo
// decide el menú que la contiene.
MouseArea {
    id: entry

    required property string icon
    required property string label

    // Esperando confirmación: se tiñe de alerta para que se note que el
    // siguiente click sí ejecuta.
    property bool armed: false

    signal triggered

    // Texto e icono comparten color salvo en el hover, donde solo el icono
    // toma el acento. Las entradas sin implementar (enabled: false) se
    // muestran atenuadas.
    readonly property color baseColor: !entry.enabled ? Colors.textDisabled : entry.armed ? Colors.alert : Colors.text

    implicitHeight: 26
    hoverEnabled: entry.enabled
    cursorShape: entry.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: entry.triggered()

    Rectangle {
        anchors.fill: parent
        radius: Theme.itemRadius
        color: entry.enabled && entry.containsMouse ? Colors.surfaceHover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
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
            color: entry.enabled && !entry.armed && entry.containsMouse ? Colors.accent : entry.baseColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontMd

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }
        }

        Text {
            Layout.fillWidth: true

            text: entry.label
            elide: Text.ElideRight
            color: entry.baseColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
        }
    }
}
