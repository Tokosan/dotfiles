import QtQuick
import QtQuick.Layouts

import "../../config"

Rectangle {
    id: stat

    required property string label
    required property int value
    // false: pill con relleno de carga y etiqueta. true: pill plana con el
    // porcentaje. Alterna con el botón central.
    required property bool showPercent

    implicitWidth: showPercent ? pctMetrics.width + 16 : labelMetrics.width + 16
    implicitHeight: 26
    radius: 11

    color: Qt.alpha(Colors.foreground, 0.12)
    // El relleno se dibuja dentro, así que hay que recortarlo al radio.
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    TextMetrics {
        id: labelMetrics
        font: text.font
        text: "CPU"
    }

    TextMetrics {
        id: pctMetrics
        font: text.font
        text: "100%"
    }

    // Relleno proporcional a la carga, que sube desde abajo.
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        visible: !stat.showPercent
        height: parent.height * (stat.value / 100)
        color: Colors.loadColor(stat.value)

        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 400
            }
        }
    }

    Text {
        id: text
        anchors.centerIn: parent

        text: stat.showPercent ? stat.value + "%" : stat.label
        // Sobre el relleno claro el texto se oscurece, como en waybar.
        color: !stat.showPercent && stat.value >= 50 ? Colors.loadTextOnFill : Colors.foreground
        font.family: "JetBrains Mono Nerd Font"
        font.pixelSize: 11
        font.bold: true
    }
}
