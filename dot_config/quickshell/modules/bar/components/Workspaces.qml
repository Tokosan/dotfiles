import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "../../config"

Rectangle {
    id: workspaces

    // IDs que forman este grupo. Se muestran siempre, aunque estén vacíos.
    required property var workspaceIds
    // Diámetro del círculo de un workspace vacío.
    property real pillSize: 26

    implicitWidth: layout.implicitWidth + 20
    implicitHeight: layout.implicitHeight + 8

    color: Colors.barBackground
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: 15
    bottomRightRadius: 15

    // Une los IDs del grupo con el estado real de Hyprland, que solo reporta
    // los workspaces ocupados.
    readonly property var entries: {
        const byId = ({});

        for (const id of workspaces.workspaceIds) {
            byId[id] = {
                id: id,
                name: String(id),
                focused: false,
                urgent: false,
                occupied: false,
                ws: null
            };
        }

        for (const ws of Hyprland.workspaces.values) {
            // Se compara por name porque un workspace descubierto vía toplevel
            // llega con id = -1; el name en cambio siempre viene bien.
            const wsId = parseInt(ws.name);
            if (isNaN(wsId) || !workspaces.workspaceIds.includes(wsId))
                continue;

            byId[wsId] = {
                id: wsId,
                name: ws.name,
                focused: ws.focused,
                urgent: ws.urgent,
                occupied: true,
                ws: ws
            };
        }

        return Object.values(byId).sort((a, b) => a.id - b.id);
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: workspaces.entries

            MouseArea {
                id: entry
                required property var modelData

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
                        Hyprland.dispatch('hl.dsp.window.move({ workspace = ' + entry.modelData.id + ' })');
                    else
                        Hyprland.dispatch('hl.dsp.focus({ workspace = ' + entry.modelData.id + ' })');
                }

                Rectangle {
                    id: pill
                    anchors.centerIn: parent

                    // Vacío: círculo perfecto (ancho = alto), sin nada dentro.
                    // Con ventanas: se alarga lo justo para los iconos.
                    implicitHeight: workspaces.pillSize
                    implicitWidth: entry.modelData.occupied ? Math.max(workspaces.pillSize, icons.implicitWidth + 18) : workspaces.pillSize
                    radius: height / 2

                    color: entry.modelData.focused ? Colors.workspaceActiveBg : entry.containsMouse ? Colors.workspaceHoverBg : Colors.workspaceEmptyBg

                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    WorkspaceButton {
                        id: icons
                        anchors.centerIn: parent

                        workspaceId: entry.modelData.id
                        // También se ilumina al pasar el mouse, no solo al estar enfocado.
                        iconColor: entry.modelData.focused || entry.containsMouse ? Colors.workspaceActive : Colors.workspaceIdle

                        Behavior on iconColor {
                            ColorAnimation {
                                duration: 120
                            }
                        }
                    }
                }
            }
        }
    }
}
