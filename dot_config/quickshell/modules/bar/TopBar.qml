pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "./components/"
import "../config"
import "../launcher/"

// La barra de una pantalla (shell.qml crea una por monitor). Contiene la fila
// de pills y los desplegables que cuelgan de ella.
//
// Desplegables: hay uno abierto como máximo, y cuál es lo dice `openPanel`.
// Para agregar uno nuevo, ver la receta en CLAUDE.md.
PanelWindow {
    id: topPanel

    // Nombre del monitor de esta barra (`screen` lo inyecta Variants).
    readonly property string monitorName: topPanel.screen ? topPanel.screen.name : ""

    // "" = ninguno; si no, el nombre del desplegable abierto ("menu", "mixer").
    property string openPanel: ""

    function togglePanel(name) {
        topPanel.openPanel = topPanel.openPanel === name ? "" : name;
    }

    // Espacio para lo que se despliega bajo la barra. Lo más alto es el menú
    // en la vista de wallpapers; el mezclador tiene tope y hace scroll.
    readonly property real expandRoom: 460

    anchors {
        top: true
        left: true
        right: true
    }
    // Altura fija que ya reserva el espacio de lo que puede desplegarse. No se
    // ajusta al contenido: hacerlo reescalaba la superficie durante la
    // animación y la fila entera daba un salto de un frame al cerrar.
    implicitHeight: Theme.barHeight + topPanel.expandRoom
    color: "transparent"

    // La zona exclusiva se queda en la altura de la barra: lo que se expande
    // flota sobre las ventanas en vez de reacomodarlas.
    exclusiveZone: Theme.barHeight

    // Solo la barra y lo que esté desplegado reciben clicks; el resto del
    // panel los deja pasar a las ventanas de abajo. Todo lo que pueda
    // crecer por debajo de la fila tiene que estar aquí.
    mask: Region {
        item: content

        Region {
            item: systemMonitor
            intersection: Intersection.Combine
        }

        Region {
            item: volumeMixer
            intersection: Intersection.Combine
        }

        Region {
            item: globalMenu
            intersection: Intersection.Combine
        }
    }

    // Sin margen izquierdo: el botón de la esquina va pegado al canto.
    margins {
        left: 0
        right: 10
        top: 0
    }

    // Cierra el desplegable abierto al hacer click fuera de la barra. Los
    // clicks dentro del panel no cuentan como fuera.
    HyprlandFocusGrab {
        windows: [topPanel]
        active: topPanel.openPanel !== ""
        onCleared: topPanel.openPanel = ""
    }

    // Cubre el panel entero para que las estrellitas puedan caer bajo la
    // barra sin recortarse contra el borde del botón.
    StarBurst {
        id: starBurst
        anchors.fill: parent
        z: 10
    }

    // ── Desplegables ──────────────────────────────────────────────────
    // Van aquí y no dentro del widget que los abre: colgados de la pill
    // quedarían fuera del área de su padre y no recibirían el mouse.

    GlobalMenu {
        id: globalMenu
        anchors.top: content.bottom
        anchors.topMargin: Theme.dropdownGap
        anchors.left: content.left

        monitor: topPanel.monitorName
        open: topPanel.openPanel === "menu"
        onCloseRequested: topPanel.openPanel = ""
    }

    VolumeMixer {
        id: volumeMixer
        anchors.top: content.bottom
        anchors.topMargin: Theme.dropdownGap
        anchors.right: content.right
        // Alineado con el borde derecho de la pill de volumen.
        anchors.rightMargin: content.width - volumeWidget.x - volumeWidget.width

        open: topPanel.openPanel === "mixer"
    }

    // ── Fila de pills ─────────────────────────────────────────────────
    RowLayout {
        id: content
        // Anclado arriba y con la altura de la barra, no del panel: si
        // siguiera al panel se redimensionaría durante la animación y toda
        // la fila daría un salto.
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.barHeight
        spacing: Theme.pillSpacing

        StarButton {
            id: starButton
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.rightMargin: 6

            onSparkle: {
                // Las estrellitas salen desde el centro-bajo del botón.
                starBurst.moveTo(starButton.x + starButton.width / 2, Theme.barHeight - 6);
                starBurst.fire(16);
            }

            // Se abre en esta pantalla, no en la enfocada: el click puede venir
            // de un monitor que no tiene el foco.
            onPrimaryAction: {
                topPanel.openPanel = "";
                LauncherState.toggle(topPanel.monitorName);
            }

            onSecondaryAction: topPanel.togglePanel("menu")
        }

        Repeater {
            model: Settings.workspaceGroups

            Workspaces {
                required property var modelData
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                workspaceIds: modelData
            }
        }

        Item {
            Layout.fillWidth: true
        }

        SystemMonitor {
            id: systemMonitor
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
        }

        Volume {
            id: volumeWidget
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            onMixerToggleRequested: topPanel.togglePanel("mixer")
        }

        Clock {
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
        }
    }
}
