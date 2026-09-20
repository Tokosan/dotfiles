import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

import "../../config"

Rectangle {
    id: monitor

    property real hPadding: 10
    property real bottomRadius: 15
    property real barHeight: 34
    property real borderWidth: 2

    // Alterna entre relleno de carga y porcentaje, para las tres a la vez.
    property bool showPercent: false
    // Expande la pill hacia abajo mostrando el porcentaje bajo cada una.
    property bool expanded: false

    property int cpuUsage: 0
    property int memUsage: 0
    property int gpuUsage: 0

    // Detalle que se muestra al expandir.
    property int cpuTemp: 0
    property int gpuTemp: 0
    property real memUsedGb: 0
    property real memTotalGb: 0

    // /proc/stat trae contadores acumulados: el uso real es la diferencia
    // entre dos lecturas.
    property var lastCpu: null

    implicitWidth: row.implicitWidth + hPadding * 2
    implicitHeight: barHeight + (expanded ? expandExtra : 0)

    // Cuánto crece la pill al expandirse.
    readonly property real expandExtra: 36

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    color: Colors.barBackground
    bottomLeftRadius: bottomRadius
    bottomRightRadius: bottomRadius

    // Al expandirse la pill queda flotando sobre el wallpaper, así que se
    // perfila con un borde. Se traza con Shape y no con border.width porque
    // arriba no lleva: la pill cuelga del borde de la pantalla y ahí no hay
    // nada de lo que separarla.
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        opacity: monitor.expanded ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 160
            }
        }

        ShapePath {
            strokeColor: Colors.panelBorder
            strokeWidth: monitor.borderWidth
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            // Baja por la izquierda, curva, cruza abajo, curva y sube por la
            // derecha. El tramo superior queda abierto.
            startX: monitor.borderWidth / 2
            startY: 0

            PathLine {
                x: monitor.borderWidth / 2
                y: monitor.height - monitor.bottomRadius
            }

            PathArc {
                x: monitor.bottomRadius
                y: monitor.height - monitor.borderWidth / 2
                radiusX: monitor.bottomRadius
                radiusY: monitor.bottomRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: monitor.width - monitor.bottomRadius
                y: monitor.height - monitor.borderWidth / 2
            }

            PathArc {
                x: monitor.width - monitor.borderWidth / 2
                y: monitor.height - monitor.bottomRadius
                radiusX: monitor.bottomRadius
                radiusY: monitor.bottomRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: monitor.width - monitor.borderWidth / 2
                y: 0
            }
        }
    }

    function readCpu(text) {
        const line = text.split("\n")[0];
        const parts = line.trim().split(/\s+/).slice(1).map(Number);
        if (parts.length < 4)
            return;

        const idle = parts[3] + (parts[4] ?? 0);
        const total = parts.reduce((a, b) => a + b, 0);

        if (monitor.lastCpu) {
            const dTotal = total - monitor.lastCpu.total;
            const dIdle = idle - monitor.lastCpu.idle;
            if (dTotal > 0)
                monitor.cpuUsage = Math.round((1 - dIdle / dTotal) * 100);
        }

        monitor.lastCpu = {
            idle: idle,
            total: total
        };
    }

    function readMem(text) {
        const total = Number(text.match(/MemTotal:\s+(\d+)/)?.[1] ?? 0);
        const available = Number(text.match(/MemAvailable:\s+(\d+)/)?.[1] ?? 0);
        if (total <= 0)
            return;

        monitor.memUsage = Math.round((1 - available / total) * 100);
        // /proc/meminfo viene en kB.
        monitor.memTotalGb = total / 1048576;
        monitor.memUsedGb = (total - available) / 1048576;
    }

    FileView {
        id: statFile
        path: "/proc/stat"
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
    }

    // Promedio de los sensores por core. Se excluye el del package, que es
    // otra medida y no un core más.
    Process {
        id: cpuTempProcess
        command: ["sh", "-c", `
            for h in /sys/class/hwmon/hwmon*; do
                [ "$(cat "$h/name" 2>/dev/null)" = "coretemp" ] || \
                [ "$(cat "$h/name" 2>/dev/null)" = "k10temp" ] || continue
                for f in "$h"/temp*_input; do
                    [ -f "$f" ] || continue
                    label=$(cat "\${f%_input}_label" 2>/dev/null)
                    case "$label" in *Package*|*Tctl*) continue;; esac
                    cat "$f"
                done
            done | awk '{ sum += $1; n++ } END { if (n > 0) print int(sum / n / 1000) }'
        `]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseInt(text.trim());
                if (!isNaN(value))
                    monitor.cpuTemp = value;
            }
        }
    }

    Process {
        id: gpuProcess
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",").map(v => parseInt(v.trim()));
                if (!isNaN(parts[0]))
                    monitor.gpuUsage = parts[0];
                if (!isNaN(parts[1]))
                    monitor.gpuTemp = parts[1];
            }
        }
    }

    Timer {
        running: true
        // Expandido se refresca más seguido, porque se está mirando el detalle.
        interval: monitor.expanded ? 1000 : 5000
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            statFile.reload();
            memFile.reload();
            monitor.readCpu(statFile.text());
            monitor.readMem(memFile.text());
            gpuProcess.running = true;
            cpuTempProcess.running = true;
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        // El click derecho es el de reactividad: despliega el detalle.
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
        anchors.topMargin: (monitor.barHeight - 30) / 2
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6

        Stat {
            label: "CPU"
            value: monitor.cpuUsage
            showPercent: monitor.showPercent
            expanded: monitor.expanded
            detail: monitor.cpuTemp > 0 ? monitor.cpuTemp + "\u00b0C" : ""
        }

        Stat {
            label: "RAM"
            value: monitor.memUsage
            showPercent: monitor.showPercent
            expanded: monitor.expanded
            detail: monitor.memTotalGb > 0 ? monitor.memUsedGb.toFixed(1) + "/" + monitor.memTotalGb.toFixed(0) + "G" : ""
        }

        Stat {
            label: "GPU"
            value: monitor.gpuUsage
            showPercent: monitor.showPercent
            expanded: monitor.expanded
            detail: monitor.gpuTemp > 0 ? monitor.gpuTemp + "\u00b0C" : ""
        }
    }
}
