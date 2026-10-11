pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../config"
import "../../common"
import "../../services"
import "../../launcher"

// Menú del click derecho en la estrella. Dos vistas: la lista de opciones y
// la grilla de wallpapers. Lo abre y cierra TopBar con `open` (de Panel).
Panel {
    id: menu

    // La pantalla de la barra que contiene este menú, para que el launcher y
    // el selector de wallpapers sepan dónde abrir/aplicar.
    required property string monitor

    // "menu" muestra las opciones; "wallpaper" reemplaza el panel por la
    // grilla de miniaturas.
    property string view: "menu"

    // Apagar y reiniciar piden un segundo click: un click perdido en la barra
    // no debería cerrar la sesión entera. La confirmación caduca sola.
    property string pendingAction: ""

    // El menú no decide si está abierto: pide cerrarse y TopBar lo hace.
    signal closeRequested

    readonly property real padding: 10

    implicitWidth: menu.view === "wallpaper" ? 420 : 210
    implicitHeight: (menu.view === "wallpaper" ? wallpaperLoader.implicitHeight : menuView.implicitHeight) + menu.padding * 2

    // Sin sombra: el menú es chico y la capa cuesta más que lo que aporta.
    shadow: false

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Theme.easing
        }
    }

    // Cada vez que se cierra vuelve a la lista: así la grilla de wallpapers
    // se destruye y no queda viva (ni sus procesos) mientras no se mira.
    onOpenChanged: {
        if (!menu.open)
            menu.reset();
    }

    function reset() {
        menu.view = "menu";
        menu.pendingAction = "";
    }

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
            // nf-fa-image
            icon: "\u{f03e}"
            label: "Wallpaper"
            onTriggered: {
                menu.view = "wallpaper";
                Sounds.play("soft");
            }
        }

        MenuEntry {
            Layout.fillWidth: true
            // nf-fa-camera
            icon: "\u{f030}"
            label: "Screenshot"
            enabled: false
        }

        MenuEntry {
            Layout.fillWidth: true
            // nf-fa-search
            icon: "\u{f002}"
            label: "Launcher"
            onTriggered: {
                menu.closeRequested();
                LauncherState.show(menu.monitor);
            }
        }

        MenuEntry {
            Layout.fillWidth: true
            // nf-fa-refresh
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
            // nf-fa-power_off
            icon: "\u{f011}"
            armed: menu.pendingAction === "poweroff"
            label: armed ? "Click again to shut down" : "Shutdown"
            onTriggered: menu.confirm("poweroff", ["systemctl", "poweroff"])
        }
    }

    // ── Vista: grilla de wallpapers ───────────────────────────────────
    // En un Loader: solo existe mientras se mira. Al crearse lista los
    // directorios, así que siempre muestra lo que hay en disco.
    Loader {
        id: wallpaperLoader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: menu.padding

        active: menu.view === "wallpaper"

        sourceComponent: WallpaperGrid {
            monitor: menu.monitor
            onBack: menu.view = "menu"
        }
    }
}
