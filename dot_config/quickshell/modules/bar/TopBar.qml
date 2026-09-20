import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts

import "./components/"

PanelWindow {
    id: topPanel

    anchors {
        top: true
        left: true
        right: true
    }
    // Altura fija que ya reserva el espacio de lo que puede desplegarse. No se
    // ajusta al contenido: hacerlo reescalaba la superficie durante la
    // animación y la fila entera daba un salto de un frame al cerrar.
    // No afecta al layout de ventanas, porque la zona exclusiva es barHeight.
    implicitHeight: barHeight + expandRoom
    color: "transparent"

    property real barHeight: 40
    // Espacio para lo que se despliega bajo la barra (el mezclador de volumen
    // es lo más alto y crece con la cantidad de apps sonando). No desplaza
    // ventanas porque la zona exclusiva sigue siendo barHeight.
    property real expandRoom: 460

    // La zona exclusiva se queda en la altura de la barra: lo que se expande
    // flota sobre las ventanas en vez de reacomodarlas.
    exclusiveZone: barHeight

    // Solo la barra recibe clicks; el resto del panel deja pasar el mouse.
    // Solo la barra y lo que esté desplegado reciben clicks; el resto del
    // panel los deja pasar a las ventanas de abajo.
    mask: Region {
        item: content

        Region {
            item: volumeMixer
            intersection: Intersection.Combine
        }

        Region {
            item: globalMenu
            intersection: Intersection.Combine
        }
    }

    margins {
        left: 10
        right: 10
        top: 0
    }

    // Mismo patrón que el mezclador: fuera del RowLayout para quedar dentro
    // del área del panel y poder recibir los clicks.
    GlobalMenu {
        id: globalMenu

        property bool open: false

        anchors.top: content.bottom
        anchors.topMargin: 6
        anchors.left: content.left
        anchors.leftMargin: starButton.x

        visible: opacity > 0
        opacity: open ? 1 : 0
        height: open ? implicitHeight : 0
        clip: true

        Behavior on opacity {
            NumberAnimation {
                duration: 160
            }
        }
    }

    // El mezclador va aquí y no dentro de Volume: colgado del borde inferior
    // de la pill quedaría fuera del área de su padre y QML no le entregaría
    // los eventos de mouse, así que los sliders no responderían.
    VolumeMixer {
        id: volumeMixer
        anchors.top: content.bottom
        anchors.topMargin: 6
        anchors.right: content.right
        anchors.rightMargin: volumeWidget !== null ? content.width - volumeWidget.x - volumeWidget.width : 0

        sink: volumeWidget.sink
        source: volumeWidget.source

        visible: opacity > 0
        opacity: volumeWidget.expanded ? 1 : 0

        // Cerrado no ocupa nada: si conservara su tamaño, la máscara seguiría
        // capturando clicks en esa zona aunque el panel esté invisible.
        height: volumeWidget.expanded ? implicitHeight : 0
        clip: true

        Behavior on opacity {
            NumberAnimation {
                duration: 160
            }
        }
    }

    RowLayout {
        id: content
        // Anclado arriba y con la altura de la barra, no del panel: si siguiera
        // al panel se redimensionaría durante la animación de expandir y toda
        // la fila daría un salto.
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: topPanel.barHeight
        spacing: 4

        StarButton {
            id: starButton
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft

            onSecondaryAction: {
                if (globalMenu.open)
                    globalMenu.open = false;
                else {
                    globalMenu.reset();
                    globalMenu.open = true;
                }
            }
        }

        // Dos grupos, igual que en waybar: DP-1 lleva 1-5 y HDMI-A-1 lleva 6-10.
        Workspaces {
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            workspaceIds: [1, 2, 3, 4, 5]
        }

        Workspaces {
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            workspaceIds: [6, 7, 8, 9, 10]
        }

        Item {
            Layout.fillWidth: true
        }

        SystemMonitor {
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
        }

        Volume {
            id: volumeWidget
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
        }

        Clock {
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
        }
    }
}
