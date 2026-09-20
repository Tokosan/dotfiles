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

    // Panel del mezclador, desplegable con el click derecho.
    property bool expanded: false

    implicitWidth: row.implicitWidth + hPadding * 2
    implicitHeight: barHeight

    color: Colors.barBackground
    bottomLeftRadius: bottomRadius
    bottomRightRadius: bottomRadius

    // Sin esto los nodos no reportan volumen ni mute.
    PwObjectTracker {
        objects: [volume.sink, volume.source]
    }

    // Click derecho en cualquier parte de la pill abre el mezclador. Va detrás
    // de las zonas de cada canal, que solo aceptan el botón izquierdo.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: volume.expanded = !volume.expanded
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

    // Color del texto según estado: muteado manda sobre el hover.
    function textColor(node, hovered) {
        if (node?.audio?.muted)
            return Colors.alert;

        return hovered ? Colors.accent : Colors.foreground;
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

    // El mezclador cuelga bajo la pill sin participar de su layout, así no
    // desplaza nada de la barra: la pill queda como el palo de una T.
    VolumeMixer {
        id: mixer
        anchors.top: parent.bottom
        anchors.topMargin: 6
        anchors.right: parent.right

        sink: volume.sink
        source: volume.source

        visible: opacity > 0
        opacity: volume.expanded ? 1 : 0
        // Se despliega desde arriba.
        transform: Scale {
            origin.x: mixer.width
            origin.y: 0
            yScale: volume.expanded ? 1 : 0.85
            xScale: 1

            Behavior on yScale {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 160
            }
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 12

        // Entrada (micrófono). Un solo MouseArea cubre número, icono y el
        // espacio entre ambos, que antes quedaba muerto al click.
        MouseArea {
            id: micArea

            readonly property real gap: 5

            implicitWidth: pctMetrics.width + gap + Math.max(micIconMetrics.width, micIconMutedMetrics.width)
            implicitHeight: micPct.implicitHeight
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: volume.toggleMute(volume.source)
            onWheel: wheel => volume.scrollVolume(volume.source, wheel.angleDelta.y)

            Text {
                id: micPct
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                width: pctMetrics.width
                horizontalAlignment: Text.AlignRight

                text: volume.label(volume.source)
                color: volume.textColor(volume.source, micArea.containsMouse)
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 13
                font.bold: true

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }

            Text {
                id: micIcon
                anchors.left: micPct.right
                anchors.leftMargin: micArea.gap
                anchors.verticalCenter: parent.verticalCenter

                text: volume.source?.audio?.muted ? "\u{f036d}" : "\u{f036c}"
                color: volume.textColor(volume.source, micArea.containsMouse)
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 13
                font.bold: true

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }
        }

        // Salida (altavoces): icono primero, número después.
        MouseArea {
            id: sinkArea

            readonly property real gap: 5
            readonly property real iconWidth: Math.max(sinkIconMetrics.width, sinkIconLowMetrics.width, sinkIconMedMetrics.width, sinkIconOffMetrics.width)

            implicitWidth: iconWidth + gap + pctMetrics.width
            implicitHeight: sinkPct.implicitHeight
            hoverEnabled: true
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
                color: volume.textColor(volume.sink, sinkArea.containsMouse)
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 13
                font.bold: true

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }

            Text {
                id: sinkPct
                anchors.left: parent.left
                anchors.leftMargin: sinkArea.iconWidth + sinkArea.gap
                anchors.verticalCenter: parent.verticalCenter

                width: pctMetrics.width
                horizontalAlignment: Text.AlignLeft

                text: volume.label(volume.sink)
                color: volume.textColor(volume.sink, sinkArea.containsMouse)
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 13
                font.bold: true

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }
            }
        }
    }
}
