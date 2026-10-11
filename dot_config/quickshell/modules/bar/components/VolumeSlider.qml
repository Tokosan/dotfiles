import Quickshell.Services.Pipewire
import QtQuick

import "../../config"
import "../../services"

// Slider de volumen de un nodo. Click o arrastre fija el nivel; rueda lo
// mueve un paso.
Item {
    id: slider

    required property PwNode node
    property real trackHeight: 5

    readonly property real value: slider.node?.audio?.volume ?? 0
    readonly property bool muted: Audio.isMuted(slider.node)

    implicitHeight: 14

    // x en coordenadas del MouseArea, que sobresale 4 px por cada lado para
    // que sea fácil de agarrar: hay que pasarla a las del slider.
    function setFromAreaX(x) {
        const local = area.mapToItem(slider, x, 0).x;
        Audio.setVolume(slider.node, local / slider.width);
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right

        height: slider.trackHeight
        radius: height / 2
        color: Colors.sliderTrack

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: track.width * slider.value
            radius: track.radius
            color: slider.muted ? Colors.alert : area.containsMouse ? Colors.accent : Colors.sliderFill

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }
        }
    }

    Rectangle {
        id: handle
        anchors.verticalCenter: track.verticalCenter

        x: Math.max(0, Math.min(slider.width - width, slider.width * slider.value - width / 2))
        width: 11
        height: 11
        radius: width / 2

        color: slider.muted ? Colors.alert : Colors.text
        visible: area.containsMouse || area.pressed
    }

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -4

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: mouse => slider.setFromAreaX(mouse.x)
        onPositionChanged: mouse => {
            if (area.pressed)
                slider.setFromAreaX(mouse.x);
        }
        onWheel: wheel => Audio.nudge(slider.node, wheel.angleDelta.y)
    }
}
