import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtMultimedia

import "../../config"
import "../../launcher"

Rectangle {
    id: menu

    // La pantalla de la barra que contiene este menú, para que el selector de
    // wallpapers sepa dónde aplicar.
    required property string monitor

    // "menu" muestra las opciones; "wallpaper" reemplaza el panel por la
    // grilla de miniaturas.
    property string view: "menu"

    // El menú no sabe si está abierto: eso lo decide quien lo contiene.
    signal closeRequested

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
        menu.pendingAction = "";
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
            onTriggered: {
                menu.closeRequested();
                LauncherState.show(menu.monitor);
            }
        }

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f021}"
            label: "Restart Hyprland"
            enabled: false
        }

        MenuEntry {
            Layout.fillWidth: true
            // nf-md-restart
            icon: "\u{f0709}"
            armed: menu.pendingAction === "reboot"
            label: armed ? "Click again to reboot" : "Reboot"
            onTriggered: menu.confirm("reboot", ["systemctl", "reboot"])
        }

        MenuEntry {
            Layout.fillWidth: true
            icon: "\u{f011}"
            armed: menu.pendingAction === "poweroff"
            label: armed ? "Click again to shut down" : "Shutdown"
            onTriggered: menu.confirm("poweroff", ["systemctl", "poweroff"])
        }
    }

    // Apagar y reiniciar piden un segundo click: un click perdido en la barra
    // no debería cerrar la sesión entera. La confirmación caduca sola.
    property string pendingAction: ""

    function confirm(action, command) {
        if (menu.pendingAction === action) {
            menu.pendingAction = "";
            Quickshell.execDetached(command);
            return;
        }
        menu.pendingAction = action;
        confirmTimer.restart();
    }

    Timer {
        id: confirmTimer
        interval: 3000
        onTriggered: menu.pendingAction = ""
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
