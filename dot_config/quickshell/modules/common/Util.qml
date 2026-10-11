pragma Singleton

import Quickshell
import QtQuick

// Funciones pequeñas que se repiten entre módulos.
Singleton {
    // Ruta local -> URL. Escapa cada segmento: "file://" + ruta a secas rompe
    // con nombres que llevan #, ? o %.
    function fileUrl(path) {
        return "file://" + path.split("/").map(encodeURIComponent).join("/");
    }
}
