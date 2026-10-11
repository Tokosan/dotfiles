import QtQuick

import "../config"

// Base de cada módulo de la barra: la "pill colgante", pegada al borde
// superior y con las esquinas de abajo redondeadas. Los hijos se centran
// solos y la pill toma su ancho más el padding.
//
//   BarPill {
//       BarText { text: "hola" }
//   }
Rectangle {
    id: pill

    // Hijos declarados dentro de la pill.
    default property alias content: container.data

    property real hPadding: 12
    // true: el contenido se pega arriba (útil si la pill crece hacia abajo,
    // como el monitor de sistema expandido). false: centrado vertical.
    property bool alignTop: false
    property real topPadding: (Theme.pillHeight - container.implicitHeight) / 2

    implicitWidth: container.implicitWidth + hPadding * 2
    implicitHeight: Theme.pillHeight

    color: Colors.barBackground
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: Theme.pillRadius
    bottomRightRadius: Theme.pillRadius

    Item {
        id: container
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
        width: implicitWidth
        height: implicitHeight
        x: (pill.width - width) / 2
        y: pill.alignTop ? pill.topPadding : (pill.height - height) / 2
    }
}
