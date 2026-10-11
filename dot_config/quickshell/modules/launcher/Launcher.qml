import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "../config"

Scope {
    id: root

    // `qs ipc call launcher toggle` (el atajo de Hyprland usa este).
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            LauncherState.toggle("");
        }

        function open(): void {
            LauncherState.show("");
        }

        function close(): void {
            LauncherState.close();
        }
    }

    // Se crea al abrir y se destruye al cerrar: así cada apertura empieza con
    // la búsqueda vacía y no hay una ventana oculta ocupando memoria.
    LazyLoader {
        active: LauncherState.open

        PanelWindow {
            id: window

            // Quickshell.screens no es un array de JS, así que no tiene find().
            screen: {
                for (const s of Quickshell.screens) {
                    if (s.name === LauncherState.screenName)
                        return s;
                }
                return null;
            }

            // Ocupa la pantalla entera: lo que queda fuera de la tarjeta es la
            // zona de "click fuera para cerrar".
            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }
            exclusionMode: ExclusionMode.Ignore
            color: Colors.overlayDim

            WlrLayershell.layer: WlrLayer.Overlay
            // Exclusivo para que se pueda escribir apenas se abre, sin click.
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            property string tab: LauncherState.favorites.length > 0 ? "favs" : "all"
            property string query: ""
            readonly property bool searching: query.length > 0
            // Mientras se arrastra no se reconstruye el modelo de favoritos:
            // borraría el delegate que se está moviendo.
            property bool dragging: false

            readonly property var apps: DesktopEntries.applications.values.filter(a => !a.noDisplay).sort((a, b) => a.name.localeCompare(b.name))

            // Coincidencias que empiezan por lo escrito van primero: al buscar
            // "fi" se espera Firefox antes que algo que solo lo contiene.
            readonly property var results: {
                if (!searching)
                    return apps;
                const q = query.toLowerCase();
                const matches = apps.filter(a => [a.name, a.genericName].concat(a.keywords).join(" ").toLowerCase().includes(q));
                return matches.filter(a => a.name.toLowerCase().startsWith(q)).concat(matches.filter(a => !a.name.toLowerCase().startsWith(q)));
            }

            readonly property bool showingAll: searching || tab === "all"

            function launch(entry) {
                if (!entry)
                    return;
                // execute() no abre terminal para las apps que la necesitan.
                if (entry.runInTerminal)
                    Quickshell.execDetached(["kitty", "-e"].concat(entry.command));
                else
                    entry.execute();
                LauncherState.close();
            }

            function syncFavorites() {
                if (window.dragging)
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

            function commitFavorites() {
                const ids = [];
                for (let i = 0; i < favModel.count; i++)
                    ids.push(favModel.get(i).appId);
                LauncherState.setFavorites(ids);
            }

            ListModel {
                id: favModel
            }

            Component.onCompleted: syncFavorites()

            Connections {
                target: LauncherState
                function onFavoritesChanged() {
                    window.syncFavorites();
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: LauncherState.close()
            }

            Rectangle {
                id: card
                anchors.centerIn: parent
                width: 620
                height: 470

                color: Colors.panelBackground
                radius: 15
                border.width: 2
                border.color: Colors.panelBorder

                // Entrada suave; al cerrar desaparece de golpe porque el
                // LazyLoader destruye la ventana.
                opacity: 0
                scale: 0.96
                Component.onCompleted: {
                    opacity = 1;
                    scale = 1;
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 140
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 160
                        easing.type: Easing.OutCubic
                    }
                }

                // Se traga los clicks dentro de la tarjeta, para que no lleguen
                // a la zona de cerrar que hay detrás.
                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    // ── Búsqueda ──────────────────────────────────────
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 34
                        radius: 10
                        color: Qt.alpha(Colors.foreground, 0.07)

                        Text {
                            id: searchIcon
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter

                            // nf-fa-search
                            text: "\u{f002}"
                            color: Qt.alpha(Colors.foreground, 0.5)
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 12
                        }

                        TextInput {
                            id: search
                            anchors.left: searchIcon.right
                            anchors.right: parent.right
                            anchors.leftMargin: 10
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter

                            focus: true
                            color: Colors.foreground
                            selectionColor: Qt.alpha(Colors.accent, 0.4)
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 12
                            clip: true

                            onTextChanged: window.query = text

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Escape) {
                                    LauncherState.close();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (window.showingAll)
                                        window.launch(window.results[0]);
                                    else if (favModel.count > 0)
                                        window.launch(DesktopEntries.byId(favModel.get(0).appId));
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Tab) {
                                    window.tab = window.tab === "favs" ? "all" : "favs";
                                    event.accepted = true;
                                }
                            }

                            Text {
                                visible: search.text.length === 0
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Search apps…"
                                color: Qt.alpha(Colors.foreground, 0.35)
                                font: search.font
                            }
                        }
                    }

                    // ── Pestañas ──────────────────────────────────────
                    RowLayout {
                        spacing: 4

                        Repeater {
                            model: [
                                {
                                    id: "favs",
                                    label: "Favorites"
                                },
                                {
                                    id: "all",
                                    label: "All"
                                }
                            ]

                            MouseArea {
                                id: tabButton
                                required property var modelData

                                // Buscando siempre se ve All, así que la pestaña
                                // marcada tiene que reflejarlo.
                                readonly property bool active: modelData.id === "all" ? window.showingAll : !window.showingAll

                                implicitWidth: tabLabel.implicitWidth + 18
                                implicitHeight: 22
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    window.tab = modelData.id;
                                    search.text = "";
                                    search.forceActiveFocus();
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 7
                                    color: tabButton.active ? Qt.alpha(Colors.foreground, 0.14) : tabButton.containsMouse ? Qt.alpha(Colors.foreground, 0.07) : "transparent"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 120
                                        }
                                    }
                                }

                                Text {
                                    id: tabLabel
                                    anchors.centerIn: parent
                                    text: tabButton.modelData.label
                                    color: tabButton.active ? Colors.foreground : Qt.alpha(Colors.foreground, 0.45)
                                    font.family: "JetBrains Mono Nerd Font"
                                    font.pixelSize: 10
                                    font.bold: tabButton.active
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: window.showingAll ? "Right-click: toggle favorite" : "Drag to reorder · Right-click: remove"
                            color: Qt.alpha(Colors.foreground, 0.35)
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 9
                        }
                    }

                    // ── Grillas ───────────────────────────────────────
                    Item {
                        id: gridArea
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        GridView {
                            id: allGrid
                            anchors.fill: parent
                            visible: window.showingAll
                            clip: true

                            cellWidth: Math.floor(width / 6)
                            cellHeight: 88
                            model: window.results
                            boundsBehavior: Flickable.StopAtBounds

                            delegate: MouseArea {
                                id: allDelegate
                                required property var modelData
                                required property int index

                                width: allGrid.cellWidth
                                height: allGrid.cellHeight
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton

                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton)
                                        LauncherState.toggleFavorite(modelData.id);
                                    else
                                        window.launch(modelData);
                                }

                                AppTile {
                                    anchors.fill: parent
                                    entry: allDelegate.modelData
                                    hovered: allDelegate.containsMouse
                                    favorite: LauncherState.favorites.includes(allDelegate.modelData.id)
                                    highlighted: window.searching && allDelegate.index === 0
                                }
                            }
                        }

                        GridView {
                            id: favGrid
                            anchors.fill: parent
                            visible: !window.showingAll
                            clip: true
                            interactive: !window.dragging

                            cellWidth: Math.floor(width / 6)
                            cellHeight: 88
                            model: favModel
                            boundsBehavior: Flickable.StopAtBounds

                            // Los demás iconos se corren con animación al
                            // abrir hueco al que se arrastra.
                            move: Transition {
                                NumberAnimation {
                                    properties: "x,y"
                                    duration: 160
                                    easing.type: Easing.OutCubic
                                }
                            }
                            moveDisplaced: Transition {
                                NumberAnimation {
                                    properties: "x,y"
                                    duration: 160
                                    easing.type: Easing.OutCubic
                                }
                            }

                            delegate: MouseArea {
                                id: favDelegate
                                required property int index
                                required property string appId
                                readonly property var entry: DesktopEntries.byId(appId)
                                // Un arrastre termina con un release, que no
                                // tiene que contar como click y abrir la app.
                                property bool moved: false

                                width: favGrid.cellWidth
                                height: favGrid.cellHeight
                                hoverEnabled: true
                                cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton

                                drag.target: favTile

                                drag.onActiveChanged: {
                                    if (drag.active) {
                                        favDelegate.moved = true;
                                        window.dragging = true;
                                    }
                                }

                                onPressed: favDelegate.moved = false

                                onReleased: {
                                    if (!favDelegate.moved)
                                        return;
                                    window.dragging = false;
                                    window.commitFavorites();
                                }

                                onClicked: mouse => {
                                    if (favDelegate.moved)
                                        return;
                                    if (mouse.button === Qt.RightButton)
                                        LauncherState.toggleFavorite(favDelegate.appId);
                                    else
                                        window.launch(favDelegate.entry);
                                }

                                AppTile {
                                    id: favTile
                                    width: favDelegate.width
                                    height: favDelegate.height
                                    anchors.horizontalCenter: favDelegate.horizontalCenter
                                    anchors.verticalCenter: favDelegate.verticalCenter

                                    entry: favDelegate.entry
                                    hovered: favDelegate.containsMouse || Drag.active
                                    scale: Drag.active ? 1.08 : 1

                                    Drag.active: favDelegate.drag.active
                                    Drag.source: favDelegate
                                    Drag.hotSpot.x: width / 2
                                    Drag.hotSpot.y: height / 2

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 120
                                        }
                                    }

                                    // Al arrastrar se saca del delegate y se sube
                                    // a la grilla: si no, al moverse el modelo el
                                    // icono viajaría con su celda y no con el mouse.
                                    states: State {
                                        when: favTile.Drag.active

                                        ParentChange {
                                            target: favTile
                                            parent: gridArea
                                        }

                                        AnchorChanges {
                                            target: favTile
                                            anchors.horizontalCenter: undefined
                                            anchors.verticalCenter: undefined
                                        }
                                    }
                                }

                                DropArea {
                                    anchors.fill: parent
                                    anchors.margins: 12

                                    onEntered: drag => {
                                        const from = drag.source.index;
                                        const to = favDelegate.index;
                                        if (from !== to)
                                            favModel.move(from, to, 1);
                                    }
                                }
                            }
                        }

                        Text {
                            visible: !window.showingAll && favModel.count === 0
                            anchors.centerIn: parent
                            text: "No favorites yet.\nRight-click an app in All to add it."
                            horizontalAlignment: Text.AlignHCenter
                            color: Qt.alpha(Colors.foreground, 0.4)
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 11
                        }

                        Text {
                            visible: window.searching && window.results.length === 0
                            anchors.centerIn: parent
                            text: "No apps match “" + window.query + "”"
                            color: Qt.alpha(Colors.foreground, 0.4)
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}
