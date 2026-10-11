import QtQuick

import "../../config"
import "../../common"

// Una miniatura de la grilla de wallpapers. No sabe aplicar nada: avisa con
// `activated` y la grilla decide (igual que StarButton).
Item {
    id: tile

    // Lo que se pinta: ruta local de la imagen o de su miniatura pregenerada.
    required property string thumb
    // "image", "video" o "scene": decide el distintivo de la esquina.
    required property string kind
    // Es el fondo que tiene puesto esta pantalla.
    property bool current: false
    // Se está aplicando (el script todavía no terminó).
    property bool pending: false
    // El último intento de aplicarlo falló.
    property bool failed: false

    signal activated

    Rectangle {
        id: frame
        anchors.fill: tile
        anchors.margins: 3

        radius: Theme.itemRadius
        color: "transparent"
        border.width: 2
        // El fallo pesa más que el hover: si no, el rojo desaparece justo
        // mientras el mouse sigue encima y no se llega a ver.
        border.color: tile.failed ? Colors.alert : area.containsMouse ? Colors.accent : tile.current ? Colors.text : "transparent"
        clip: true

        Behavior on border.color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }

        Image {
            id: image
            anchors.fill: frame
            anchors.margins: 2

            source: Util.fileUrl(tile.thumb)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            // Se decodifica al tamaño de la miniatura, no al original.
            sourceSize.width: 96
            sourceSize.height: 56
            cache: true
            // Mientras el script trabaja la miniatura se apaga un poco, para
            // que se note que el click llegó.
            opacity: tile.pending ? 0.5 : 1

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animNormal
                }
            }
        }

        // Distintivo para los animados: sin él, un vídeo y una imagen se ven
        // idénticos en la grilla.
        Rectangle {
            id: badge
            visible: tile.kind !== "image"
            anchors.right: image.right
            anchors.bottom: image.bottom
            anchors.margins: 3

            width: 14
            height: 14
            radius: 7
            color: Colors.badgeBackground

            Text {
                anchors.centerIn: badge
                // f04b: play (vídeo) · f0d0: varita mágica (scene)
                text: tile.kind === "video" ? "\u{f04b}" : "\u{f0d0}"
                color: Colors.badgeForeground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBadge
            }
        }

        MouseArea {
            id: area
            anchors.fill: frame
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.activated()
        }
    }
}
