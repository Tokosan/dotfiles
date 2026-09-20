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
        // Se dibuja la estrella con un shader en vez de cargar una imagen.
        source: "qrc:///qt-project.org/imports/QtQuick/Particles/particleresources/star.png"
        color: system.tint
        colorVariation: 0.35
        alpha: 0
        entryEffect: ImageParticle.Scale
        rotationVariation: 180
        rotationVelocityVariation: 220
    }

    Emitter {
        id: emitter

        emitRate: 0
        lifeSpan: 900
        lifeSpanVariation: 300
        size: 9
        sizeVariation: 5
        endSize: 2

        velocity: AngleDirection {
            angle: 90
            angleVariation: 75
            magnitude: 110
            magnitudeVariation: 55
        }

        acceleration: PointDirection {
            y: 160
            xVariation: 40
        }
    }

    // Permite posicionar el emisor donde esté el botón.
    function moveTo(x, y) {
        emitter.x = x;
        emitter.y = y;
    }
}
