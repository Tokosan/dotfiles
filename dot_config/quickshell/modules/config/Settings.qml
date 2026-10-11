pragma Singleton

import Quickshell
import QtQuick

// Preferencias del usuario que no son de estilo: qué hay en la barra, qué
// programas se usan, cada cuánto se refresca. Es el primer sitio donde mirar
// para "cambiar X" sin tocar componentes.
Singleton {
    id: root

    // Grupos de workspaces de la barra, en orden. Tiene que coincidir con el
    // reparto de hypr/windows.lua y waybar: DP-1 lleva 1-5 y HDMI-A-1 6-10.
    // Hoy las dos barras muestran los dos grupos.
    readonly property var workspaceGroups: [[1, 2, 3, 4, 5], [6, 7, 8, 9, 10]]

    // Terminal para las apps con Terminal=true del launcher.
    readonly property var terminalCommand: ["kitty", "-e"]

    // Cada cuánto se leen CPU, RAM y temperaturas (ms).
    readonly property int statsInterval: 2000

    // Volumen que cambia cada paso de la rueda (0-1).
    readonly property real volumeStep: 0.05

    // Wallpapers.
    readonly property string home: Quickshell.env("HOME")
    readonly property string wallpaperDir: `${home}/media/images/wallpapers/unsorted`
    readonly property string videoWallpaperDir: `${home}/media/videos/wallpapers`
    readonly property string wallpaperThumbDir: `${home}/.cache/wallpaper-thumbs`
    // Script que aplica un fondo (imagen, vídeo o id de scene). Vive en el
    // repo en bin/executable_change-wallpaper.sh.
    readonly property string wallpaperScript: `${home}/bin/change-wallpaper.sh`
    // Último fondo de cada pantalla, que escriben los scripts de wallpaper:
    // <dir>/<monitor> con "image <ruta>", "video <ruta>" o "scene <id>".
    readonly property string wallpaperStateDir: `${Quickshell.env("XDG_STATE_HOME") || home + "/.local/state"}/wallpaper`
}
