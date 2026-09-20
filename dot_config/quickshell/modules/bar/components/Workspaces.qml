import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "../../config"

Rectangle {
    id: workspaces

    // IDs que forman este grupo. Se muestran siempre, aunque estén vacíos.
    required property var workspaceIds

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

                    implicitWidth: entryRow.implicitWidth + 16
                    implicitHeight: entryRow.implicitHeight + 6
                    radius: height / 2

                    color: entry.modelData.focused ? Colors.workspaceActiveBg : entry.containsMouse ? Colors.workspaceHoverBg : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    RowLayout {
                        id: entryRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: entry.modelData.name
                            // Un workspace vacío se ve más apagado que uno con ventanas.
                            color: entry.modelData.focused ? Colors.workspaceActive : entry.modelData.occupied ? Colors.workspaceIdle : Qt.alpha(Colors.foreground, 0.3)
                            font.family: "JetBrains Mono Nerd Font"
                            font.pixelSize: 14
                            font.bold: true
                        }

                        WorkspaceButton {
                            workspaceId: entry.modelData.id
                            iconColor: entry.modelData.focused ? Colors.workspaceActive : Colors.workspaceIdle
                        }
                    }
                }
            }
        }
    }
}
