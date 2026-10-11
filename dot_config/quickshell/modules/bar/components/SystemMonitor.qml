import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

import "../../config"
import "../../common"
import "../../services"

// Pills de CPU, RAM y GPU. Solo pinta: los números vienen de SystemStats,
// compartido entre todas las barras.
//   click derecho: despliega temperatura/uso bajo cada pill
//   click medio:   alterna relleno de carga <-> porcentaje
BarPill {
    id: monitor

    // Alterna entre relleno de carga y porcentaje, para las tres a la vez.
    property bool showPercent: false
    // Expande la pill hacia abajo mostrando el detalle bajo cada una.
    property bool expanded: false

    // Cuánto crece la pill al expandirse.
    readonly property real expandExtra: 36

    hPadding: 10
    contentWidth: row.implicitWidth
    implicitHeight: Theme.pillHeight + (monitor.expanded ? monitor.expandExtra : 0)

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Theme.animSlow
            easing.type: Theme.easing
        }
    }

    // Al expandirse la pill queda flotando sobre el wallpaper, así que se
    // perfila con un borde. Se traza con Shape y no con border.width porque
    // arriba no lleva: la pill cuelga del borde de la pantalla y ahí no hay
    // nada de lo que separarla.
    Shape {
        id: outline
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        readonly property real stroke: Theme.panelBorderWidth
        readonly property real r: monitor.bottomLeftRadius

        opacity: monitor.expanded ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animNormal
            }
        }

        ShapePath {
            strokeColor: Colors.panelBorder
            strokeWidth: outline.stroke
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            // Baja por la izquierda, curva, cruza abajo, curva y sube por la
            // derecha. El tramo superior queda abierto.
            startX: outline.stroke / 2
            startY: 0

            PathLine {
                x: outline.stroke / 2
                y: monitor.height - outline.r
            }

            PathArc {
                x: outline.r
                y: monitor.height - outline.stroke / 2
                radiusX: outline.r
                radiusY: outline.r
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: monitor.width - outline.r
                y: monitor.height - outline.stroke / 2
            }

            PathArc {
                x: monitor.width - outline.stroke / 2
                y: monitor.height - outline.r
                radiusX: outline.r
                radiusY: outline.r
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: monitor.width - outline.stroke / 2
                y: 0
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton)
                monitor.showPercent = !monitor.showPercent;
            else
                monitor.expanded = !monitor.expanded;
        }
    }

    RowLayout {
        id: row
        anchors.top: parent.top
        anchors.topMargin: (Theme.pillHeight - 30) / 2
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6

        Stat {
            label: "CPU"
            value: SystemStats.cpuUsage
            showPercent: monitor.showPercent
            expanded: monitor.expanded
            detail: SystemStats.cpuTemp > 0 ? SystemStats.cpuTemp + "°C" : ""
        }

        Stat {
            label: "RAM"
            value: SystemStats.memUsage
            showPercent: monitor.showPercent
            expanded: monitor.expanded
            detail: SystemStats.memTotalGb > 0 ? SystemStats.memUsedGb.toFixed(1) + "/" + SystemStats.memTotalGb.toFixed(0) + "G" : ""
        }

        // Sin nvidia-smi se oculta: un 0 % fijo parecería una lectura real.
        Stat {
            visible: SystemStats.gpuAvailable
            label: "GPU"
            value: SystemStats.gpuUsage
            showPercent: monitor.showPercent
            expanded: monitor.expanded
            detail: SystemStats.gpuTemp > 0 ? SystemStats.gpuTemp + "°C" : ""
        }
    }
}
