import Quickshell
import Quickshell.Io
import QtQuick

// Lee y guarda launcher.json. LauncherState solo ve `favorites` y save(); el
// formato del archivo y la migración quedan aquí.
Scope {
    id: store

    // Ruta fija y no Quickshell.statePath(): esa cuelga del id de la shell,
    // que sale de la ruta de la config, así que mover la config o probar una
    // copia (check.sh, otro worktree) dejaba los favoritos atrás. Va fuera del
    // repo a propósito: cambia en cada reordenamiento y chezmoi lo pisaría.
    readonly property string path: `${Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state"}/quickshell/launcher.json`
    // Donde lo guardaban las versiones anteriores. Solo se lee para migrar.
    readonly property string legacyPath: Quickshell.statePath("launcher.json")

    // Ids de los .desktop, en el orden elegido por el usuario.
    property var favorites: []

    function save(list) {
        store.favorites = list;
        file.setText(JSON.stringify({
            favorites: list
        }, null, 2));
    }

    // Devuelve false si el texto no se pudo interpretar.
    function parse(text) {
        try {
            const data = JSON.parse(text);
            if (Array.isArray(data.favorites))
                store.favorites = data.favorites;
            return true;
        } catch (e) {
            console.warn("FavoritesStore: no se pudo leer launcher.json:", e);
            return false;
        }
    }

    FileView {
        id: file
        path: store.path
        preload: true
        // Escribe a un temporal y lo renombra: un corte a mitad de guardado no
        // deja un JSON a medias.
        atomicWrites: true
        // Si el archivo cambia por fuera (editado a mano, otra instancia), se
        // relee. Las escrituras propias también disparan esto; releer el
        // mismo contenido no cambia nada.
        watchChanges: true
        onFileChanged: file.reload()
        // Que no exista es lo normal la primera vez; no ensuciar el log.
        printErrors: false

        onLoaded: store.parse(file.text())
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                legacy.path = store.legacyPath;
            else
                console.warn("FavoritesStore: no se pudo abrir launcher.json:", FileViewError.toString(error));
        }
    }

    // Migración única desde la ruta vieja: solo se mira si la nueva no existe,
    // y al copiar la nueva ya existe, así que no vuelve a pasar. El archivo
    // viejo se deja donde está como respaldo.
    FileView {
        id: legacy
        // Vacío hasta que haga falta, para no leerlo en cada arranque.
        path: ""
        printErrors: false

        onLoaded: {
            if (store.parse(legacy.text()))
                store.save(store.favorites);
        }
    }
}
