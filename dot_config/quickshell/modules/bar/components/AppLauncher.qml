import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../../config"

Item {
    id: launcher

    signal back
    signal launched

    property string filter: ""
    property var apps: []
    readonly property var visibleApps: {
        const needle = launcher.filter.trim().toLowerCase();
        if (!needle)
            return launcher.apps;

        return launcher.apps.filter(a => a.name.toLowerCase().includes(needle) || a.comment.toLowerCase().includes(needle));
    }

    implicitHeight: header.implicitHeight + 6 + list.height

    function launch(app) {
        // gtk-launch resuelve el .desktop completo (acciones, terminal, %U).
        runner.command = ["sh", "-c", `gtk-launch '${app.id}' >/dev/null 2>&1 &`];
        runner.running = true;
        launcher.launched();
    }

    Process {
        id: runner
    }

    // Lee los .desktop y arma la lista: id, nombre y descripción.
    Process {
        id: scanner
        running: true
        command: ["sh", "-c", `
            for dir in /usr/share/applications "$HOME/.local/share/applications" /var/lib/flatpak/exports/share/applications; do
                [ -d "$dir" ] || continue
                for f in "$dir"/*.desktop; do
                    [ -f "$f" ] || continue
                    grep -q '^NoDisplay=true' "$f" && continue
                    grep -q '^Hidden=true' "$f" && continue
                    name=$(grep -m1 '^Name=' "$f" | cut -d= -f2-)
                    comment=$(grep -m1 '^Comment=' "$f" | cut -d= -f2-)
                    [ -n "$name" ] && printf '%s\\t%s\\t%s\\n' "$(basename "$f")" "$name" "$comment"
                done
            done | sort -t"$(printf '\\t')" -k2 -f -u
        `]

        stdout: StdioCollector {
            onStreamFinished: {
                const seen = ({});
                const out = [];

                for (const line of text.trim().split("\n")) {
                    if (!line)
                        continue;

                    const parts = line.split("\t");
                    if (parts.length < 2)
                        continue;

                    const name = parts[1];
                    // Varios directorios pueden traer la misma app.
                    if (seen[name])
                        continue;

                    seen[name] = true;
                    out.push({
                        id: parts[0],
                        name: name,
                        comment: parts[2] ?? ""
                    });
                }

                launcher.apps = out;
            }
        }
    }

    RowLayout {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        MouseArea {
            implicitWidth: backIcon.implicitWidth + 8
            implicitHeight: 20
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: launcher.back()

            Text {
                id: backIcon
                anchors.centerIn: parent

                text: "\u{f104}"
                color: parent.containsMouse ? Colors.accent : Colors.foreground
                font.family: "JetBrains Mono Nerd Font"
                font.pixelSize: 14
            }
        }

        // Campo de búsqueda difusa.
        TextInput {
            id: search
            Layout.fillWidth: true

            text: launcher.filter
            onTextChanged: launcher.filter = text
            color: Colors.foreground
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 11
            clip: true
            focus: true

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                visible: search.text.length === 0
                text: "Search apps…"
                color: Qt.alpha(Colors.foreground, 0.35)
                font: search.font
            }

            Keys.onEscapePressed: launcher.back()
            Keys.onReturnPressed: {
                if (launcher.visibleApps.length > 0)
                    launcher.launch(launcher.visibleApps[list.currentIndex >= 0 ? list.currentIndex : 0]);
            }
            Keys.onDownPressed: list.currentIndex = Math.min(list.currentIndex + 1, launcher.visibleApps.length - 1)
            Keys.onUpPressed: list.currentIndex = Math.max(list.currentIndex - 1, 0)
        }

        Text {
            text: launcher.visibleApps.length
            color: Qt.alpha(Colors.foreground, 0.4)
            font.family: "JetBrains Mono Nerd Font"
            font.pixelSize: 9
        }
    }

    ListView {
        id: list
        anchors.top: header.bottom
        anchors.topMargin: 6
        anchors.left: parent.left
        anchors.right: parent.right

        height: 260
        clip: true
        currentIndex: 0
        model: launcher.visibleApps

        delegate: MouseArea {
            required property var modelData
            required property int index

            width: list.width
            implicitHeight: 28
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: launcher.launch(modelData)
            onEntered: list.currentIndex = index

            Rectangle {
                anchors.fill: parent
                anchors.rightMargin: 4
                radius: 7
                color: index === list.currentIndex ? Qt.alpha(Colors.foreground, 0.1) : "transparent"
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 0

                Text {
                    Layout.fillWidth: true

                    text: modelData.name
                    elide: Text.ElideRight
                    color: Colors.foreground
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 11
                }

                Text {
                    Layout.fillWidth: true

                    visible: modelData.comment.length > 0
                    text: modelData.comment
                    elide: Text.ElideRight
                    color: Qt.alpha(Colors.foreground, 0.4)
                    font.family: "JetBrains Mono Nerd Font"
                    font.pixelSize: 9
                }
            }
        }
    }
}
