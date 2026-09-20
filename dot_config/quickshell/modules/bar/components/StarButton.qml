import Quickshell
import QtQuick
import QtQuick.Particles
import QtMultimedia

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
    // Ocupa la esquina entera, como en waybar: solo se curva hacia adentro,
    // por eso la inferior izquierda va pegada al canto.
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: 0
    bottomRightRadius: bottomRadius

    // La ráfaga la dispara quien nos contiene: las partículas tienen que
    // poder salir del botón sin recortarse.
    signal sparkle

    function celebrate() {
        chime.play();
        starButton.sparkle();
        pulse.restart();
    }

    SoundEffect {
        id: chime
        source: Qt.resolvedUrl("../../../assets/chime.wav")
        volume: 0.35
    }

    MouseArea {
        id: area
        anchors.fill: parent

        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            starButton.celebrate();

            if (mouse.button === Qt.RightButton)
                starButton.secondaryAction();
            else
                starButton.primaryAction();
        }

        Text {
            id: starGlyph
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

            // Rebote al hacer click.
            SequentialAnimation {
                id: pulse

                NumberAnimation {
                    target: starGlyph
                    property: "scale"
                    to: 1.35
                    duration: 90
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: starGlyph
                    property: "scale"
                    to: 1
                    duration: 260
                    easing.type: Easing.OutBack
                }
            }
        }
    }
}
