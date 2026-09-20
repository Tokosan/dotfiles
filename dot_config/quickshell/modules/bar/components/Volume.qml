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
    // Cuánto cambia el volumen por cada paso de rueda.
    property real step: 0.05

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

    function label(node) {
        return node?.audio?.muted ? "---" : volume.percent(node) + "%";
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

    // Ancho reservado para un porcentaje. Se fija con el caso más largo para
    // que ni la pill ni los iconos se muevan al cambiar de 2 a 3 cifras.
    TextMetrics {
        id: pctMetrics
        font: micPct.font
        text: "100%"
    }

    // El glifo de micrófono tachado no mide igual que el normal; se reserva el
    // mayor para que el icono no se corra al mutear.
    TextMetrics {
        id: micIconMetrics
        font: micIcon.font
        text: "\u{f036c}"
    }

    TextMetrics {
        id: micIconMutedMetrics
        font: micIcon.font
        text: "\u{f036d}"
    }

    // Los cuatro glifos de salida tampoco miden igual entre sí.
    TextMetrics {
        id: sinkIconMetrics
        font: sinkIcon.font
        text: "\u{f057e}"
    }

    TextMetrics {
        id: sinkIconLowMetrics
        font: sinkIcon.font
        text: "\u{f057f}"
    }

    TextMetrics {
        id: sinkIconMedMetrics
        font: sinkIcon.font
        text: "\u{f0580}"
    }

    TextMetrics {
        id: sinkIconOffMetrics
        font: sinkIcon.font
        text: "\u{f075f}"
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 12

        // Entrada (micrófono): número a la derecha, icono después.
        RowLayout {
            spacing: 5

            MouseArea {
                implicitWidth: pctMetrics.width
                implicitHeight: micPct.implicitHeight
                cursorShape: Qt.PointingHandCursor
                onClicked: volume.toggleMute(volume.source)
                onWheel: wheel => volume.scrollVolume(volume.source, wheel.angleDelta.y)

                Text {
                    id: micPct
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    text: volume.label(volume.source)
                    color: volume.source?.audio?.muted ? Colors.alert : Colors.foreground
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                }
            }

            MouseArea {
                implicitWidth: Math.max(micIconMetrics.width, micIconMutedMetrics.width)
                implicitHeight: micIcon.implicitHeight
                cursorShape: Qt.PointingHandCursor
                onClicked: volume.toggleMute(volume.source)
                onWheel: wheel => volume.scrollVolume(volume.source, wheel.angleDelta.y)

                Text {
                    id: micIcon
                    // Anclado a la izquierda y no centrado: el glifo tachado es
                    // más angosto y centrarlo lo correría un píxel.
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: volume.source?.audio?.muted ? "\u{f036d}" : "\u{f036c}"
                    color: volume.source?.audio?.muted ? Colors.alert : Colors.foreground
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                }
            }
        }

        // Salida (altavoces): icono primero, número a la izquierda.
        RowLayout {
            spacing: 5

            MouseArea {
                implicitWidth: Math.max(sinkIconMetrics.width, sinkIconLowMetrics.width, sinkIconMedMetrics.width, sinkIconOffMetrics.width)
                implicitHeight: sinkIcon.implicitHeight
                cursorShape: Qt.PointingHandCursor
                onClicked: volume.toggleMute(volume.sink)
                onWheel: wheel => volume.scrollVolume(volume.sink, wheel.angleDelta.y)

                Text {
                    id: sinkIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    readonly property int pct: volume.percent(volume.sink)
                    // El icono sigue el nivel, como los format-icons de waybar.
                    text: volume.sink?.audio?.muted || pct === 0 ? "\u{f075f}" : pct < 34 ? "\u{f057f}" : pct < 67 ? "\u{f0580}" : "\u{f057e}"
                    color: volume.sink?.audio?.muted ? Colors.alert : Colors.foreground
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                }
            }

            MouseArea {
                implicitWidth: pctMetrics.width
                implicitHeight: sinkPct.implicitHeight
                cursorShape: Qt.PointingHandCursor
                onClicked: volume.toggleMute(volume.sink)
                onWheel: wheel => volume.scrollVolume(volume.sink, wheel.angleDelta.y)

                Text {
                    id: sinkPct
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: volume.label(volume.sink)
                    color: volume.sink?.audio?.muted ? Colors.alert : Colors.foreground
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                }
            }
        }
    }
}
