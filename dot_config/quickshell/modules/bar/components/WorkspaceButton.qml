import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Item {
    id: button
    required property int workspaceId
    property color iconColor: "white"
    property real iconSize: 14

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    // Glifos Nerd Font escritos como escapes y no como caracteres literales:
    // pegados en crudo se pierden con facilidad al editar el archivo.
    readonly property var iconMap: [
        {
            // Globo genérico de internet en vez del logo del navegador.
            match: cls => cls === "firefox",
            icon: "\u{f0ac}"
        },
        {
            match: cls => cls === "zen" || cls.startsWith("zen-"),
            icon: "\u{f0ac}"
        },
        {
            match: cls => cls.includes("whatsapp"),
            icon: "\u{f232}"
        },
        {
            match: cls => cls === "org.telegram.desktop",
            icon: "\u{f2c6}"
        },
        {
            match: cls => cls === "ghostty" || cls === "com.mitchellh.ghostty",
            icon: "\u{f11c}"
        },
        {
            match: cls => cls === "kitty",
            icon: "\u{f11c}"
        },
        {
            match: cls => cls.startsWith("steam_app"),
            icon: "\u{f05ba}"
        },
        {
            match: cls => cls === "steam",
            icon: "\u{f1b6}"
        },
        {
            match: cls => cls === "spotify",
            icon: "\u{f1bc}"
        },
        {
            match: cls => cls === "vesktop" || cls === "discord",
            icon: "\u{f1ff}"
        }
    ]
    readonly property string fallbackIcon: "\u{f059}"

    function appIcon(toplevel) {
        const cls = (toplevel.lastIpcObject?.["class"] ?? "").toLowerCase();
        const title = (toplevel.title ?? "").toLowerCase();

        for (const entry of button.iconMap) {
            if (entry.match(cls))
                return entry.icon;
        }

        if (title.includes("steam"))
            return "\u{f1b6}";

        return button.fallbackIcon;
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 4

        Repeater {
            model: Hyprland.toplevels

            delegate: Text {
                required property HyprlandToplevel modelData

                // Se compara por name y no por id: cuando el workspace se
                // descubre a través de un toplevel, Hyprland lo entrega con
                // id = -1 aunque el name sí venga bien.
                visible: modelData.workspace !== null && modelData.workspace.name === String(button.workspaceId)
                // Un delegate invisible no debe ocupar espacio en el layout.
                Layout.preferredWidth: visible ? implicitWidth : 0

                text: modelData.lastIpcObject ? button.appIcon(modelData) : ""
                color: button.iconColor
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: button.iconSize
                font.bold: true
            }
        }
    }
}
