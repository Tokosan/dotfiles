pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import "../config"

// Pestaña "Favorites": grilla reordenable con arrastre. Trabaja sobre una
// copia local (ListModel) para que GridView anime los movimientos; al soltar
// se guarda el orden en LauncherState.
Item {
    id: root

    property int highlightedIndex: -1
    readonly property int count: favModel.count

    // Mientras se arrastra no se reconstruye el modelo: borraría el delegate
    // que se está moviendo.
    property bool dragging: false
    // Fila donde está ahora el icono arrastrado; cambia con cada move().
    property int dragIndex: -1

    signal launched(var entry)

    function activate(index) {
        if (index >= 0 && index < favModel.count)
            root.launched(DesktopEntries.byId(favModel.get(index).appId));
    }

    function sync() {
        if (root.dragging)
            return;
        // Se omiten las apps desinstaladas en vez de mostrar un hueco.
        const ids = LauncherState.favorites.filter(id => DesktopEntries.byId(id) !== null);
        const current = [];
        for (let i = 0; i < favModel.count; i++)
            current.push(favModel.get(i).appId);
        if (current.join("\n") === ids.join("\n"))
            return;
        favModel.clear();
        for (const id of ids)
            favModel.append({
                appId: id
            });
    }

    function commit() {
        const ids = [];
        for (let i = 0; i < favModel.count; i++)
            ids.push(favModel.get(i).appId);
        LauncherState.reorderFavorites(ids);
    }

    ListModel {
        id: favModel
    }

    Component.onCompleted: root.sync()

    Connections {
        target: LauncherState
        function onFavoritesChanged() {
            root.sync();
        }
    }

    // Un favorito oculto por no encontrarse su .desktop vuelve a verse si la
    // app se instala con el launcher abierto (y uno desinstalado se va).
    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            root.sync();
        }
    }

    GridView {
        id: grid
        anchors.fill: root
        clip: true
        interactive: !root.dragging

        cellWidth: Math.floor(grid.width / Theme.launcherColumns)
        cellHeight: Theme.launcherCellHeight
        model: favModel
        boundsBehavior: Flickable.StopAtBounds

        // Los demás iconos se corren con animación al abrir hueco al que se
        // arrastra.
        move: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: Theme.animNormal
                easing.type: Theme.easing
            }
        }
        moveDisplaced: Transition {
            NumberAnimation {
                properties: "x,y"
                duration: Theme.animNormal
                easing.type: Theme.easing
            }
        }

        delegate: FavoriteDelegate {
            id: cell
            width: grid.cellWidth
            height: grid.cellHeight
            dragLayer: root
            highlighted: cell.index === root.highlightedIndex

            onLaunched: entry => root.launched(entry)
            onDragStarted: index => {
                root.dragging = true;
                root.dragIndex = index;
            }
            onDragFinished: {
                root.dragging = false;
                root.dragIndex = -1;
                root.commit();
            }
            onHoveredByDrag: index => {
                if (root.dragIndex < 0 || root.dragIndex === index)
                    return;
                favModel.move(root.dragIndex, index, 1);
                root.dragIndex = index;
            }
        }
    }

    EmptyMessage {
        visible: favModel.count === 0
        anchors.centerIn: root
        text: "No favorites yet.\nRight-click an app in All to add it."
    }
}
