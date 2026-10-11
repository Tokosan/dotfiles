pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "../../config"
import "../../common"

// Grupo de workspaces (p. ej. 1-5). Se muestran siempre, aunque estén vacíos.
//   click izquierdo: ir al workspace · click medio: mover ahí la ventana
BarPill {
    id: workspaces

    // IDs que forman este grupo (ver Settings.workspaceGroups).
    required property var workspaceIds

    hPadding: 10
    contentWidth: layout.implicitWidth

    // Workspace de Hyprland con ese número, o null si está vacío (Hyprland
    // solo reporta los ocupados). Se compara por name porque uno descubierto
    // vía toplevel llega con id = -1; el name en cambio siempre viene bien.
    function findWorkspace(id) {
        return Hyprland.workspaces.values.find(ws => parseInt(ws.name) === id) ?? null;
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 8

        // El modelo es la lista fija de ids, no el estado de Hyprland: así los
        // delegates viven siempre y solo cambian sus propiedades. Con un
        // array recalculado se recreaban en cada cambio de foco y las
        // animaciones de color/ancho no llegaban a verse.
        Repeater {
            model: workspaces.workspaceIds

            MouseArea {
                id: entry
                required property int modelData

                readonly property var ws: workspaces.findWorkspace(entry.modelData)
                readonly property bool focused: entry.ws?.focused ?? false
                readonly property bool occupied: entry.ws !== null

                implicitWidth: pill.implicitWidth
                implicitHeight: pill.implicitHeight
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                // Siempre por dispatch: activate() actuaría sobre un objeto que
                // puede traer id = -1 y enfocar el workspace equivocado.
                onClicked: mouse => {
                    if (mouse.button === Qt.MiddleButton)
                        // Igual que super+shift+n: lleva la ventana enfocada y
                        // el foco con ella.
                        Hyprland.dispatch(`hl.dsp.window.move({ workspace = ${entry.modelData} })`);
                    else
                        Hyprland.dispatch(`hl.dsp.focus({ workspace = ${entry.modelData} })`);
                }

                Rectangle {
                    id: pill
                    anchors.centerIn: parent

                    // Vacío: círculo perfecto (ancho = alto), sin nada dentro.
                    // Con ventanas: se alarga lo justo para los iconos.
                    implicitHeight: Theme.workspaceSize
                    implicitWidth: entry.occupied ? Math.max(Theme.workspaceSize, icons.implicitWidth + 18) : Theme.workspaceSize
                    radius: height / 2

                    color: entry.focused ? Colors.workspaceActiveBg : entry.containsMouse ? Colors.workspaceHoverBg : Colors.workspaceEmptyBg

                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: Theme.animNormal
                            easing.type: Theme.easing
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.animNormal
                        }
                    }

                    WorkspaceButton {
                        id: icons
                        anchors.centerIn: parent

                        workspaceId: entry.modelData
                        // También se ilumina al pasar el mouse, no solo al estar enfocado.
                        iconColor: entry.focused || entry.containsMouse ? Colors.workspaceActive : Colors.workspaceIdle

                        Behavior on iconColor {
                            ColorAnimation {
                                duration: Theme.animFast
                            }
                        }
                    }
                }
            }
        }
    }
}
