import QtQuick

import "../config"

// Texto con la tipografía de la barra y transición de color en el hover.
// Usarlo en vez de Text para no repetir fuente, tamaño y Behavior.
Text {
    color: Colors.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontBar
    font.bold: true

    Behavior on color {
        ColorAnimation {
            duration: Theme.animFast
        }
    }
}
