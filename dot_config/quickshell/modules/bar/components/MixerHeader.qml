import QtQuick
import QtQuick.Layouts

import "../../config"

Item {
    id: header

    required property string text

    implicitHeight: label.implicitHeight + 6

    Text {
        id: label
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        text: header.text.toUpperCase()
        color: Qt.alpha(Colors.foreground, 0.45)
        font.family: "JetBrains Mono Nerd Font"
        font.pixelSize: 9
        font.bold: true
        font.letterSpacing: 1
    }

    Rectangle {
        anchors.left: label.right
        anchors.leftMargin: 7
        anchors.right: parent.right
        anchors.verticalCenter: label.verticalCenter

        height: 1
        color: Qt.alpha(Colors.foreground, 0.12)
    }
}
