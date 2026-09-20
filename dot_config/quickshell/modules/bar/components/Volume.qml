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

    function percent(node) {
        return Math.round((node?.audio?.volume ?? 0) * 100);
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 10

        // Entrada (micrófono)
        Text {
            text: volume.source?.audio?.muted ? "--- \u{f036d}" : volume.percent(volume.source) + "% \u{f036c}"
            color: Colors.foreground
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 13
            font.bold: true
        }

        // Salida (altavoces)
        Text {
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
