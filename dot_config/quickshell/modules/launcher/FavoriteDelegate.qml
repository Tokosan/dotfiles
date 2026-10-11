import Quickshell
import QtQuick

import "../config"

// Una celda de la grilla de favoritos: click abre, click derecho quita y
// arrastrar reordena. No toca el modelo: avisa con señales y FavoritesGrid
// mueve las filas.
MouseArea {
    id: cell

    required property int index
    required property string appId
    // Dónde se sube el icono mientras se arrastra (ver el State de abajo).
    required property Item dragLayer
    property bool highlighted: false

    readonly property var entry: DesktopEntries.byId(cell.appId)
    // Un arrastre termina con un release, que no tiene que contar como
    // click y abrir la app.
    property bool moved: false

    signal launched(var entry)
    signal dragStarted(int index)
    signal dragFinished
    // Otro icono arrastrado pasó por encima de esta celda.
    signal hoveredByDrag(int index)

    hoverEnabled: true
    cursorShape: cell.drag.active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    drag.target: tile

    drag.onActiveChanged: {
        if (cell.drag.active) {
            cell.moved = true;
            cell.dragStarted(cell.index);
        }
    }

    onPressed: cell.moved = false

    onReleased: {
        if (cell.moved)
            cell.dragFinished();
    }

    onClicked: mouse => {
        if (cell.moved)
            return;
        if (mouse.button === Qt.RightButton)
            LauncherState.toggleFavorite(cell.appId);
        else
            cell.launched(cell.entry);
    }

    AppTile {
        id: tile
        width: cell.width
        height: cell.height
        anchors.horizontalCenter: cell.horizontalCenter
        anchors.verticalCenter: cell.verticalCenter

        entry: cell.entry
        hovered: cell.containsMouse || tile.Drag.active
        highlighted: cell.highlighted
        scale: tile.Drag.active ? 1.08 : 1

        Drag.active: cell.drag.active
        Drag.source: cell
        Drag.hotSpot.x: tile.width / 2
        Drag.hotSpot.y: tile.height / 2

        Behavior on scale {
            NumberAnimation {
                duration: Theme.animFast
            }
        }

        // Al arrastrar se saca de la celda y se sube a dragLayer: si no, al
        // moverse el modelo el icono viajaría con su celda y no con el mouse.
        states: State {
            when: tile.Drag.active

            ParentChange {
                target: tile
                parent: cell.dragLayer
            }

            AnchorChanges {
                target: tile
                anchors.horizontalCenter: undefined
                anchors.verticalCenter: undefined
            }
        }
    }

    DropArea {
        anchors.fill: cell
        anchors.margins: 12
        onEntered: cell.hoveredByDrag(cell.index)
    }
}
