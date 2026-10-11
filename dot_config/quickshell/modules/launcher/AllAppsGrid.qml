pragma ComponentBehavior: Bound

import QtQuick

import "../config"

// Pestaña "All" y resultados de búsqueda. Click abre la app; click derecho la
// agrega o quita de favoritos.
Item {
    id: root

    // Lista de DesktopEntry ya filtrada y ordenada (AppCatalog.search).
    property var apps: []
    // Lo escrito, solo para el mensaje de "sin resultados".
    property string query: ""
    // Índice marcado como "el que abre Enter"; -1 para ninguno.
    property int highlightedIndex: -1
    readonly property int count: root.apps.length

    signal launched(var entry)

    onHighlightedIndexChanged: grid.followHighlight()

    // Abre la app en esa posición (Enter desde el campo de búsqueda).
    function activate(index) {
        if (index >= 0 && index < root.apps.length)
            root.launched(root.apps[index]);
    }

    GridView {
        id: grid
        anchors.fill: root
        clip: true

        cellWidth: Math.floor(grid.width / Theme.launcherColumns)
        cellHeight: Theme.launcherCellHeight
        model: root.apps
        boundsBehavior: Flickable.StopAtBounds
        // Con las flechas la selección puede salir de la vista; se desplaza
        // lo justo para que se vea.
        onCountChanged: grid.followHighlight()

        function followHighlight() {
            if (root.highlightedIndex >= 0 && root.highlightedIndex < grid.count)
                grid.positionViewAtIndex(root.highlightedIndex, GridView.Contain);
        }

        delegate: MouseArea {
            id: cell
            required property var modelData
            required property int index

            width: grid.cellWidth
            height: grid.cellHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: mouse => {
                if (mouse.button === Qt.RightButton)
                    LauncherState.toggleFavorite(cell.modelData.id);
                else
                    root.launched(cell.modelData);
            }

            AppTile {
                anchors.fill: cell
                entry: cell.modelData
                hovered: cell.containsMouse
                favorite: LauncherState.isFavorite(cell.modelData.id)
                highlighted: cell.index === root.highlightedIndex
            }
        }
    }

    EmptyMessage {
        visible: root.query.length > 0 && root.apps.length === 0
        anchors.centerIn: root
        text: "No apps match “" + root.query + "”"
    }
}
