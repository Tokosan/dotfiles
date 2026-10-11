import QtQuick
import QtQuick.Layouts

import "../../common"
import "../../services"

// Pill de volumen: micrófono y salida. El click derecho pide abrir el
// mezclador; TopBar decide (es quien maneja los desplegables).
BarPill {
    id: volume

    signal mixerToggleRequested

    contentWidth: row.implicitWidth

    // nf-md-microphone / microphone_off
    readonly property string micOn: "\u{f036c}"
    readonly property string micOff: "\u{f036d}"
    // nf-md-volume_high / low / medium / off
    readonly property string volHigh: "\u{f057e}"
    readonly property string volLow: "\u{f057f}"
    readonly property string volMid: "\u{f0580}"
    readonly property string volOff: "\u{f075f}"

    // El icono sigue el nivel, como los format-icons de waybar.
    function sinkIcon() {
        const pct = Audio.percent(Audio.sink);
        if (Audio.isMuted(Audio.sink) || pct === 0)
            return volume.volOff;
        return pct < 34 ? volume.volLow : pct < 67 ? volume.volMid : volume.volHigh;
    }

    // Detrás de los controles, que solo aceptan izquierdo y medio.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: volume.mixerToggleRequested()
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 12

        AudioControl {
            node: Audio.source
            iconFirst: false
            icon: Audio.isMuted(Audio.source) ? volume.micOff : volume.micOn
            iconGlyphs: [volume.micOn, volume.micOff]
        }

        // Click medio: pasa al siguiente dispositivo de salida.
        AudioControl {
            node: Audio.sink
            icon: volume.sinkIcon()
            iconGlyphs: [volume.volHigh, volume.volLow, volume.volMid, volume.volOff]
            onMiddleClicked: Audio.cycleSink()
        }
    }
}
