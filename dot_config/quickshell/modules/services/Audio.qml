pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

import "../config"

// Estado y acciones de audio (PipeWire) para toda la shell. Los widgets solo
// pintan y llaman a estas funciones; así el paso de la rueda, el formato del
// porcentaje o los alias de dispositivos se cambian en un solo sitio.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    // Dispositivos de salida, ordenados por id para que el ciclo con el click
    // medio sea estable.
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio).sort((a, b) => a.id - b.id)
    // Streams de aplicaciones que están sonando.
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isSink && n.isStream && n.audio)

    // Sin tracker los nodos no reportan volumen ni mute. Uno solo para toda
    // la shell, y solo sobre nodos de audio (los de vídeo no hacen falta).
    PwObjectTracker {
        objects: Pipewire.nodes.values.filter(n => n.audio)
    }

    // Alias para acortar los nombres que reporta PipeWire. Se buscan por
    // node.name, que es estable. Solo afectan a esta shell.
    readonly property var deviceAliases: [
        {
            match: "hdmi",
            label: "Headphones"
        },
        {
            match: "analog-stereo",
            label: "Speakers"
        }
    ]

    function percent(node) {
        return Math.round((node?.audio?.volume ?? 0) * 100);
    }

    // "---" si está muteado, si no "N%".
    function label(node) {
        return node?.audio?.muted ? "---" : root.percent(node) + "%";
    }

    function isMuted(node) {
        return node?.audio?.muted ?? false;
    }

    function nodeLabel(node) {
        const name = (node?.name ?? "").toLowerCase();
        for (const alias of root.deviceAliases) {
            if (name.includes(alias.match))
                return alias.label;
        }
        // Sin alias: el nick es más corto que la descripción completa.
        return node?.nickname || node?.description || node?.name || "?";
    }

    function toggleMute(node) {
        const audio = node?.audio;
        if (audio)
            audio.muted = !audio.muted;
    }

    function setVolume(node, value) {
        const audio = node?.audio;
        if (audio)
            audio.volume = Math.max(0, Math.min(1, value));
    }

    // Un paso de rueda: delta > 0 sube, < 0 baja.
    function nudge(node, delta) {
        const audio = node?.audio;
        if (audio)
            root.setVolume(node, audio.volume + (delta > 0 ? 1 : -1) * Settings.volumeStep);
    }

    // Cambia la salida por defecto. Es asíncrono: `sink` se actualiza cuando
    // PipeWire lo confirma.
    function setDefaultSink(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function cycleSink() {
        const list = root.sinks;
        if (list.length < 2)
            return;
        const current = list.findIndex(n => n.id === root.sink?.id);
        root.setDefaultSink(list[(current + 1) % list.length]);
    }
}
