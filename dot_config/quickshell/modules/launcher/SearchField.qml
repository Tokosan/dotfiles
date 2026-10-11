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
