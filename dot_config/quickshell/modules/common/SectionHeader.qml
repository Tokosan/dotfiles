import QtQuick

import "../config"

// Título de sección en mayúsculas con una línea que llena el resto del ancho.
// Se usa dentro de paneles ("DEVICES", "APPLICATIONS"...).
Item {
    id: header

    required property string text

    implicitHeight: label.implicitHeight + 6

    Text {
        id: label
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        text: header.text.toUpperCase()
        color: Colors.textMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontXs
        font.bold: true
        font.letterSpacing: 1
    }

    Rectangle {
        anchors.left: label.right
        anchors.leftMargin: 7
        anchors.right: parent.right
        anchors.verticalCenter: label.verticalCenter

        height: 1
        color: Colors.divider
    }
}
