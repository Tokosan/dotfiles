pragma ComponentBehavior: Bound

import Quickshell.Services.Pipewire
import QtQuick

import "../../config"
import "../../common"
import "../../services"

// Porcentaje + icono de un canal de audio (micrófono o salida). Un solo
// MouseArea cubre los dos y el hueco entre ambos.
//   click izquierdo: mutea · rueda: volumen · click medio: señal middleClicked
MouseArea {
    id: control

    required property PwNode node
    // Glifo a mostrar ahora.
    required property string icon
    // Todos los glifos posibles: se reserva el ancho del más ancho para que
    // nada se corra al cambiar de nivel o al mutear.
    required property var iconGlyphs
    // true: icono y luego número (salida). false: número y luego icono (mic).
    property bool iconFirst: true

    signal middleClicked

    readonly property real gap: 5
    readonly property color tint: Audio.isMuted(control.node) ? Colors.alert : control.containsMouse ? Colors.accent : Colors.text

    implicitWidth: glyphProbe.implicitWidth + control.gap + pctMetrics.width
    implicitHeight: pct.implicitHeight
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    onClicked: mouse => {
        if (mouse.button === Qt.MiddleButton)
            control.middleClicked();
        else
            Audio.toggleMute(control.node);
    }
    onWheel: wheel => Audio.nudge(control.node, wheel.angleDelta.y)

    // Mide todos los glifos: una Column toma el ancho de su hijo más ancho.
    // Transparente y no `visible: false`, para que se siga midiendo.
    Column {
        id: glyphProbe
        opacity: 0

        Repeater {
            model: control.iconGlyphs

            BarText {
                required property string modelData
                text: modelData
            }
        }
    }

    // Ancho del caso más largo, para que la pill no salte de 2 a 3 cifras.
    TextMetrics {
        id: pctMetrics
        font: pct.font
        text: "100%"
    }

    BarText {
        id: iconText
        x: control.iconFirst ? 0 : pctMetrics.width + control.gap
        anchors.verticalCenter: parent.verticalCenter

        text: control.icon
        color: control.tint
    }

    BarText {
        id: pct
        x: control.iconFirst ? glyphProbe.implicitWidth + control.gap : 0
        anchors.verticalCenter: parent.verticalCenter
        width: pctMetrics.width
        horizontalAlignment: control.iconFirst ? Text.AlignLeft : Text.AlignRight

        text: Audio.label(control.node)
        color: control.tint
    }
}
