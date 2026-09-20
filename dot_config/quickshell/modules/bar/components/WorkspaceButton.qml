import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Item {
    id: button
    required property int workspaceId
    property color iconColor: "white"

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    function appIcon(toplevel) {
        const cls = (toplevel.lastIpcObject["class"] ?? "").toLowerCase();
        const title = (toplevel.title ?? "").toLowerCase();

        if (cls === "firefox")
            return "";
        if (cls === "zen")
            return "";
        if (cls.startsWith("chrome-web.whatsapp"))
            return "";
        if (cls === "org.telegram.desktop")
            return "t";
        if (cls === "ghostty")
            return "";
        if (cls === "kitty")
            return "";
        if (title.includes("steam"))
            return "";
        if (cls.startsWith("steam_app"))
            return "󰖺";
        if (cls === "steam")
            return "󰖺";
        if (cls === "spotify")
            return "";
        if (cls === "vesktop")
            return "";
        return "";
    }

    RowLayout {
        id: layout
        anchors.fill: parent

        Repeater {
            model: Hyprland.toplevels
            delegate: Text {
                required property HyprlandToplevel modelData
                visible: modelData.workspace !== null && modelData.workspace.id === button.workspaceId
                text: modelData.lastIpcObject ? button.appIcon(modelData) : ""
                color: button.iconColor
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 14
                font.bold: true
            }
        }
    }
}
