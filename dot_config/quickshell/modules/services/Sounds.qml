pragma Singleton

import Quickshell
import QtQuick
import QtMultimedia

// Chime de feedback compartido por toda la shell. Un solo SoundEffect en vez
// de uno por componente y por barra: cada instancia abre su propio decoder, y
// tener varios coincidió con el bucle de "QSocketNotifier: Invalid socket"
// que llenó /run/user tras un error de PipeWire (ver CLAUDE.md).
Singleton {
    id: root

    // El volumen sigue el peso de la acción: cambiar de pestaña pesa menos
    // que aplicar un fondo.
    readonly property var volumes: ({
            "subtle": 0.18,   // cambiar de pestaña
            "soft": 0.25,     // entrar a una sub-vista
            "normal": 0.35,   // botón de la estrella
            "strong": 0.4     // aplicar algo (wallpaper)
        })

    function play(weight) {
        chime.volume = root.volumes[weight] ?? root.volumes.normal;
        chime.play();
    }

    SoundEffect {
        id: chime
        source: Qt.resolvedUrl("../../assets/chime.wav")
    }
}
