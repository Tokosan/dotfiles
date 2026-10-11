import Quickshell
import QtQuick

import "./modules/bar/"
import "./modules/launcher/"

ShellRoot {
    id: root

    // Una barra por monitor conectado. Se crean y destruyen solas al
    // conectar/desconectar pantallas.
    Variants {
        model: Quickshell.screens

        TopBar {
            required property var modelData
            screen: modelData
        }
    }

    // Uno solo para todas las pantallas: se abre en la que tiene el foco.
    Launcher {}
}
