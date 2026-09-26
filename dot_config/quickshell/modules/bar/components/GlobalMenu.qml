import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtMultimedia

import "../../config"

Rectangle {
    id: menu

    // La pantalla de la barra que contiene este menú, para que el selector de
    // wallpapers sepa dónde aplicar.
    required property string monitor

    // "menu" muestra las opciones; "wallpaper" reemplaza el panel por la
    // grilla de miniaturas.
    property string view: "menu"

    property real padding: 10
    property real radiusValue: 15

    implicitWidth: view === "wallpaper" ? 420 : 210
    implicitHeight: (view === "wallpaper" ? wallpaperView.implicitHeight : menuView.implicitHeight) + padding * 2

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
            icon: "\u{f03e}"
            label: "Wallpaper"
            onTriggered: {
                menu.view = "wallpaper";
                enterSound.play();
            }
        }

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f030}"
            label: "Screenshot"
            enabled: false
        }

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f002}"
            label: "Launcher"
            enabled: false
        }

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f021}"
            label: "Restart Hyprland"
            enabled: false
        }

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f011}"
            label: "Power off"
            enabled: false
        }
    }

    // Mismo chime que el botón de la estrella, más suave.
    SoundEffect {
        id: enterSound
        source: Qt.resolvedUrl("../../../assets/chime.wav")
        volume: 0.25
    }

    // ── Vista: grilla de wallpapers ───────────────────────────────────
    WallpaperGrid {
        id: wallpaperView
        monitor: menu.monitor
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: menu.padding

        visible: menu.view === "wallpaper"
        onBack: menu.view = "menu"
    }
}
