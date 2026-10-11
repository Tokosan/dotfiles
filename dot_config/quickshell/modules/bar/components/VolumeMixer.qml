pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import "../../config"
import "../../common"
import "../../services"

// Desplegable del volumen: elegir salida y volumen por aplicación. Lo abre y
// cierra TopBar con `open` (heredado de Panel).
Panel {
    id: mixer

    // Tope de la lista de apps: más allá hace scroll en vez de crecer y
    // cortarse contra el borde del panel de la barra (expandRoom).
    readonly property real maxStreamsHeight: 260

    implicitWidth: 300
    implicitHeight: content.implicitHeight + Theme.panelPadding * 2

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.panelPadding

        spacing: 10

        // ── Dispositivos de salida ────────────────────────────────────
        SectionHeader {
            Layout.fillWidth: true
            text: "Devices"
        }

        // ScriptModel y no el array a secas: con un array, cada cambio en
        // PipeWire recrearía todas las filas (y cortaría un arrastre).
        Repeater {
            model: ScriptModel {
                values: Audio.sinks
            }

            delegate: MouseArea {
                id: deviceRow
                required property PwNode modelData

                readonly property bool isActive: deviceRow.modelData?.id === Audio.sink?.id

                Layout.fillWidth: true
                implicitHeight: 24
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Audio.setDefaultSink(deviceRow.modelData)

                RowLayout {
                    anchors.fill: parent
                    spacing: 7

                    Text {
                        // nf-md-circle_medium / circle_outline: lleno si es el activo.
                        text: deviceRow.isActive ? "\u{f0765}" : "\u{f0766}"
                        color: deviceRow.isActive ? Colors.accent : Colors.textMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animFast
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text: Audio.nodeLabel(deviceRow.modelData)
                        elide: Text.ElideRight
                        color: deviceRow.isActive ? Colors.text : deviceRow.containsMouse ? Colors.accent : Colors.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animFast
                            }
                        }
                    }
                }
            }
        }

        // ── Volumen por aplicación ────────────────────────────────────
        SectionHeader {
            Layout.fillWidth: true
            text: "Applications"
        }

        Text {
            Layout.fillWidth: true

            visible: Audio.streams.length === 0
            text: "Nothing playing"
            color: Colors.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            font.italic: true
        }

        ListView {
            id: streamList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(streamList.contentHeight, mixer.maxStreamsHeight)

            visible: Audio.streams.length > 0
            clip: true
            spacing: 10
            boundsBehavior: Flickable.StopAtBounds

            model: ScriptModel {
                values: Audio.streams
            }

            delegate: MixerRow {
                required property PwNode modelData

                width: streamList.width
                // nf-md-application_outline
                icon: "\u{f075a}"
                label: Audio.nodeLabel(modelData)
                node: modelData
            }
        }
    }
}
