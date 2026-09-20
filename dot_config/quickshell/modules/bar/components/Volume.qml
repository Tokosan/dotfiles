import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import "../../config"

Rectangle {
    id: volume

    property real hPadding: 12
    property real bottomRadius: 15
    property real barHeight: 34

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    implicitWidth: row.implicitWidth + hPadding * 2
    implicitHeight: barHeight

    color: Colors.barBackground
    bottomLeftRadius: bottomRadius
    bottomRightRadius: bottomRadius

    // Sin esto los nodos no reportan volumen ni mute.
    PwObjectTracker {
        objects: [volume.sink, volume.source]
    }

    // Cuánto cambia el volumen por cada paso de rueda.
    property real step: 0.05

    function percent(node) {
        return Math.round((node?.audio?.volume ?? 0) * 100);
    }

    function toggleMute(node) {
        const audio = node?.audio;
        if (!audio)
            return;

        audio.muted = !audio.muted;
    }

    function scrollVolume(node, delta) {
        const audio = node?.audio;
        if (!audio)
            return;

        const dir = delta > 0 ? 1 : -1;
        audio.volume = Math.max(0, Math.min(1, audio.volume + dir * volume.step));
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 10

        // Entrada (micrófono)
        MouseArea {
            // Ancho fijo con el máximo de ambos estados: el texto de mute es
            // un par de píxeles más ancho y si no la pill saltaría al mutear.
            implicitWidth: Math.max(micText.implicitWidth, micMetrics.implicitWidth, micMetricsMuted.implicitWidth)
            implicitHeight: micText.implicitHeight
            cursorShape: Qt.PointingHandCursor
            onClicked: volume.toggleMute(volume.source)
            onWheel: wheel => volume.scrollVolume(volume.source, wheel.angleDelta.y)

            // Solo para medir: nunca se dibuja. Hay dos porque el glifo de
            // mute y el del micrófono activo no miden lo mismo, y el caso más
            // ancho es el volumen de tres cifras.
            Text {
                id: micMetrics
                visible: false

                text: "100% \u{f036c}"
                font: micText.font
            }

            Text {
                id: micMetricsMuted
                visible: false

                text: "--- \u{f036d}"
                font: micText.font
            }

            Text {
                id: micText
                anchors.centerIn: parent

                text: volume.source?.audio?.muted ? "--- \u{f036d}" : volume.percent(volume.source) + "% \u{f036c}"
                color: volume.source?.audio?.muted ? Colors.alert : Colors.foreground
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 13
                font.bold: true
            }
        }

        // Salida (altavoces)
        MouseArea {
            implicitWidth: Math.max(sinkText.implicitWidth, sinkMetrics.implicitWidth)
            implicitHeight: sinkText.implicitHeight
            cursorShape: Qt.PointingHandCursor
            onClicked: volume.toggleMute(volume.sink)
            onWheel: wheel => volume.scrollVolume(volume.sink, wheel.angleDelta.y)

            // Solo para medir: el caso más ancho es el volumen de tres cifras.
            Text {
                id: sinkMetrics
                visible: false

                text: "\u{f057e} 100%"
                font: sinkText.font
            }

            Text {
                id: sinkText
                anchors.centerIn: parent

                readonly property int pct: volume.percent(volume.sink)
                // El icono sigue el nivel, como los format-icons de waybar.
                readonly property string icon: volume.sink?.audio?.muted ? "\u{f075f}" : pct === 0 ? "\u{f075f}" : pct < 34 ? "\u{f057f}" : pct < 67 ? "\u{f0580}" : "\u{f057e}"

                text: volume.sink?.audio?.muted ? icon + " ---" : icon + " " + pct + "%"
                color: volume.sink?.audio?.muted ? Colors.alert : Colors.foreground
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 13
                font.bold: true
            }
        }
    }
}
