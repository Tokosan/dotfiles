import QtQuick

import "../config"

// Campo de búsqueda del launcher. No decide nada: avisa de las teclas
// especiales con señales y la ventana actúa.
Rectangle {
    id: field

    readonly property alias text: input.text

    signal escapePressed
    signal acceptPressed
    signal tabPressed
    // Flechas: columnas (izq/der) y filas (arriba/abajo) a mover en la grilla.
    signal moveSelection(int columns, int rows)

    function clear() {
        input.text = "";
        input.forceActiveFocus();
    }

    implicitHeight: Theme.launcherSearchHeight
    radius: Theme.launcherTileRadius
    color: Colors.surfaceSubtle

    Text {
        id: searchIcon
        anchors.left: field.left
        anchors.leftMargin: 12
        anchors.verticalCenter: field.verticalCenter

        // nf-fa-search
        text: "\u{f002}"
        color: Colors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontMd
    }

    TextInput {
        id: input
        anchors.left: searchIcon.right
        anchors.right: field.right
        anchors.leftMargin: 10
        anchors.rightMargin: 12
        anchors.verticalCenter: field.verticalCenter

        // Con foco desde el principio: se escribe apenas se abre.
        focus: true
        color: Colors.text
        selectionColor: Colors.selection
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontMd
        clip: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape)
                field.escapePressed();
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                field.acceptPressed();
            else if (event.key === Qt.Key_Tab)
                field.tabPressed();
            // Izquierda/derecha también mueven la selección y no el cursor
            // del texto: las búsquedas son de pocas letras y moverse por la
            // grilla es lo que se usa.
            else if (event.key === Qt.Key_Left)
                field.moveSelection(-1, 0);
            else if (event.key === Qt.Key_Right)
                field.moveSelection(1, 0);
            else if (event.key === Qt.Key_Up)
                field.moveSelection(0, -1);
            else if (event.key === Qt.Key_Down)
                field.moveSelection(0, 1);
            else
                return;
            event.accepted = true;
        }

        Text {
            visible: input.text.length === 0
            anchors.verticalCenter: input.verticalCenter
            text: "Search apps…"
            color: Colors.textFaint
            font: input.font
        }
    }
}
