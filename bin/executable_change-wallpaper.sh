#!/bin/bash

# This file must change the wallpaper to the selected image. It must have the following arguments:
# $1: The path to the image file, a video file, or a Wallpaper Engine scene id
# and the flags:
# --wal: Must apply pywal
# --lock-file: Must create a lockscreen file
#
# Acepta tres tipos de fondo:
#   imagen  -> awww (estático)
#   vídeo   -> mpvpaper, vía wallpaper-video
#   scene   -> linux-wallpaperengine, vía wallpaper-scene (el id numérico)
# pywal y el lockscreen necesitan una imagen fija: para vídeos y scenes se usa
# la miniatura pregenerada por `pregenerate-thumbs`.

# El log va junto al estado de los fondos y no a /tmp: /tmp se borra al
# reiniciar, justo cuando más interesa saber por qué no volvió un fondo.
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper"
LOG_FILE="$STATE_DIR/change.log"
# Al pasar de este tamaño se rota a change.log.1 (se guarda una sola copia).
LOG_MAX_BYTES=$((256 * 1024))
LN_PATH=~/media/images/wallpapers/unsorted/current-wallpaper
LOCK_LN_PATH=~/media/images/wallpapers/unsorted/current-lockscreen
LOCK_CACHE_DIR=~/.cache/lockscreens
THUMB_CACHE_DIR=~/.cache/wallpaper-thumbs
# Los colores del sistema son globales pero cada pantalla puede tener su propio
# fondo, así que sólo el monitor principal decide el tema.
THEME_MONITOR="DP-1"
MONITOR="all"
WORKSHOP_DIR=~/.local/share/Steam/steamapps/workshop/content/431960

# Escribe a stderr y al archivo, nunca a stdout: las funciones que se llaman
# con $(...) devuelven su resultado por stdout, y un log ahí lo ensuciaría
# (antes un "File not found" terminaba guardado como el tipo de fondo).
function log() {
  local level="$1"
  shift
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$level] $*" | tee -a "$LOG_FILE" >&2
}

function rotate_log() {
  mkdir -p "$STATE_DIR"
  local size
  size=$(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0)
  if [ "$size" -gt "$LOG_MAX_BYTES" ]; then
    mv -f "$LOG_FILE" "$LOG_FILE.1"
  fi
}

rotate_log

# Un cambio a la vez: dos clicks seguidos (o uno en cada barra) lanzaban dos
# instancias que se pisaban el symlink, pywal y los procesos de mpvpaper. La
# segunda espera a que termine la primera en vez de abortar, para que el
# último click sea el que gana.
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/change-wallpaper.lock"
exec 9>"$LOCK_FILE"
if ! flock -w 60 9; then
  log ERROR "Otro cambio de fondo lleva más de 60 s en curso; abortando"
  exit 1
fi

if [ -z "$1" ]; then
  log ERROR "No arguments passed"
  echo "Usage: $0 <image_path|video_path|scene_id> [--wal] [--lock-file]"
  exit 1
fi

# Devuelve image, video o scene según lo que sea "$1".
function detect_kind() {
  local target="$1"

  # Una scene se identifica por su id numérico del Workshop, no por una ruta.
  if [[ "$target" =~ ^[0-9]+$ ]]; then
    if [ -d "$WORKSHOP_DIR/$target" ]; then
      echo scene
      return
    fi
    log ERROR "No existe la scene $target"
    exit 1
  fi

  if [ ! -f "$target" ]; then
    log ERROR "File not found: $target"
    exit 1
  fi

  case "${target,,}" in
    *.mp4 | *.webm | *.mkv) echo video ;;
    *) echo image ;;
  esac
}

# La imagen de la que pywal y el lockscreen sacan los colores. Para un fondo
# estático es el propio fichero; para vídeo y scene, su miniatura.
function still_for() {
  local kind="$1" target="$2" still

  case "$kind" in
    image) echo "$target" ;;
    video)
      still="$THUMB_CACHE_DIR/video/$(basename "${target%.*}").jpg"
      [ -f "$still" ] && echo "$still"
      ;;
    scene)
      still="$THUMB_CACHE_DIR/scene/${target}.jpg"
      [ -f "$still" ] && echo "$still"
      ;;
  esac
}

log INFO "Starting wallpaper change with args: $*"

function create_link() {
  if [ -L "$LN_PATH" ]; then
    log DEBUG "Removing existing symlink: $LN_PATH"
    rm "$LN_PATH"
  fi
  ln -sf "$1" "$LN_PATH"
  log INFO "Created symlink: $LN_PATH -> $1"
}

function set_wallpaper() {
  local mon="$1"
  log INFO "Setting wallpaper via awww on $mon"
  # Un fondo animado activo taparía al estático: se quita antes.
  wallpaper-video stop --monitor "$mon" >/dev/null 2>&1
  wallpaper-scene stop --monitor "$mon" >/dev/null 2>&1

  # awww necesita el nombre de la salida; sin -o pinta en todas.
  local outputs=()
  [ "$mon" != "all" ] && outputs=(-o "$mon")

  if awww img "${outputs[@]}" "$LN_PATH" --transition-duration 0.5 --transition-type any ; then
    log INFO "Wallpaper set successfully"
  else
    log ERROR "Failed to set wallpaper (awww exit code: $?)"
    return 1
  fi
}

function set_video() {
  log INFO "Setting video wallpaper on $2: $1"
  if wallpaper-video start --monitor "$2" "$1" >/dev/null 2>&1; then
    log INFO "Video wallpaper started"
  else
    log ERROR "Failed to start video wallpaper (exit code: $?)"
    return 1
  fi
}

function set_scene() {
  log INFO "Setting Wallpaper Engine scene on $2: $1"
  if wallpaper-scene start --monitor "$2" "$1" >/dev/null 2>&1; then
    log INFO "Scene started"
  else
    log ERROR "Failed to start scene (exit code: $?)"
    return 1
  fi
}

function apply_pywal() {
  local still="$1"

  if [ -z "$still" ] || [ ! -f "$still" ]; then
    log WARN "Sin imagen fija para pywal; corre pregenerate-thumbs"
    return
  fi

  log INFO "Applying pywal theme from $still"
  if wal -i "$still" --cols16 --saturate=0.08 -n -q; then
    log INFO "Pywal theme applied successfully"
  else
    log ERROR "Failed to apply pywal theme (exit code: $?)"
  fi
}

# El lockscreen ya no se genera aquí: componer el blur con magick tardaba
# segundos en cada cambio. Ahora se pregeneran todos por lotes y esto solo
# apunta el symlink al que corresponde.
function create_lock_file() {
  local source_image="$1"

  if [ -z "$source_image" ] || [ ! -f "$source_image" ]; then
    log WARN "Sin imagen fija para el lockscreen; corre pregenerate-thumbs"
    return
  fi

  local base
  base=$(basename "$source_image")
  local cached="$LOCK_CACHE_DIR/$base"

  # Los estáticos tienen su lockscreen pregenerado por lotes. Las miniaturas de
  # vídeos y scenes no, así que se compone aquí: son 114 y cambiarían con cada
  # reimportación, y hacerlo al vuelo cuesta menos que mantener otro lote.
  if [ ! -f "$cached" ]; then
    local w h third
    read -r w h < <(identify -format "%w %h" "$source_image" 2>/dev/null)

    if [ -z "${w:-}" ]; then
      log WARN "No se pudo leer $base para el lockscreen"
      return
    fi

    third=$((w / 3))
    log INFO "Componiendo lockscreen para $base"
    if ! magick "$source_image" \( +clone -blur 0x20 \) \
        \( -size "${w}x${h}" xc:black -fill white -draw "rectangle 0,0 ${third},${h}" \) \
        -composite "$cached" 2>/dev/null; then
      log WARN "Falló la composición del lockscreen para $base"
      return
    fi
  fi

  if [ -L "$LOCK_LN_PATH" ]; then
    rm "$LOCK_LN_PATH"
  fi
  ln -sf "$cached" "$LOCK_LN_PATH"
  log INFO "Lockscreen symlink: $LOCK_LN_PATH -> $cached"
}

function main() {
  local target kind still rest=()

  target="$1"
  shift

  # --monitor puede venir en cualquier posición; el resto de flags se procesan
  # después, cuando ya se sabe sobre qué pantalla se aplicó.
  while [ $# -gt 0 ]; do
    case $1 in
      --monitor | -m)
        MONITOR="${2:?--monitor necesita un nombre}"
        shift 2
        ;;
      *)
        rest+=("$1")
        shift
        ;;
    esac
  done
  set -- "${rest[@]+"${rest[@]}"}"

  # detect_kind corre en un subshell: su `exit 1` sólo termina el subshell,
  # así que hay que propagar el fallo a mano o seguiríamos con kind vacío.
  kind=$(detect_kind "$target") || exit 1

  # Una scene es un id, no una ruta: sólo las rutas se resuelven.
  [ "$kind" != "scene" ] && target=$(readlink -f "$target")

  still=$(still_for "$kind" "$target")
  log INFO "Tipo: $kind | monitor: $MONITOR | imagen fija: ${still:-(ninguna)}"

  # Si el fondo no se pudo poner se sale con error sin tocar pywal ni el
  # lockscreen: quien llama (la grilla de Quickshell) usa el código de salida
  # para decidir si marcar el fondo como aplicado.
  case "$kind" in
    image)
      create_link "$target"
      set_wallpaper "$MONITOR" || exit 1
      ;;
    video)
      set_video "$target" "$MONITOR" || exit 1
      ;;
    scene)
      set_scene "$target" "$MONITOR" || exit 1
      ;;
  esac

  while [ $# -gt 0 ]; do
    case $1 in
      --wal | -w)
        # El tema es global: sólo lo redefine la pantalla principal, para que
        # cambiar el fondo de la otra no recoloree el escritorio entero.
        if [ "$MONITOR" = "all" ] || [ "$MONITOR" = "$THEME_MONITOR" ]; then
          apply_pywal "$still"
        else
          log INFO "Sin pywal: $MONITOR no es la pantalla del tema ($THEME_MONITOR)"
        fi
        ;;
      --lock-file | -l)
        if [ "$MONITOR" = "all" ] || [ "$MONITOR" = "$THEME_MONITOR" ]; then
          create_lock_file "$still"
        else
          log INFO "Sin lockscreen: $MONITOR no es la pantalla del tema"
        fi
        ;;
      *)
        log WARN "Unknown flag: $1"
        echo "Usage: $0 <image_path> [--wal] [--lock-file]"
        ;;
    esac
    shift
  done

  log INFO "Wallpaper change completed"
}

main "$@"
