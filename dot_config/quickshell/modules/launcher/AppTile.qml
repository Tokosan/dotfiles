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
    // Primer resultado de la búsqueda: es el que abre Enter.
    property bool highlighted: false

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        radius: 10
        color: tile.hovered ? Qt.alpha(Colors.foreground, 0.12) : tile.highlighted ? Qt.alpha(Colors.foreground, 0.07) : "transparent"
        border.width: tile.highlighted ? 1 : 0
        border.color: Qt.alpha(Colors.accent, 0.6)

        Behavior on color {
            ColorAnimation {
                duration: 120
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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 12

        implicitSize: 40
        visible: tile.iconSource !== ""
        source: tile.iconSource
    }

    Text {
        visible: tile.iconSource === ""
        anchors.centerIn: icon

        // nf-md-application
        text: "\u{f08c6}"
        color: Qt.alpha(Colors.foreground, 0.6)
        font.family: "JetBrains Mono Nerd Font"
        font.pixelSize: 32
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
        font.family: "JetBrains Mono Nerd Font"
        font.pixelSize: 10
    }

    Text {
        anchors.top: icon.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 6
        anchors.rightMargin: 6

        text: tile.entry?.name ?? ""
        color: Colors.foreground
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        font.family: "JetBrains Mono Nerd Font"
        font.pixelSize: 10
    }
}
