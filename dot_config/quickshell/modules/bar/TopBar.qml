import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts

import "./components/"

PanelWindow {
    id: topPanel

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 40
    color: "transparent"

    margins {
        left: 50
        right: 0
        top: 0
    }

    RowLayout {
        anchors.fill: parent
        spacing: 4

        // Dos grupos, igual que en waybar: DP-1 lleva 1-5 y HDMI-A-1 lleva 6-10.
        Workspaces {
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            workspaceIds: [1, 2, 3, 4, 5]
        }

        Workspaces {
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            workspaceIds: [6, 7, 8, 9, 10]
        }

        Item {
            Layout.fillWidth: true
        }
    }
}
