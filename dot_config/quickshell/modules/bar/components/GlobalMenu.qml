import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../config"

Rectangle {
    id: menu

    // "menu" muestra las opciones; "wallpaper" reemplaza el panel por la
    // grilla de miniaturas.
    property string view: "menu"

    property real padding: 10
    property real radiusValue: 15

    implicitWidth: view === "wallpaper" ? 420 : view === "apps" ? 360 : 230
    implicitHeight: (view === "wallpaper" ? wallpaperView.implicitHeight : view === "apps" ? appsView.implicitHeight : menuView.implicitHeight) + padding * 2

    color: Colors.panelBackground
    radius: radiusValue
    border.width: 2
    border.color: Colors.panelBorder

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutCubic
        }
    }

    signal closed

    function reset() {
        menu.view = "menu";
    }

    // ── Vista: lista de opciones ──────────────────────────────────────
    ColumnLayout {
        id: menuView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: menu.padding

        visible: menu.view === "menu"
        spacing: 2

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f009}"
            label: "Apps"
            onTriggered: menu.view = "apps"
        }

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f03e}"
            label: "Style"
            onTriggered: menu.view = "wallpaper"
        }

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f030}"
            label: "Capture"
            enabled: false
        }

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f013}"
            label: "Setup"
            enabled: false
        }

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f019}"
            label: "Install"
            enabled: false
        }

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f011}"
            label: "System"
            enabled: false
        }
    }

    // ── Vista: lanzador de aplicaciones ───────────────────────────────
    AppLauncher {
        id: appsView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: menu.padding

        visible: menu.view === "apps"
        onBack: menu.view = "menu"
        onLaunched: menu.closed()
    }

    // ── Vista: grilla de wallpapers ───────────────────────────────────
    WallpaperGrid {
        id: wallpaperView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: menu.padding

        visible: menu.view === "wallpaper"
        onBack: menu.view = "menu"
    }
}
