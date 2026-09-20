import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

import "../../config"

Item {
    id: slider

    required property PwNode node
    property real trackHeight: 5

    readonly property real value: node?.audio?.volume ?? 0
    readonly property bool muted: node?.audio?.muted ?? false

    implicitHeight: 14

    function setFromX(x) {
        const audio = slider.node?.audio;
        if (!audio)
            return;

        audio.volume = Math.max(0, Math.min(1, x / slider.width));
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right

        height: slider.trackHeight
        radius: height / 2
        color: Qt.alpha(Colors.foreground, 0.18)

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: parent.width * slider.value
            radius: parent.radius
            color: slider.muted ? Colors.alert : area.containsMouse ? Colors.accent : Colors.color4

            Behavior on color {
                ColorAnimation {
                    duration: 120
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

        color: slider.muted ? Colors.alert : Colors.foreground
        visible: area.containsMouse || area.pressed
    }

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -4

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: mouse => slider.setFromX(mouse.x)
        onPositionChanged: mouse => {
            if (pressed)
                slider.setFromX(mouse.x);
        }
        onWheel: wheel => {
            const audio = slider.node?.audio;
            if (!audio)
                return;

            const dir = wheel.angleDelta.y > 0 ? 1 : -1;
            audio.volume = Math.max(0, Math.min(1, audio.volume + dir * 0.05));
        }
    }
}
