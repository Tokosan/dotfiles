import QtQuick
import QtQuick.Layouts

import "../../config"

Item {
    id: stat

    required property string label
    required property int value
    // false: pill con relleno de carga y etiqueta. true: pill plana con el
    // porcentaje. Alterna con el botón central.
    required property bool showPercent
    // Muestra el porcentaje bajo la pill, fuera de ella.
    required property bool expanded

    property real pillHeight: 26

    implicitWidth: pill.implicitWidth
    implicitHeight: pillHeight + (expanded ? expandedPct.implicitHeight + 3 : 0)

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        id: pill
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        // Fracción de la pill que ocupa el relleno, animada aparte para que el
        // gradiente se mueva suave.
        property real fillRatio: stat.showPercent ? 0 : stat.value / 100

        implicitWidth: stat.showPercent ? pctMetrics.width + 16 : labelMetrics.width + 16
        height: stat.pillHeight
        radius: 11

        // El relleno es el propio fondo de la pill, como el linear-gradient de
        // waybar: así respeta el borde redondeado sin recortes.
        gradient: Gradient {
            GradientStop {
                position: 0
                color: Qt.alpha(Colors.foreground, 0.12)
            }
            GradientStop {
                position: Math.max(0, 1 - pill.fillRatio - 0.001)
                color: Qt.alpha(Colors.foreground, 0.12)
            }
            GradientStop {
                position: Math.max(0, 1 - pill.fillRatio)
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

    // Porcentaje bajo la pill, visible solo al expandir.
    Text {
        id: expandedPct
        anchors.top: pill.bottom
        anchors.topMargin: 3
        anchors.horizontalCenter: pill.horizontalCenter

        visible: opacity > 0
        opacity: stat.expanded ? 1 : 0

        text: stat.value + "%"
        color: Colors.foreground
        font.family: "JetBrains Mono Nerd Font"
        font.pixelSize: 10
        font.bold: true

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
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
}
