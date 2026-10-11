pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "../../config"

// Iconos de las ventanas abiertas en un workspace.
Item {
    id: button
    required property int workspaceId
    property color iconColor: Colors.workspaceIdle
    property real iconSize: Theme.fontLg

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    // Para agregar una app: una entrada más con su match y su glifo.
    // El primero que coincide gana, así que lo específico va antes.
    // `cls` es la clase de la ventana en minúsculas; `title`, su título.
    // Glifos Nerd Font escritos como escapes y no como caracteres literales:
    // pegados en crudo se pierden con facilidad al editar el archivo.
    readonly property var iconMap: [
        {
            // Globo genérico de internet en vez del logo del navegador.
            match: (cls, title) => cls === "firefox",
            icon: "\u{f0ac}"
        },
        {
            match: (cls, title) => cls === "zen" || cls.startsWith("zen-"),
            icon: "\u{f0ac}"
        },
        {
            // Chromium a secas; las web apps (chrome-*) se resuelven por su
            // propio sitio más abajo.
            match: (cls, title) => cls === "chromium" || cls === "chromium-browser" || cls === "google-chrome",
            icon: "\u{f0ac}"
        },
        {
            match: (cls, title) => cls.includes("whatsapp"),
            icon: "\u{f232}"
        },
        {
            match: (cls, title) => cls === "org.telegram.desktop",
            icon: "\u{f2c6}"
        },
        {
            match: (cls, title) => cls === "ghostty" || cls === "com.mitchellh.ghostty",
            icon: "\u{f11c}"
        },
        {
            match: (cls, title) => cls === "kitty",
            icon: "\u{f11c}"
        },
        {
            // Juegos de steam (proton) y ejecutables nativos: valheim.x86_64,
            // algo.exe y similares suelen ser juegos lanzados fuera de proton.
            match: (cls, title) => cls.startsWith("steam_app") || cls.endsWith(".x86_64") || cls.endsWith(".x86") || cls.endsWith(".exe") || cls.endsWith(".bin"),
            icon: "\u{f05ba}"
        },
        {
            // El cliente de Steam a veces llega sin clase útil: se reconoce
            // también por el título.
            match: (cls, title) => cls === "steam" || title.includes("steam"),
            icon: "\u{f1b6}"
        },
        {
            // Incluye la web app de Chrome (chrome-spotify.com__-Default).
            match: (cls, title) => cls.includes("spotify"),
            icon: "\u{f1bc}"
        },
        {
            match: (cls, title) => cls === "vesktop" || cls === "discord",
            icon: "\u{f1ff}"
        }
    ]
    // nf-fa-question_circle
    readonly property string fallbackIcon: "\u{f059}"

    function appIcon(toplevel) {
        // appId llega apenas se abre la ventana. lastIpcObject solo se llena
        // al refrescar los toplevels (al arrancar), así que una ventana nueva
        // se quedaba sin icono hasta reiniciar la config.
        const cls = (toplevel.wayland?.appId || toplevel.lastIpcObject?.["class"] || "").toLowerCase();
        const title = (toplevel.title ?? "").toLowerCase();

        for (const entry of button.iconMap) {
            if (entry.match(cls, title))
                return entry.icon;
        }
        return button.fallbackIcon;
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 4

        // Solo las ventanas de este workspace. Se compara por name y no por
        // id: un workspace descubierto vía toplevel llega con id = -1.
        Repeater {
            model: ScriptModel {
                values: Hyprland.toplevels.values.filter(t => t.workspace?.name === String(button.workspaceId))
            }

            delegate: Text {
                id: appGlyph
                required property HyprlandToplevel modelData

                text: appGlyph.modelData.wayland || appGlyph.modelData.lastIpcObject ? button.appIcon(appGlyph.modelData) : ""
                color: button.iconColor
                font.family: Theme.fontFamily
                font.pixelSize: button.iconSize
                font.bold: true
            }
        }
    }
}
