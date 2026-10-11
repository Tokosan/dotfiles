pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

import "../../config"

// Los fondos disponibles, por tipo. Lista los directorios una sola vez, al
// crearse: la grilla vive sólo mientras su vista está abierta.
//
// Cada entrada es { path, thumb, kind }: `path` es lo que se le pasa al script
// (ruta o id de scene) y `thumb` lo que se pinta en la grilla.
Scope {
    id: lists

    property var statics: []
    property var videos: []
    property var scenes: []

    // Lista los archivos de `dir` cuyo nombre calza con algún patrón. find va
    // como array (sin sh -c: una comilla en la ruta rompía el comando) y con
    // -print0, porque un nombre puede llevar saltos de línea pero nunca un
    // NUL. El orden se hace aquí y no con `sort`, que exigiría un shell.
    component FileList: Process {
        id: lister

        required property string dir
        required property var patterns

        signal listed(var paths)

        running: true
        command: {
            // ( -iname a -o -iname b ... ): un patrón por extensión.
            const names = [];
            for (const pattern of lister.patterns) {
                if (names.length > 0)
                    names.push("-o");
                names.push("-iname", pattern);
            }
            return ["find", lister.dir, "-maxdepth", "1", "-type", "f", "(", ...names, ")", "-print0"];
        }

        stdout: StdioCollector {
            id: listOut
            onStreamFinished: lister.listed(listOut.text.split("\0").filter(p => p.length > 0).sort((a, b) => a.localeCompare(b)))
        }
    }

    // -type f deja fuera los symlinks que mantiene el propio script
    // (current-wallpaper, current-lockscreen).
    FileList {
        dir: Settings.wallpaperDir
        patterns: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        onListed: paths => lists.statics = paths.map(p => ({
                    path: p,
                    thumb: p,
                    kind: "image"
                }))
    }

    // Los vídeos se muestran con la miniatura que pregenera `pregenerate-thumbs`;
    // un QML no puede sacar un fotograma de un mp4 por sí solo.
    FileList {
        dir: Settings.videoWallpaperDir
        patterns: ["*.mp4", "*.webm", "*.mkv"]
        onListed: paths => lists.videos = paths.map(p => ({
                    path: p,
                    thumb: `${Settings.wallpaperThumbDir}/video/${p.split("/").pop().replace(/\.[^.]+$/, "")}.jpg`,
                    kind: "video"
                }))
    }

    // Una scene se aplica por su id del Workshop, no por una ruta, así que se
    // listan desde el directorio de miniaturas ya generadas.
    FileList {
        dir: `${Settings.wallpaperThumbDir}/scene`
        patterns: ["*.jpg"]
        onListed: paths => lists.scenes = paths.map(p => ({
                    path: p.split("/").pop().replace(/\.jpg$/, ""),
                    thumb: p,
                    kind: "scene"
                }))
    }
}
