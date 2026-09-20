import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../config"

Rectangle {
    id: clock

    property real hPadding: 14
    property real bottomRadius: 15
    // Misma altura que el grupo de workspaces (pillSize + padding) para que
    // las pills de la barra queden todas del mismo grosor.
    property real barHeight: 34

    implicitWidth: row.implicitWidth + hPadding * 2
    implicitHeight: barHeight

    color: Colors.barBackground
    bottomLeftRadius: bottomRadius
    bottomRightRadius: bottomRadius

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: Qt.formatDateTime(systemClock.date, "dddd, dd 'of' MMMM")
            color: Colors.foreground
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 13
            font.bold: true
        }

        Text {
            // nf-md-clock_outline
            text: "\u{f0954}"
            color: Colors.foreground
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 13
        }

        Text {
            text: Qt.formatDateTime(systemClock.date, "HH:mm:ss")
            color: Colors.foreground
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 13
            font.bold: true
        }
    }
}
