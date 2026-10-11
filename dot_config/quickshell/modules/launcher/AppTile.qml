import Quickshell
import Quickshell.Widgets
import QtQuick

import "../config"

// Solo la parte visual de una app: icono, nombre y fondo de hover. El mouse lo
// maneja quien lo contiene, porque en favoritos además se arrastra.
Item {
    id: tile

    property var entry: null
    property bool hovered: false
    property bool favorite: false
    // La app que abre Enter: se marca con un borde.
    property bool highlighted: false

    Rectangle {
        anchors.fill: tile
        anchors.margins: 3
        radius: Theme.launcherTileRadius
        color: tile.hovered ? Colors.surfaceRaised : tile.highlighted ? Colors.surfaceSubtle : "transparent"
        border.width: tile.highlighted ? 1 : 0
        border.color: Colors.focusRing

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }
    }

    // Algunos .desktop traen una ruta absoluta en vez de un nombre de tema.
    // Vacío si no hay icono: el tema que usa Qt (hicolor) tampoco trae el
    // genérico application-x-executable, así que no sirve como fallback.
    readonly property string iconSource: {
        const name = tile.entry?.icon ?? "";
        if (name.startsWith("/"))
            return "file://" + name;
        return name ? Quickshell.iconPath(name, true) : "";
    }

    IconImage {
        id: icon
        anchors.horizontalCenter: tile.horizontalCenter
        anchors.top: tile.top
        anchors.topMargin: 12

        implicitSize: Theme.launcherIconSize
        visible: tile.iconSource !== ""
        source: tile.iconSource
    }

    Text {
        visible: tile.iconSource === ""
        anchors.centerIn: icon

        // nf-md-application
        text: "\u{f08c6}"
        color: Colors.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontIconLarge
    }

    // Marca de favorito, para distinguirlos en la pestaña All.
    Text {
        visible: tile.favorite
        anchors.right: icon.right
        anchors.top: icon.top
        anchors.rightMargin: -6
        anchors.topMargin: -4

        // nf-fa-star
        text: "\u{f005}"
        color: Colors.accent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSm
    }

    Text {
        anchors.top: icon.bottom
        anchors.topMargin: 6
        anchors.left: tile.left
        anchors.right: tile.right
        anchors.leftMargin: 6
        anchors.rightMargin: 6

        text: tile.entry?.name ?? ""
        color: Colors.text
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSm
    }
}
