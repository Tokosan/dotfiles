import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

import "../../config"

Rectangle {
    id: stat

    required property string label
    required property int value
    // false: pill con relleno de carga y etiqueta. true: pill plana con el
    // porcentaje. Alterna con el botón central.
    required property bool showPercent

    // Fracción de la pill que ocupa el relleno, animada aparte para que el
    // gradiente se mueva suave.
    property real fillRatio: showPercent ? 0 : value / 100

    implicitWidth: showPercent ? pctMetrics.width + 16 : labelMetrics.width + 16
    implicitHeight: 26
    radius: 11

    // El relleno es el propio fondo de la pill, como el linear-gradient de
    // waybar: así respeta el borde redondeado sin recortes.
    gradient: Gradient {
        GradientStop {
            position: 0
            color: Qt.alpha(Colors.foreground, 0.12)
        }
        GradientStop {
            position: Math.max(0, 1 - stat.fillRatio - 0.001)
            color: Qt.alpha(Colors.foreground, 0.12)
        }
        GradientStop {
            position: Math.max(0, 1 - stat.fillRatio)
            color: stat.showPercent ? Qt.alpha(Colors.foreground, 0.12) : Colors.loadColor(stat.value)
        }
        GradientStop {
            position: 1
            color: stat.showPercent ? Qt.alpha(Colors.foreground, 0.12) : Colors.loadColor(stat.value)
        }
    }

    Behavior on fillRatio {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

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
