pragma Singleton

import Quickshell
import QtQuick

// Chime de feedback compartido por toda la shell.
//
// Cada sonido es un `pw-play` corto e independiente, NO un SoundEffect de
// QtMultimedia. SoundEffect deja un stream abierto pegado a la salida por
// defecto; si esa salida desaparece (p. ej. unos audífonos Bluetooth que se
// apagan), el backend de Qt entra en un bucle de
// "QSocketNotifier: Invalid socket" que escribe cientos de miles de líneas
// por segundo en el log (tmpfs) hasta llenar /run/user. Reproducido el
// 2026-10-10 quitando un sink con `pactl unload-module`. No volver a usar
// SoundEffect ni MediaPlayer para esto.
Singleton {
    id: root

    readonly property string chimePath: Quickshell.shellPath("assets/chime.wav")

    // El volumen sigue el peso de la acción: cambiar de pestaña pesa menos
    // que aplicar un fondo.
    readonly property var volumes: ({
            "subtle": 0.18,   // cambiar de pestaña
            "soft": 0.25,     // entrar a una sub-vista
            "normal": 0.35,   // botón de la estrella
            "strong": 0.4     // aplicar algo (wallpaper)
        })

    function play(weight) {
        const volume = root.volumes[weight] ?? root.volumes.normal;
        Quickshell.execDetached(["pw-play", "--volume", String(volume), root.chimePath]);
    }
}
