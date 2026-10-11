import QtQuick

import "../config"

// Base de cada módulo de la barra: la "pill colgante", pegada al borde
// superior y con las esquinas de abajo redondeadas. El ancho sale del
// contenido más el padding; el contenido lo posiciona quien la usa.
//
//   BarPill {
//       contentWidth: row.implicitWidth
//       RowLayout { id: row; anchors.centerIn: parent; ... }
//   }
Rectangle {
    id: pill

    // Ancho del contenido, sin padding.
    property real contentWidth: 0
    property real hPadding: 12

    implicitWidth: contentWidth + hPadding * 2
    implicitHeight: Theme.pillHeight

    color: Colors.barBackground
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: Theme.pillRadius
    bottomRightRadius: Theme.pillRadius
}
