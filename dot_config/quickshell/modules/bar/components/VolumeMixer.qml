import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import "../../config"

Rectangle {
    id: mixer

    required property PwNode sink
    required property PwNode source

    property real padding: 12
    property real radiusValue: 15

    implicitWidth: 300
    implicitHeight: content.implicitHeight + padding * 2

    // Más opaco que la barra: flota sobre el wallpaper y tiene que leerse.
    color: Colors.panelBackground
    radius: radiusValue

    border.width: 2
    border.color: Colors.panelBorder

    // La sombra necesita que el panel se renderice en su propia capa.
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Colors.panelShadow
        shadowBlur: 0.7
        shadowVerticalOffset: 4
        shadowOpacity: 0.55
    }

    // Todos los nodos deben estar registrados o no reportan volumen.
    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    // Dispositivos de salida disponibles.
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    // Streams de aplicaciones que están sonando.
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isSink && n.isStream && n.audio)

    function nodeLabel(node) {
        return node?.description || node?.name || "?";
    }

    function percentOf(node) {
        return Math.round((node?.audio?.volume ?? 0) * 100);
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: mixer.padding

        spacing: 10

        // ── Salida y entrada ──────────────────────────────────────────
        MixerRow {
            Layout.fillWidth: true
            icon: "\u{f057e}"
            label: "Salida"
            node: mixer.sink
        }

        MixerRow {
            Layout.fillWidth: true
            icon: "\u{f036c}"
            label: "Entrada"
            node: mixer.source
        }

        // ── Dispositivos de salida ────────────────────────────────────
        MixerHeader {
            Layout.fillWidth: true
            text: "Dispositivos"
            visible: mixer.sinks.length > 1
        }

        Repeater {
            model: mixer.sinks.length > 1 ? mixer.sinks : []

            delegate: MouseArea {
                required property PwNode modelData

                readonly property bool isActive: modelData?.id === mixer.sink?.id

                Layout.fillWidth: true
                implicitHeight: 22
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Pipewire.preferredDefaultAudioSink = modelData

                RowLayout {
                    anchors.fill: parent
                    spacing: 7

                    Text {
                        // Punto lleno si es el activo.
                        text: parent.parent.isActive ? "\u{f0765}" : "\u{f0766}"
                        color: parent.parent.isActive ? Colors.accent : Qt.alpha(Colors.foreground, 0.5)
                        font.family: "JetBrains Mono Nerd Font"
                        font.pixelSize: 11
                    }

                    Text {
                        Layout.fillWidth: true

                        text: mixer.nodeLabel(parent.parent.modelData)
                        elide: Text.ElideRight
                        color: parent.parent.isActive ? Colors.foreground : Qt.alpha(Colors.foreground, 0.6)
                        font.family: "JetBrains Mono Nerd Font"
                        font.pixelSize: 11
                    }
                }
            }
        }

        // ── Volumen por aplicación ────────────────────────────────────
        MixerHeader {
            Layout.fillWidth: true
            text: "Aplicaciones"
        }

        Text {
            Layout.fillWidth: true

            visible: mixer.streams.length === 0
            text: "Nada reproduciéndose"
            color: Qt.alpha(Colors.foreground, 0.45)
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 11
            font.italic: true
        }

        Repeater {
            model: mixer.streams

            delegate: MixerRow {
                required property PwNode modelData

                Layout.fillWidth: true
                icon: "\u{f075a}"
                label: mixer.nodeLabel(modelData)
                node: modelData
            }
        }
    }
}
