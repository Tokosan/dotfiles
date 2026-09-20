import QtQuick
import QtQuick.Layouts

import "../../config"

Rectangle {
    id: stat

    required property string label
    required property int value

    implicitWidth: row.implicitWidth + 14
    implicitHeight: 26
    radius: 11

    color: Qt.alpha(Colors.foreground, 0.12)

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: stat.label
            color: Colors.foreground
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 11
            font.bold: true
        }

        // Ancho reservado para tres cifras, para que la pill no salte.
        Item {
            implicitWidth: pctMetrics.width
            implicitHeight: pct.implicitHeight

            TextMetrics {
                id: pctMetrics
                font: pct.font
                text: "100%"
            }

            Text {
                id: pct
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                text: stat.value + "%"
                color: Colors.foreground
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 11
                font.bold: true
            }
        }
    }
}
