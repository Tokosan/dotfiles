pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

import "../config"

// Lecturas de CPU, RAM, GPU y temperaturas. Una sola fuente para todas las
// barras: antes cada pantalla lanzaba su propio `sh` y `nvidia-smi`.
Singleton {
    id: root

    // Porcentajes 0-100.
    property int cpuUsage: 0
    property int memUsage: 0
    property int gpuUsage: 0

    // Grados Celsius; 0 = sin dato.
    property int cpuTemp: 0
    property int gpuTemp: 0

    property real memUsedGb: 0
    property real memTotalGb: 0

    // false si nvidia-smi no existe o se cayó: la pill de GPU se oculta en vez
    // de mostrar un 0 % que parece real.
    property bool gpuAvailable: false

    // /proc/stat trae contadores acumulados: el uso real es la diferencia
    // entre dos lecturas.
    property var lastCpu: null

    // Rutas temp*_input de los cores (coretemp/k10temp), resueltas una vez
    // al arrancar. Luego se leen con FileView, sin lanzar procesos.
    property var cpuTempPaths: []

    function readCpu(text) {
        const line = text.split("\n")[0];
        // Solo user..steal (8 columnas): guest y guest_nice ya están
        // incluidos en user y nice, y sumarlos inflaría el total.
        const parts = line.trim().split(/\s+/).slice(1, 9).map(Number);
        if (parts.length < 4)
            return;

        const idle = parts[3] + (parts[4] ?? 0);
        const total = parts.reduce((a, b) => a + b, 0);

        if (root.lastCpu) {
            const dTotal = total - root.lastCpu.total;
            const dIdle = idle - root.lastCpu.idle;
            if (dTotal > 0)
                root.cpuUsage = Math.round((1 - dIdle / dTotal) * 100);
        }

        root.lastCpu = {
            idle: idle,
            total: total
        };
    }

    function readMem(text) {
        const total = Number(text.match(/MemTotal:\s+(\d+)/)?.[1] ?? 0);
        const available = Number(text.match(/MemAvailable:\s+(\d+)/)?.[1] ?? 0);
        if (total <= 0)
            return;

        root.memUsage = Math.round((1 - available / total) * 100);
        // /proc/meminfo viene en kB.
        root.memTotalGb = total / 1048576;
        root.memUsedGb = (total - available) / 1048576;
    }

    function readCpuTemp() {
        let sum = 0;
        let n = 0;
        for (const file of cpuTempFiles.instances) {
            file.reload();
            const value = parseInt(file.text());
            if (!isNaN(value)) {
                sum += value;
                n++;
            }
        }
        if (n > 0)
            root.cpuTemp = Math.round(sum / n / 1000);
    }

    function refresh() {
        statFile.reload();
        memFile.reload();
        root.readCpu(statFile.text());
        root.readMem(memFile.text());
        root.readCpuTemp();
    }

    FileView {
        id: statFile
        path: "/proc/stat"
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
    }

    // Se excluye el sensor del package (Package/Tctl): es otra medida y no un
    // core más. Corre una sola vez.
    Process {
        id: cpuTempDiscovery
        running: true
        command: ["sh", "-c", `
            for h in /sys/class/hwmon/hwmon*; do
                name=$(cat "$h/name" 2>/dev/null)
                [ "$name" = coretemp ] || [ "$name" = k10temp ] || continue
                for f in "$h"/temp*_input; do
                    [ -f "$f" ] || continue
                    case "$(cat "\${f%_input}_label" 2>/dev/null)" in *Package*|*Tctl*) continue;; esac
                    echo "$f"
                done
            done
        `]

        stdout: StdioCollector {
            onStreamFinished: root.cpuTempPaths = text.split("\n").filter(p => p.length > 0)
        }
    }

    Variants {
        id: cpuTempFiles
        model: root.cpuTempPaths

        FileView {
            required property string modelData
            path: modelData
        }
    }

    // Un único nvidia-smi que reporta solo cada 2 s (-lms), en vez de lanzar
    // un proceso por lectura: arrancar NVML es lo más caro de todo el poll.
    Process {
        id: gpuProcess
        running: true
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits", "-lms", String(Settings.statsInterval)]

        stdout: SplitParser {
            onRead: line => {
                const parts = line.split(",").map(v => parseInt(v.trim()));
                if (isNaN(parts[0]))
                    return;
                root.gpuAvailable = true;
                root.gpuUsage = parts[0];
                if (!isNaN(parts[1]))
                    root.gpuTemp = parts[1];
            }
        }

        // Si se cae o no existe (driver recargado, suspensión, sin NVIDIA),
        // se reintenta más tarde.
        onRunningChanged: {
            if (!gpuProcess.running) {
                root.gpuAvailable = false;
                gpuRetry.restart();
            }
        }
    }

    Timer {
        id: gpuRetry
        interval: 30000
        onTriggered: gpuProcess.running = true
    }

    Timer {
        running: true
        repeat: true
        triggeredOnStart: true
        interval: Settings.statsInterval
        onTriggered: root.refresh()
    }
}
