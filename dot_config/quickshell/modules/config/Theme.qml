pragma Singleton

import Quickshell
import QtQuick

// Medidas, tipografía y tiempos compartidos. Los colores van aparte, en
// Colors.qml. Si un número de estilo se repite en dos archivos, va aquí.
Singleton {
    id: root

    // ── Tipografía ────────────────────────────────────────────────────
    readonly property string fontFamily: "JetBrains Mono Nerd Font"

    readonly property int fontBadge: 7       // distintivos sobre miniaturas
    readonly property int fontXs: 9          // cabeceras de sección, contadores
    readonly property int fontSm: 10         // pestañas, etiquetas secundarias
    readonly property int fontBody: 11       // texto de paneles y menús
    readonly property int fontMd: 12         // iconos de menú, búsqueda
    readonly property int fontBar: 13        // texto de las pills de la barra
    readonly property int fontLg: 14         // iconos de navegación (volver)
    readonly property int fontXl: 15         // estrella de la esquina
    readonly property int fontIconLarge: 32  // icono de fallback del launcher

    // ── Barra ─────────────────────────────────────────────────────────
    // Alto de la franja que reservan las ventanas (exclusiveZone).
    readonly property real barHeight: 40
    // Alto de cada pill colgante: todas iguales para que la barra se vea pareja.
    readonly property real pillHeight: 34
    // Radio de las esquinas inferiores de las pills.
    readonly property real pillRadius: 15
    readonly property real pillSpacing: 4
    // Diámetro del círculo de un workspace vacío.
    readonly property real workspaceSize: 26

    // ── Paneles flotantes (menú, mezclador, launcher) ─────────────────
    readonly property real panelRadius: 15
    readonly property real panelBorderWidth: 2
    readonly property real panelPadding: 12
    // Separación entre la barra y un desplegable que cuelga de ella.
    readonly property real dropdownGap: 6
    // Radio de los elementos dentro de un panel (filas, pestañas, tiles).
    readonly property real itemRadius: 7

    // ── Launcher ──────────────────────────────────────────────────────
    readonly property real launcherWidth: 620
    readonly property real launcherHeight: 470
    // Columnas de las grillas de apps; el ancho de celda sale de dividir.
    readonly property int launcherColumns: 6
    readonly property real launcherCellHeight: 88
    readonly property real launcherIconSize: 40
    readonly property real launcherSearchHeight: 34
    // Radio del campo de búsqueda y de los tiles: más redondo que itemRadius
    // porque son elementos más grandes.
    readonly property real launcherTileRadius: 10

    // ── Animaciones ───────────────────────────────────────────────────
    readonly property int animFast: 120      // color de hover
    readonly property int animNormal: 160    // abrir/cerrar paneles
    readonly property int animSlow: 200      // cambios de tamaño
    readonly property int easing: Easing.OutCubic
}
