import QtQuick

import "../config"

// Aviso de que launcher.json tuvo un problema. Se cierra con un click; no
// bloquea nada, solo evita que el usuario pierda favoritos sin enterarse.
Rectangle {
    id: warning

    required property string message

    signal dismissed

    visible: warning.message !== ""
    implicitHeight: warning.visible ? label.implicitHeight + 12 : 0
    radius: Theme.itemRadius
    color: Colors.alertSurface

    Text {
        id: label
        anchors.left: warning.left
        anchors.right: warning.right
        anchors.verticalCenter: warning.verticalCenter
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        text: warning.message + "  (click to dismiss)"
        wrapMode: Text.Wrap
        color: Colors.alert
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSm
    }

    MouseArea {
        anchors.fill: warning
        cursorShape: Qt.PointingHandCursor
        onClicked: warning.dismissed()
    }
}
