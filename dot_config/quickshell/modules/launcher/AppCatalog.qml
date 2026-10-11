pragma Singleton

import Quickshell
import QtQuick

import "../config"

// Apps instaladas: la lista visible, la búsqueda y cómo se lanza cada una.
// Vive aparte de la ventana para poder cambiar el ranking o el arranque sin
// tocar la UI, y para no recalcular la lista en cada apertura.
Singleton {
    id: root

    readonly property var apps: DesktopEntries.applications.values.filter(a => !a.noDisplay).sort((a, b) => a.name.localeCompare(b.name))

    // Coincidencias que empiezan por lo escrito van primero: al buscar "fi"
    // se espera Firefox antes que algo que solo lo contiene.
    function search(query) {
        if (!query)
            return root.apps;
        const q = query.toLowerCase();
        const matches = root.apps.filter(a => [a.name, a.genericName].concat(a.keywords).join(" ").toLowerCase().includes(q));
        const prefix = matches.filter(a => a.name.toLowerCase().startsWith(q));
        const rest = matches.filter(a => !a.name.toLowerCase().startsWith(q));
        return prefix.concat(rest);
    }

    function launch(entry) {
        if (!entry)
            return;
        if (!entry.runInTerminal) {
            entry.execute();
            return;
        }
        // execute() no abre terminal para las apps que la necesitan, así que
        // se envuelve el comando con la terminal de Settings. El Path= del
        // .desktop se respeta a mano por la misma razón.
        const context = {
            command: Settings.terminalCommand.concat(entry.command)
        };
        if (entry.workingDirectory)
            context.workingDirectory = entry.workingDirectory;
        Quickshell.execDetached(context);
    }
}
