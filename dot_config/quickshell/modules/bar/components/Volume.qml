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
            implicitWidth: micText.implicitWidth
            implicitHeight: micText.implicitHeight
            onWheel: wheel => volume.scrollVolume(volume.source, wheel.angleDelta.y)

            Text {
                id: micText
                anchors.centerIn: parent

                text: volume.source?.audio?.muted ? "--- \u{f036d}" : volume.percent(volume.source) + "% \u{f036c}"
                color: Colors.foreground
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 13
                font.bold: true
            }
        }

        // Salida (altavoces)
        MouseArea {
            implicitWidth: sinkText.implicitWidth
            implicitHeight: sinkText.implicitHeight
            onWheel: wheel => volume.scrollVolume(volume.sink, wheel.angleDelta.y)

            Text {
                id: sinkText
                anchors.centerIn: parent

                readonly property int pct: volume.percent(volume.sink)
                // El icono sigue el nivel, como los format-icons de waybar.
                readonly property string icon: volume.sink?.audio?.muted ? "\u{f075f}" : pct === 0 ? "\u{f075f}" : pct < 34 ? "\u{f057f}" : pct < 67 ? "\u{f0580}" : "\u{f057e}"

                text: volume.sink?.audio?.muted ? icon + " ---" : icon + " " + pct + "%"
                color: Colors.foreground
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 13
                font.bold: true
            }
        }
    }
}
