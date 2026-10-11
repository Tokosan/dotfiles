import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

import "../config"
import "../common"

// Ventana del launcher: velo a pantalla completa con la tarjeta centrada.
// Orquesta las piezas (búsqueda, pestañas, grillas) y guarda el estado que
// solo vive mientras está abierta: pestaña y texto buscado.
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

    // Ocupa la pantalla entera: lo que queda fuera de la tarjeta es la zona
    // de "click fuera para cerrar".
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
    readonly property string query: search.text
    readonly property bool searching: window.query.length > 0
    // Buscando siempre se ve All, sea cual sea la pestaña elegida.
    readonly property bool showingAll: window.searching || window.tab === "all"
    readonly property var results: AppCatalog.search(window.query)

    function launch(entry) {
        AppCatalog.launch(entry);
        LauncherState.close();
    }

    function selectTab(id) {
        window.tab = id;
        search.clear();
    }

    MouseArea {
        anchors.fill: window.contentItem
        onClicked: LauncherState.close()
    }

    Panel {
        id: card
        anchors.centerIn: window.contentItem
        implicitWidth: Theme.launcherWidth
        implicitHeight: Theme.launcherHeight
        width: card.implicitWidth

        // Entrada suave (Panel anima la opacidad al pasar open a true); al
        // cerrar desaparece de golpe porque el LazyLoader destruye la ventana.
        open: false
        scale: card.open ? 1 : 0.96
        Component.onCompleted: card.open = true

        Behavior on scale {
            NumberAnimation {
                duration: Theme.animNormal
                easing.type: Theme.easing
            }
        }

        // Se traga los clicks dentro de la tarjeta, para que no lleguen a la
        // zona de cerrar que hay detrás.
        MouseArea {
            anchors.fill: card
        }

        ColumnLayout {
            anchors.fill: card
            anchors.margins: Theme.panelPadding
            spacing: 10

            SearchField {
                id: search
                Layout.fillWidth: true

                onEscapePressed: LauncherState.close()
                onAcceptPressed: {
                    if (window.showingAll)
                        allGrid.activate(0);
                    else
                        favGrid.activate(0);
                }
                onTabPressed: window.tab = window.tab === "favs" ? "all" : "favs"
            }

            RowLayout {
                Layout.fillWidth: true

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
                    current: window.showingAll ? "all" : "favs"
                    onSelected: id => window.selectTab(id)
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: window.showingAll ? "Right-click: toggle favorite" : "Drag to reorder · Right-click: remove"
                    color: Colors.textFaint
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontXs
                }
            }

            Item {
                id: gridArea
                Layout.fillWidth: true
                Layout.fillHeight: true

                AllAppsGrid {
                    id: allGrid
                    anchors.fill: gridArea
                    visible: window.showingAll
                    apps: window.results
                    query: window.query
                    highlightedIndex: window.searching ? 0 : -1
                    onLaunched: entry => window.launch(entry)
                }

                FavoritesGrid {
                    id: favGrid
                    anchors.fill: gridArea
                    visible: !window.showingAll
                    onLaunched: entry => window.launch(entry)
                }
            }
        }
    }
}
