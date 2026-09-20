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
    // Crece si algún widget se expande (p. ej. el monitor de sistema), para
    // que no quede cortado contra el borde del panel.
    implicitHeight: Math.max(barHeight, content.implicitHeight)
    color: "transparent"

    property real barHeight: 40

    // La zona exclusiva se queda en la altura de la barra: lo que se expande
    // flota sobre las ventanas en vez de reacomodarlas.
    exclusiveZone: barHeight

    // Solo la barra recibe clicks; el resto del panel deja pasar el mouse.
    mask: Region {
        item: content
    }

    margins {
        left: 50
        right: 10
        top: 0
    }

    RowLayout {
        id: content
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

        SystemMonitor {
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
        }

        Volume {
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
        }

        Clock {
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
        }
    }
}
