import Quickshell
import Quickshell.Io
import QtQuick

import "../../config"
import "../../services"

// Aplica fondos en una pantalla y sabe cuál tiene puesto. No pinta nada: la
// grilla lee `current`, `pending` y `failed` para marcar las miniaturas.
Scope {
    id: applier

    required property string monitor

    // Fondo puesto ahora (ruta o id de scene). Sale del archivo de estado de
    // la pantalla y no del último click: si el script falla, no miente.
    property string current: ""
    // El que el script está aplicando ahora mismo.
    property string pending: ""
    // El último que falló, para teñirlo de rojo hasta el próximo intento.
    property string failed: ""
    // Click hecho mientras el script trabajaba. Sólo se guarda el último:
    // si el usuario hizo varios, el que cuenta es el final.
    property var queued: null

    function apply(entry) {
        if (applyProcess.running) {
            // Antes este click se perdía: `running = true` sobre un proceso
            // vivo no hace nada.
            applier.queued = entry;
            return;
        }
        applier.pending = entry.path;
        // El rojo se quita sólo al reintentar ese mismo fondo: si lo borrara
        // cualquier click, un click encolado lo haría desaparecer al instante.
        if (applier.failed === entry.path)
            applier.failed = "";
        // setsid -f -w: el script corre en su propia sesión y sobrevive si se
        // cierra la vista (al destruirse, el Process mata a su hijo y dejaría
        // el cambio a medias); -w espera y devuelve su código de salida. "--"
        // evita que una ruta que empiece con "-" se lea como opción.
        applyProcess.command = ["setsid", "-f", "-w", Settings.wallpaperScript, "--monitor", applier.monitor, "--wal", "--lock-file", "--", entry.path];
        applyProcess.running = true;
    }

    // Sólo mira el código: si el script muere por una señal, setsid sale
    // con != 0 igual.
    function finish(exitCode) {
        if (exitCode === 0) {
            Sounds.play("strong");
            // Si el archivo no existía, watchChanges no lo estaba siguiendo:
            // se relee a mano.
            stateFile.reload();
        } else {
            applier.failed = applier.pending;
        }
        applier.pending = "";

        if (applier.queued !== null) {
            const next = applier.queued;
            applier.queued = null;
            applier.apply(next);
        }
    }

    function readState() {
        // "image <ruta>", "video <ruta>" o "scene <id>". La ruta puede llevar
        // espacios: se corta sólo en el primero.
        const line = stateFile.text().trim();
        const space = line.indexOf(" ");
        applier.current = space > 0 ? line.slice(space + 1) : "";
    }

    Process {
        id: applyProcess

        // Conectado a mano y no con onExited: qmllint no conoce el tipo
        // QProcess::ExitStatus del segundo parámetro de `exited` y avisa en
        // cualquier handler declarado.
        Component.onCompleted: applyProcess.exited.connect(applier.finish)
    }

    // La fuente de verdad del fondo de esta pantalla la escriben los scripts
    // de wallpaper. Se vigila, así que un cambio hecho desde el teclado o
    // desde la barra de otra pantalla también se ve aquí.
    FileView {
        id: stateFile
        path: `${Settings.wallpaperStateDir}/${applier.monitor}`
        watchChanges: true
        // Una pantalla en la que nunca se cambió el fondo no tiene archivo; no
        // es un error que valga la pena llevar al log.
        printErrors: false
        onFileChanged: stateFile.reload()
        onLoaded: applier.readState()
        onLoadFailed: applier.current = ""
    }
}
