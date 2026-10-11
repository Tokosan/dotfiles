pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import "../../config"
import "../../common"
import "../../services"

// Vista de wallpapers del menú global. Se crea al abrir la vista y se
// destruye al cerrarla: lista los directorios al nacer y no guarda nada que
// tenga que sobrevivir.
Item {
    id: grid

    signal back

    // La pantalla donde vive esta barra: el fondo se aplica donde se hizo
    // click, sin tener que elegir el monitor a mano.
    required property string monitor

    property string kind: "image"

    readonly property var entries: grid.kind === "video" ? lists.videos : grid.kind === "scene" ? lists.scenes : lists.statics

    implicitHeight: header.implicitHeight + 6 + tabs.implicitHeight + 6 + view.height

    WallpaperApplier {
        id: applier
        monitor: grid.monitor
    }

    WallpaperLists {
        id: lists
    }

    RowLayout {
        id: header
        anchors.top: grid.top
        anchors.left: grid.left
        anchors.right: grid.right
        spacing: 8

        MouseArea {
            id: backButton
            implicitWidth: backIcon.implicitWidth + 8
            implicitHeight: 20
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: grid.back()

            Text {
                id: backIcon
                anchors.centerIn: backButton

                text: "\u{f104}" // angle-left
                color: backButton.containsMouse ? Colors.accent : Colors.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontLg
            }
        }

        // Nombrar la pantalla evita la duda de dónde va a aplicarse, ya que
        // el mismo panel existe en cada monitor.
        SectionHeader {
            Layout.fillWidth: true
            text: "Wallpapers · " + grid.monitor
        }

        Text {
            text: grid.entries.length
            color: Colors.textFaint
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontXs
        }
    }

    TabBar {
        id: tabs
        anchors.top: header.bottom
        anchors.topMargin: 6
        anchors.left: grid.left

        tabs: [
            {
                id: "image",
                label: "Static"
            },
            {
                id: "video",
                label: "Video"
            },
            {
                id: "scene",
                label: "Scene"
            }
        ]
        current: grid.kind
        onSelected: id => {
            if (grid.kind !== id) {
                grid.kind = id;
                Sounds.play("subtle");
            }
        }
    }

    GridView {
        id: view
        anchors.top: tabs.bottom
        anchors.topMargin: 6
        anchors.left: grid.left
        anchors.right: grid.right

        height: 260
        clip: true
        cellWidth: 100
        cellHeight: 62

        model: grid.entries

        delegate: WallpaperTile {
            id: tile

            required property var modelData

            width: view.cellWidth
            height: view.cellHeight
            thumb: tile.modelData.thumb
            kind: tile.modelData.kind
            current: tile.modelData.path === applier.current
            pending: tile.modelData.path === applier.pending || tile.modelData.path === applier.queued?.path
            failed: tile.modelData.path === applier.failed
            onActivated: applier.apply(tile.modelData)
        }
    }
}
