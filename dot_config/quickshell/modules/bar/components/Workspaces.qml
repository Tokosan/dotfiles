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
            // Solo los IDs de este grupo (esto ya excluye los special, id < 0).
            if (!workspaces.workspaceIds.includes(ws.id))
                continue;

            byId[ws.id] = {
                id: ws.id,
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
                onClicked: {
                    if (entry.modelData.ws)
                        entry.modelData.ws.activate();
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
                        iconColor: entry.modelData.focused ? Colors.workspaceActive : Colors.workspaceIdle
                    }
                }
            }
        }
    }
}
