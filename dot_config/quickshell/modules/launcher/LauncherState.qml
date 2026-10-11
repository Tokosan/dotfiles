pragma Singleton

import Quickshell
import Quickshell.Hyprland
import QtQuick

// Estado compartido del launcher: si está abierto, en qué pantalla y la lista
// de favoritos. Es singleton para que la barra pueda abrirlo sin tener una
// referencia a la ventana.
Singleton {
    id: root

    property bool open: false
    // Pantalla donde se muestra. Se fija al abrir y no sigue al foco: si
    // cambiara con el launcher abierto, la ventana saltaría de monitor.
    property string screenName: ""

    // Ids de los .desktop, en el orden elegido por el usuario. Se cambia con
    // setFavorites/toggleFavorite/reorderFavorites, que además lo guardan.
    readonly property alias favorites: store.favorites

    function show(screenName) {
        root.screenName = screenName || (Hyprland.focusedMonitor?.name ?? "");
        root.open = true;
    }

    function close() {
        root.open = false;
    }

    function toggle(screenName) {
        if (root.open)
            root.close();
        else
            root.show(screenName);
    }

    function isFavorite(id) {
        return root.favorites.includes(id);
    }

    function toggleFavorite(id) {
        if (root.isFavorite(id))
            root.setFavorites(root.favorites.filter(f => f !== id));
        else
            root.setFavorites(root.favorites.concat([id]));
    }

    // Aplica el orden nuevo de los favoritos que se ven en la grilla. Los
    // que no se ven (app desinstalada, disco sin montar) conservan su hueco:
    // guardar solo la lista visible los borraría del archivo para siempre.
    function reorderFavorites(visibleOrder) {
        const visible = new Set(visibleOrder);
        let next = 0;
        root.setFavorites(root.favorites.map(id => visible.has(id) ? visibleOrder[next++] : id));
    }

    function setFavorites(list) {
        store.save(list);
    }

    FavoritesStore {
        id: store
    }
}
