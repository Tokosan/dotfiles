pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../config"

// Fila de pestañas. El contenedor decide qué pasa al elegir una.
//
//   TabBar {
//       tabs: [{ id: "a", label: "A" }, { id: "b", label: "B" }]
//       current: root.tab
//       onSelected: id => root.tab = id
//   }
RowLayout {
    id: bar

    // [{ id, label }]
    required property var tabs
    required property string current
    property int fontSize: Theme.fontSm
    property real tabHeight: 22

    signal selected(string id)

    spacing: 4

    Repeater {
        model: bar.tabs

        MouseArea {
            id: tab
            required property var modelData

            readonly property bool active: tab.modelData.id === bar.current

            implicitWidth: tabLabel.implicitWidth + 18
            implicitHeight: bar.tabHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: bar.selected(tab.modelData.id)

            Rectangle {
                anchors.fill: parent
                radius: Theme.itemRadius
                color: tab.active ? Colors.surfaceSelected : tab.containsMouse ? Colors.surfaceSubtle : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animFast
                    }
                }
            }

            Text {
                id: tabLabel
                anchors.centerIn: parent
                text: tab.modelData.label
                color: tab.active ? Colors.text : Colors.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: bar.fontSize
                font.bold: tab.active
            }
        }
    }
}
