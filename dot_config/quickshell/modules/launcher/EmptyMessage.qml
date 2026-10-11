import QtQuick

import "../config"

// Mensaje centrado para una grilla vacía ("No favorites yet", "No apps match").
Text {
    horizontalAlignment: Text.AlignHCenter
    color: Colors.textFaint
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontBody
}
