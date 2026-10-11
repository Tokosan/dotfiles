import QtQuick
import QtQuick.Effects

import "../config"

// Tarjeta flotante con el estilo de los paneles (fondo, borde, sombra) y la
// animación de abrir/cerrar. Base de los desplegables de la barra y de la
// tarjeta del launcher.
//
// Cerrado mide 0 de alto a propósito: si conservara su tamaño, la máscara de
// clicks de la barra seguiría tragándose los clicks de esa zona.
Rectangle {
    id: panel

    // Para paneles que siempre se ven (launcher) se deja en true.
    property bool open: true
    // Desactivarla en paneles que cubren media pantalla: la capa de la sombra
    // cuesta en proporción al área.
    property bool shadow: true

    visible: opacity > 0
    opacity: open ? 1 : 0
    height: open ? implicitHeight : 0
    clip: true

    color: Colors.panelBackground
    radius: Theme.panelRadius
    border.width: Theme.panelBorderWidth
    border.color: Colors.panelBorder

    Behavior on opacity {
        NumberAnimation {
            duration: Theme.animNormal
        }
    }

    // La sombra necesita que el panel se renderice en su propia capa.
    layer.enabled: panel.shadow
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Colors.panelShadow
        shadowBlur: 0.7
        shadowVerticalOffset: 4
        shadowOpacity: 0.55
    }
}
