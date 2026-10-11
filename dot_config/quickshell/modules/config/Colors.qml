pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Tema de colores. Los widgets usan SOLO los roles semánticos de abajo, nunca
// colorN ni hex sueltos. Si hace falta un color nuevo, se agrega aquí como rol.
Singleton {
    id: root

    // colors.json de pywal, ya parseado. Se rellena al cargar el archivo.
    property var parsed: ({})

    // Devuelve el color de pywal si es un hex válido; si no, el fallback. Sin
    // esto, un valor raro en el JSON dejaría la propiedad en negro.
    function pick(value, fallback) {
        return typeof value === "string" && /^#[0-9a-fA-F]{6}$/.test(value) ? value : fallback;
    }

    // ── Paleta base (pywal, con fallback Catppuccin) ──────────────────
    // Estos bindings referencian root.parsed directamente para que QML los
    // re-evalúe cuando el archivo se recarga.
    readonly property color background: root.pick(root.parsed.special?.background, "#1e1e2e")
    readonly property color foreground: root.pick(root.parsed.special?.foreground, "#cdd6f4")

    readonly property color color0: root.pick(root.parsed.colors?.color0, "#1e1e2e")
    readonly property color color1: root.pick(root.parsed.colors?.color1, "#f38ba8")
    readonly property color color2: root.pick(root.parsed.colors?.color2, "#a6e3a1")
    readonly property color color3: root.pick(root.parsed.colors?.color3, "#f9e2af")
    readonly property color color4: root.pick(root.parsed.colors?.color4, "#89b4fa")
    readonly property color color5: root.pick(root.parsed.colors?.color5, "#cba6f7")
    readonly property color color6: root.pick(root.parsed.colors?.color6, "#94e2d5")
    readonly property color color7: root.pick(root.parsed.colors?.color7, "#bac2de")
    readonly property color color8: root.pick(root.parsed.colors?.color8, "#585b70")

    // ── Señales fijas ─────────────────────────────────────────────────
    // No salen de pywal: la paleta del wallpaper no garantiza un rojo o un
    // verde reconocibles y la señal se perdería.
    readonly property color alert: "#f38ba8"      // mute, confirmaciones peligrosas
    readonly property color accent: "#a6e3a1"     // hover, elemento activo
    // Fondo de un aviso con texto en `alert` (p. ej. launcher.json ilegible):
    // tenue para que el texto rojo se lea sobre él.
    readonly property color alertSurface: Qt.alpha(root.alert, 0.15)

    // ── Texto ─────────────────────────────────────────────────────────
    readonly property color text: root.foreground
    readonly property color textSecondary: Qt.alpha(root.foreground, 0.65)  // detalles, porcentajes
    readonly property color textMuted: Qt.alpha(root.foreground, 0.45)      // cabeceras, pestaña inactiva
    readonly property color textFaint: Qt.alpha(root.foreground, 0.35)      // pistas, mensajes vacíos
    readonly property color textDisabled: Qt.alpha(root.foreground, 0.3)    // entradas sin implementar

    // ── Superficies ───────────────────────────────────────────────────
    // Opaca: sin blur del compositor detrás, cualquier transparencia deja
    // asomar el wallpaper y ensucia la lectura.
    readonly property color barBackground: root.background
    readonly property color panelBackground: root.background
    readonly property color panelBorder: Qt.alpha(root.foreground, 0.38)
    readonly property color panelShadow: "#000000"
    // Velo detrás de los paneles a pantalla completa (launcher).
    readonly property color overlayDim: Qt.alpha("#000000", 0.35)

    readonly property color surfaceSubtle: Qt.alpha(root.foreground, 0.07)    // campo de búsqueda, hover suave
    readonly property color surfaceHover: Qt.alpha(root.foreground, 0.1)      // fila de menú bajo el mouse
    readonly property color surfaceSelected: Qt.alpha(root.foreground, 0.14)  // pestaña activa
    readonly property color surfaceRaised: Qt.alpha(root.foreground, 0.12)    // fondo de pill de stat, tile hover
    readonly property color divider: Qt.alpha(root.foreground, 0.12)
    readonly property color focusRing: Qt.alpha(root.accent, 0.6)
    readonly property color selection: Qt.alpha(root.accent, 0.4)

    // Distintivo sobre miniaturas (p. ej. "VIDEO"): fijo para leerse sobre
    // cualquier imagen.
    readonly property color badgeBackground: Qt.alpha("#000000", 0.55)
    readonly property color badgeForeground: "#ffffff"

    // ── Sliders ───────────────────────────────────────────────────────
    readonly property color sliderTrack: Qt.alpha(root.foreground, 0.18)
    readonly property color sliderFill: root.color4

    // ── Workspaces ────────────────────────────────────────────────────
    readonly property color workspaceIdle: Qt.alpha(root.foreground, 0.85)
    readonly property color workspaceActive: root.foreground
    // Intercambiados: el enfocado lleva el tono claro y el hover el base.
    readonly property color workspaceActiveBg: Qt.lighter(root.color4, 1.45)
    readonly property color workspaceHoverBg: root.color4
    // Un workspace vacío es un círculo sólido, no un hueco.
    readonly property color workspaceEmptyBg: Qt.alpha(root.color4, 0.55)

    // ── Carga (CPU/RAM/GPU) ───────────────────────────────────────────
    // Mismos tramos que waybar. Fijos: verde/amarillo/rojo tiene que leerse
    // igual con cualquier wallpaper.
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

    // Texto sobre una pill de carga: oscuro desde el primer tramo con relleno
    // claro (mismo umbral que loadColor).
    function loadTextColor(pct) {
        return pct >= 50 ? root.loadTextOnFill : root.foreground;
    }

    function load() {
        const raw = walFile.text();
        if (!raw)
            return;
        try {
            root.parsed = JSON.parse(raw);
        } catch (e) {
            // Típico mientras pywal está escribiendo: se conserva la paleta
            // anterior y el siguiente fileChanged la corrige.
            console.warn("Colors: no se pudo parsear colors.json:", e);
        }
    }

    FileView {
        id: walFile
        path: `${Quickshell.env("HOME")}/.cache/wal/colors.json`
        preload: true
        // Sigue el wallpaper: al cambiar pywal, la barra se recolorea sola.
        watchChanges: true
        onFileChanged: walFile.reload()
        onLoaded: root.load()
    }
}
