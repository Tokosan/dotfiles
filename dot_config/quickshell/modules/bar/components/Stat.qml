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
    // Cuánto tarda el porcentaje en aparecer o desvanecerse.
    property real fadeDuration: 120

    implicitWidth: pill.implicitWidth
    implicitHeight: pillHeight + extraHeight

    // El despliegue va por estados y no por Behavior: así el porcentaje se
    // desvanece del todo antes de que la pill empiece a encogerse, en vez de
    // animarse ambos a la vez y dejar el texto flotando un frame.
    property real extraHeight: 0
    property real pctOpacity: 0

    states: [
        State {
            name: "expanded"
            when: stat.expanded

            PropertyChanges {
                stat.extraHeight: pctChip.implicitHeight + 3
                stat.pctOpacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            to: "expanded"

            SequentialAnimation {
                NumberAnimation {
                    property: "extraHeight"
                    duration: 200
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    property: "pctOpacity"
                    duration: stat.fadeDuration
                }
            }
        },
        Transition {
            from: "expanded"

            SequentialAnimation {
                NumberAnimation {
                    property: "pctOpacity"
                    duration: stat.fadeDuration
                }

                NumberAnimation {
                    property: "extraHeight"
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
    ]

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

    // Porcentaje bajo la pill, visible solo al expandir. Lleva su propio fondo
    // porque flota sobre el wallpaper, no sobre la barra.
    Rectangle {
        id: pctChip
        anchors.top: pill.bottom
        anchors.topMargin: 3
        anchors.horizontalCenter: pill.horizontalCenter

        visible: opacity > 0
        opacity: stat.pctOpacity

        implicitWidth: expandedPct.implicitWidth + 10
        implicitHeight: expandedPct.implicitHeight + 4
        radius: height / 2

        color: Colors.panelBackground
        border.width: 1
        border.color: Colors.panelBorder

        Text {
            id: expandedPct
            anchors.centerIn: parent

            text: stat.value + "%"
            color: Colors.foreground
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 10
            font.bold: true
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
