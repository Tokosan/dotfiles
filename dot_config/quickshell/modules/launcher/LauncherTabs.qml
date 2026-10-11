import QtQuick
import QtQuick.Layouts

import "../config"
import "../common"

// Pestañas Favorites/All y, a la derecha, la pista de qué hace el mouse en
// la pestaña visible.
RowLayout {
    id: row

    // Buscando siempre se ve All, así que la ventana pasa lo que se VE, no la
    // pestaña elegida.
    required property bool showingAll

    signal selected(string id)

    TabBar {
        tabs: [
            {
                id: "favs",
                label: "Favorites"
            },
            {
                id: "all",
                label: "All"
            }
        ]
        current: row.showingAll ? "all" : "favs"
        onSelected: id => row.selected(id)
    }

    Item {
        Layout.fillWidth: true
    }

    Text {
        text: row.showingAll ? "Right-click: toggle favorite" : "Drag to reorder · Right-click: remove"
        color: Colors.textFaint
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontXs
    }
}
