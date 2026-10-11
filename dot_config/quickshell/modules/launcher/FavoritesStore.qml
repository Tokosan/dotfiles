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
    // Aviso para la UI cuando el archivo no se pudo usar; vacío si todo bien.
    property string problem: ""
    // false mientras el archivo en disco sea ilegible y no tenga copia:
    // guardar encima perdería los favoritos que el usuario quizá pueda
    // recuperar a mano.
    property bool writable: true

    // Versión del formato que escribe esta config. Al cambiar el formato: subir
    // este número y agregar el paso de conversión en normalize().
    readonly property int schemaVersion: 1

    function save(list) {
        store.favorites = list;
        if (!store.writable) {
            console.warn("FavoritesStore: launcher.json ilegible y sin copia; no se guarda.");
            return;
        }
        file.setText(JSON.stringify({
            version: store.schemaVersion,
            favorites: list
        }, null, 2));
    }

    // Lleva cualquier versión conocida al formato actual y limpia lo que no
    // sirve (ids que no son texto, repetidos). Lanza si no se puede usar.
    function normalize(data) {
        if (typeof data !== "object" || data === null || Array.isArray(data))
            throw new Error("not a JSON object");
        // Sin "version" es el formato original: { favorites: [...] }.
        const version = data.version ?? 0;
        // Uno más nuevo lo escribió otra versión de la config; reescribirlo
        // con este código perdería lo que no entiende.
        if (version > store.schemaVersion)
            throw new Error(`version ${version} is newer than ${store.schemaVersion}`);

        // Punto de migración. v0 -> v1 solo agregó el número, no hay nada
        // que convertir. Un cambio futuro va aquí: if (version < 2) { ... }

        const raw = Array.isArray(data.favorites) ? data.favorites : [];
        const ids = raw.filter(id => typeof id === "string" && id !== "");
        return {
            version: store.schemaVersion,
            favorites: ids.filter((id, i) => ids.indexOf(id) === i)
        };
    }

    // Devuelve false si el texto no se pudo interpretar.
    function parse(text) {
        try {
            store.favorites = store.normalize(JSON.parse(text)).favorites;
            // Si estaba bloqueado y ahora se lee bien (arreglado a mano),
            // sobrescribirlo ya no pierde nada.
            if (!store.writable) {
                store.writable = true;
                store.problem = "";
            }
            return true;
        } catch (e) {
            console.warn("FavoritesStore: no se pudo leer launcher.json:", e);
            return false;
        }
    }

    // El archivo existe pero no sirve: se aparta una copia antes de permitir
    // que el próximo guardado lo reemplace.
    function quarantine() {
        store.writable = false;
        backup.running = true;
    }

    function dismissProblem() {
        store.problem = "";
    }

    Process {
        id: backup
        // numbered: si vuelve a pasar, no pisa la copia anterior (.bak.~1~).
        command: ["cp", "--backup=numbered", "--", store.path, store.path + ".bak"]
    }

    // En Connections y no como onExited: qmllint no conoce el tipo del segundo
    // parámetro (QProcess::ExitStatus) y avisa en el handler directo.
    Connections {
        target: backup
        function onExited(exitCode) {
            if (exitCode === 0) {
                store.writable = true;
                store.problem = "launcher.json was unreadable. Saved a copy as launcher.json.bak.";
            } else {
                store.problem = "launcher.json is unreadable and could not be backed up. Favorites won't be saved.";
            }
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

        onLoaded: {
            const text = file.text();
            // Vacío no tiene nada que salvar: se trata como sin favoritos.
            if (text.trim() === "")
                store.favorites = [];
            else if (!store.parse(text))
                store.quarantine();
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound) {
                legacy.path = store.legacyPath;
            } else {
                // Sin permiso de lectura tampoco se puede copiar: solo bloquear.
                console.warn("FavoritesStore: no se pudo abrir launcher.json:", FileViewError.toString(error));
                store.writable = false;
                store.problem = "launcher.json can't be read. Favorites won't be saved.";
            }
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
