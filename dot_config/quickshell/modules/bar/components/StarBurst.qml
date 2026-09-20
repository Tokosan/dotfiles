import QtQuick
import QtQuick.Particles

import "../../config"

// Ráfaga de estrellitas. Vive fuera del botón para que las partículas puedan
// salir de sus límites sin recortarse.
ParticleSystem {
    id: system

    property color tint: Colors.accent

    function fire(count) {
        emitter.burst(count);
    }

    ImageParticle {
        // Textura propia: la que trae Qt vive dentro del plugin y no se puede
        // abrir desde qrc.
        source: Qt.resolvedUrl("../../../assets/star.png")
        color: system.tint
        colorVariation: 0.35
        // alpha: 0 las dejaba invisibles.
        alpha: 1
        alphaVariation: 0.2
        entryEffect: ImageParticle.Scale
        rotationVariation: 180
        rotationVelocityVariation: 220
    }

    Emitter {
        id: emitter

        // Sin tamaño explícito el emisor mide 0x0 y no llega a emitir.
        width: 8
        height: 8
        emitRate: 0
        lifeSpan: 1100
        lifeSpanVariation: 250
        // Más grandes y con menos caída: antes salían disparadas hacia abajo y
        // se perdían de vista casi de inmediato.
        size: 16
        sizeVariation: 6
        endSize: 4

        velocity: AngleDirection {
            angle: 90
            angleVariation: 85
            magnitude: 70
            magnitudeVariation: 40
        }

        acceleration: PointDirection {
            y: 60
            xVariation: 30
        }
    }

    // Permite posicionar el emisor donde esté el botón.
    function moveTo(x, y) {
        emitter.x = x - emitter.width / 2;
        emitter.y = y - emitter.height / 2;
    }
}
