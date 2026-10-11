import QtQuick

import "../../config"
import "../../common"
import "../../services"

// Botón de la esquina. Solo expone señales: TopBar decide qué hace cada
// click (izquierdo abre el launcher, derecho el menú).
BarPill {
    id: starButton

    signal primaryAction
    signal secondaryAction
    // La ráfaga de estrellitas la dibuja TopBar: las partículas tienen que
    // poder salir del botón sin recortarse.
    signal sparkle

    implicitWidth: 42
    // Ocupa la esquina entera, como en waybar: solo se curva hacia adentro,
    // por eso la inferior izquierda va pegada al canto.
    bottomLeftRadius: 0

    function celebrate() {
        Sounds.play("normal");
        starButton.sparkle();
        pulse.restart();
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
    }

    BarText {
        id: starGlyph
        anchors.centerIn: parent

        // nf-fa-star
        text: "\u{f005}"
        color: area.containsMouse ? Colors.accent : Colors.text
        font.pixelSize: Theme.fontXl
        font.bold: false

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
