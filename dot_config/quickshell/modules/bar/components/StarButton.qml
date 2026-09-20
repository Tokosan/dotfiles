import QtQuick

import "../../config"

Rectangle {
    id: starButton

    // Acciones que expone: el consumidor decide qué hacen.
    signal primaryAction
    signal secondaryAction

    property real barHeight: 34
    property real bottomRadius: 15

    implicitWidth: 42
    implicitHeight: barHeight

    color: Colors.barBackground
    bottomLeftRadius: bottomRadius
    bottomRightRadius: bottomRadius

    MouseArea {
        id: area
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton)
                starButton.secondaryAction();
            else
                starButton.primaryAction();
        }

        Text {
            anchors.centerIn: parent

            // nf-fa-star
            text: "\u{f005}"
            color: area.containsMouse ? Colors.accent : Colors.foreground
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 15

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
        }
    }
}
