import Quickshell
import Quickshell.Io
import QtQuick

// Punto de entrada del launcher: el handler de IPC y la ventana bajo demanda.
// La ventana y sus piezas están en LauncherWindow.qml; el estado (abierto,
// pantalla, favoritos) en LauncherState.qml.
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

        LauncherWindow {}
    }
}
