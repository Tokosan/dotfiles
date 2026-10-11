import Quickshell
import QtQuick
import QtQuick.Layouts

import "../../common"

BarPill {
    id: clock

    hPadding: 14
    contentWidth: row.implicitWidth

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 10

        BarText {
            text: Qt.formatDateTime(systemClock.date, "yyyy-MM-dd")
        }

        BarText {
            // nf-md-clock_outline
            text: "\u{f0954}"
            font.bold: false
        }

        BarText {
            text: Qt.formatDateTime(systemClock.date, "HH:mm:ss")
        }
    }
}
