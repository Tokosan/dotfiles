import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../config"

Rectangle {
    id: monitor

    property real hPadding: 10
    property real bottomRadius: 15
    property real barHeight: 34

    // Alterna entre relleno de carga y porcentaje, para las tres a la vez.
    property bool showPercent: false
    // Expande la pill hacia abajo mostrando el porcentaje bajo cada una.
    property bool expanded: false

    property int cpuUsage: 0
    property int memUsage: 0
    property int gpuUsage: 0

    // /proc/stat trae contadores acumulados: el uso real es la diferencia
    // entre dos lecturas.
    property var lastCpu: null

    implicitWidth: row.implicitWidth + hPadding * 2
    implicitHeight: barHeight + (expanded ? expandExtra : 0)

    // Cuánto crece la pill al expandirse.
    readonly property real expandExtra: 16

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    color: Colors.barBackground
    bottomLeftRadius: bottomRadius
    bottomRightRadius: bottomRadius

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
        if (total > 0)
            monitor.memUsage = Math.round((1 - available / total) * 100);
    }

    FileView {
        id: statFile
        path: "/proc/stat"
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
    }

    Process {
        id: gpuProcess
        command: ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = parseInt(text.trim());
                if (!isNaN(value))
                    monitor.gpuUsage = value;
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
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
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
        anchors.topMargin: (monitor.barHeight - 26) / 2
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6

        Stat {
            label: "CPU"
            value: monitor.cpuUsage
            showPercent: monitor.showPercent
            expanded: monitor.expanded
        }

        Stat {
            label: "RAM"
            value: monitor.memUsage
            showPercent: monitor.showPercent
            expanded: monitor.expanded
        }

        Stat {
            label: "GPU"
            value: monitor.gpuUsage
            showPercent: monitor.showPercent
            expanded: monitor.expanded
        }
    }
}
