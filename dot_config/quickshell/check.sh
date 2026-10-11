#!/usr/bin/env bash
# Verifica la config de Quickshell sin tocar la barra que está corriendo.
#
#   ./check.sh            lint + arranque en frío de prueba (~6 s)
#   ./check.sh --lint     solo qmllint
#
# El arranque de prueba levanta una SEGUNDA instancia desde este directorio
# (la fuente de chezmoi, no ~/.config), abre y cierra el launcher por IPC
# para que cargue, lee su salida y la mata. Durante esos segundos se ven
# barras duplicadas: es normal.
#
# Sale con código != 0 si hay errores de QML o warnings nuevos. Es lo que un
# LLM tiene que correr después de cada cambio, antes de `chezmoi apply`.
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QMLLINT=/usr/lib/qt6/bin/qmllint
status=0

# Warnings de qmllint que son falsos positivos: tipos de Quickshell que la
# herramienta no conoce (PanelWindow, margins, Toplevel de Wayland).
LINT_NOISE='uncreatable-type|Type margins is used|grouped property scope margins|qs::wayland|Unused import'

# Ruido conocido del arranque que no depende de esta config.
RUN_NOISE='Failed to register with host portal|Invalid ICC illuminant|Configuration Loaded|Launching config|Shell ID|Saving logs|Hello|qt.qpa.wayland: eglSwapBuffers'

echo "== qmllint"
lint_out="$(find "$DIR" -name '*.qml' -print0 | sort -z | xargs -0 -n1 "$QMLLINT" 2>&1 |
    grep -E '^(Warning|Error):' | grep -vE "$LINT_NOISE")"
if [[ -n "$lint_out" ]]; then
    echo "$lint_out" | sed "s|$DIR/||"
    echo "-> $(echo "$lint_out" | wc -l) avisos de lint (revisar; no todos son errores)"
else
    echo "ok"
fi

[[ "${1:-}" == "--lint" ]] && exit 0

echo "== arranque de prueba"
out="$(mktemp)"
qs -p "$DIR" >"$out" 2>&1 &
pid=$!
sleep 3
# El launcher vive en un LazyLoader: sin abrirlo, sus errores no aparecen.
qs ipc --pid "$pid" call launcher toggle >/dev/null 2>&1
sleep 1
qs ipc --pid "$pid" call launcher toggle >/dev/null 2>&1
sleep 1
kill "$pid" 2>/dev/null
wait "$pid" 2>/dev/null

problems="$(grep -E 'WARN|ERROR|error|Error' "$out" | grep -vE "$RUN_NOISE")"
if [[ -n "$problems" ]]; then
    echo "$problems" | sed "s|file://$DIR/||g"
    status=1
else
    echo "ok"
fi
rm -f "$out"

exit $status
