pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // colors.json de pywal, ya parseado. Se rellena al cargar el archivo.
    property var parsed: ({})

    // Fallback (Catppuccin) por si pywal no ha corrido todavía.
    // Nota: estos bindings referencian root.parsed directamente para que QML
    // los re-evalúe cuando el archivo se recarga (un readonly con llamada a
    // función se evaluaría una sola vez y quedaría pegado en el fallback).
    readonly property color background: root.parsed.special?.background ?? "#1e1e2e"
    readonly property color foreground: root.parsed.special?.foreground ?? "#cdd6f4"

    readonly property color color0: root.parsed.colors?.color0 ?? "#1e1e2e"
    readonly property color color1: root.parsed.colors?.color1 ?? "#f38ba8"
    readonly property color color2: root.parsed.colors?.color2 ?? "#a6e3a1"
    readonly property color color3: root.parsed.colors?.color3 ?? "#f9e2af"
    readonly property color color4: root.parsed.colors?.color4 ?? "#89b4fa"
    readonly property color color5: root.parsed.colors?.color5 ?? "#cba6f7"
    readonly property color color6: root.parsed.colors?.color6 ?? "#94e2d5"
    readonly property color color7: root.parsed.colors?.color7 ?? "#bac2de"
    readonly property color color8: root.parsed.colors?.color8 ?? "#585b70"

    // Roles semánticos: los widgets usan estos, no los colorN.
    readonly property color barBackground: Qt.alpha(root.background, 0.85)
    readonly property color workspaceIdle: Qt.alpha(root.foreground, 0.55)
    readonly property color workspaceActive: root.foreground
    readonly property color workspaceActiveBg: root.color4
    readonly property color workspaceHoverBg: Qt.alpha(root.foreground, 0.15)

    // Alerta (mute). Es un rojo fijo y no un colorN de pywal: la paleta del
    // wallpaper no garantiza un rojo (hoy color1 es verde) y se perdería la
    // señal.
    readonly property color alert: "#f38ba8"

    // Relleno de carga de las pills de sistema, con los mismos tramos que
    // waybar. Son fijos y no de pywal: el código de color verde/amarillo/rojo
    // tiene que leerse igual con cualquier wallpaper.
    readonly property color loadLow: "#a6e3a1"
    readonly property color loadMid: "#f9e2af"
    readonly property color loadHigh: "#fab387"
    readonly property color loadCritical: "#f38ba8"
    // Texto sobre el relleno claro.
    readonly property color loadTextOnFill: "#11111b"

    function loadColor(pct) {
        if (pct < 50)
            return root.loadLow;
        if (pct < 65)
            return root.loadMid;
        if (pct < 80)
            return root.loadHigh;
        return root.loadCritical;
    }
    // Un workspace vacío es un círculo sólido, no un hueco.
    readonly property color workspaceEmptyBg: Qt.alpha(root.color4, 0.55)

    function load() {
        const raw = walFile.text();
        if (!raw)
            return;
        try {
            root.parsed = JSON.parse(raw);
        } catch (e) {
            console.warn("Colors: no se pudo parsear colors.json:", e);
        }
    }

    FileView {
        id: walFile
        path: `${Quickshell.env("HOME")}/.cache/wal/colors.json`
        preload: true
        // Sigue el wallpaper: al cambiar pywal, la barra se recolorea sola.
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load()
    }
}
