# CLAUDE.md — Quickshell

Barra superior, menús y launcher de Hyprland, hechos en Quickshell (QML).
Reemplaza a Waybar. Lo pendiente está en `TODO.md`.

El dueño no programa en QML: todo cambio lo hace un LLM. Prioridad: que el
próximo LLM entienda el código leyendo poco. Ante la duda, más simple y más
explícito.

## Flujo de trabajo (siempre)

1. Editar aquí: `~/.local/share/chezmoi/dot_config/quickshell` (fuente de
   chezmoi). Nunca en `~/.config/quickshell`: chezmoi lo pisa.
2. Verificar: `./check.sh` en este directorio. Corre `qmllint` y levanta una
   instancia de prueba durante ~6 s (se ven barras duplicadas: normal), abre
   el launcher por IPC y falla si aparece un error o warning nuevo. **No
   aplicar nada que no pase `check.sh`.** Los avisos de lint no siempre son
   errores, pero los de tus archivos hay que mirarlos.
3. Aplicar: `chezmoi apply ~/.config/quickshell`. Quickshell recarga en
   caliente. Tras cambiar imports o `qmldir`, reinicio completo
   (`SUPER+SHIFT+R`, o `pkill -x qs; sleep 0.2; qs -p ~/.config/quickshell -d`):
   la recarga en caliente puede decir "Configuration Loaded" aunque el
   arranque en frío falle.
4. Probar a mano lo que `check.sh` no ve: clicks, desplegables, hover.

Otras herramientas:

- Logs de la instancia en uso: `qs log -p ~/.config/quickshell`
  (`-t 50` para las últimas líneas).
- IPC: `qs ipc show` lista los handlers; `qs ipc call launcher toggle`.
- Formato: `qmlformat` (en `~/.local/bin`): 4 espacios, una propiedad por línea.
- Versión: Quickshell 0.3.x (`quickshell-git`). Referencia de API:
  https://quickshell.org/docs/

## Arquitectura

Cuatro capas. Cada una solo importa las de arriba:

```
config/    QUÉ se ve y QUÉ prefiere el usuario   (singletons, sin lógica)
services/  DATOS y ACCIONES del sistema          (singletons, sin UI)
common/    PIEZAS de UI reutilizables            (componentes genéricos)
bar/, launcher/   PANTALLAS                      (arman piezas, leen servicios)
```

Regla principal: **los componentes visuales no hablan con el sistema.** Leer
PipeWire, `/proc`, lanzar procesos, escribir archivos → en un servicio (o en
el `*State.qml` del módulo). La vista solo pinta y llama funciones.

```
shell.qml                         Una TopBar por monitor (Variants) + el Launcher
check.sh                          Verificación (ver arriba)

modules/config/                   (qmldir: todo lo de aquí debe estar listado)
  Theme.qml       Tipografía, medidas de barra/paneles, duraciones
  Colors.qml      Roles de color (pywal + fallback). Único sitio con colores
  Settings.qml    Preferencias: grupos de workspaces, terminal, intervalos,
                  rutas de wallpapers

modules/services/                 (qmldir)
  Audio.qml       PipeWire: sink/source/streams, mute, volumen, alias
  SystemStats.qml CPU/RAM/GPU/temperaturas, un solo poll para todas las barras
  Sounds.qml      Chime de feedback: Sounds.play("subtle"|"soft"|"normal"|"strong")

modules/common/                   (qmldir)
  BarPill.qml     Base de toda pill de la barra
  BarText.qml     Text con la tipografía de la barra y hover animado
  Panel.qml       Tarjeta flotante (fondo, borde, sombra) con open/close
  TabBar.qml      Fila de pestañas
  SectionHeader.qml  Título de sección "DEVICES ───"
  Util.qml        Util.fileUrl(ruta)

modules/bar/TopBar.qml            La barra de un monitor: fila de pills +
                                  desplegables (openPanel)
modules/bar/components/           Pills y paneles de la barra (sin qmldir)
  StarButton, StarBurst           Botón de la esquina y su ráfaga
  Workspaces, WorkspaceButton     Grupo de workspaces e iconos de apps
  SystemMonitor, Stat             CPU/RAM/GPU
  Volume, AudioControl            Pill de volumen (mic + salida)
  VolumeMixer, MixerRow, VolumeSlider   Desplegable del mezclador
  Clock
  GlobalMenu, MenuEntry           Menú del click derecho en la estrella
  WallpaperGrid                   Vista de wallpapers del menú (vive en un Loader)
  WallpaperLists                  Lista los fondos de disco (imagen/vídeo/scene)
  WallpaperApplier                Corre change-wallpaper.sh y sabe el fondo actual
  WallpaperTile                   Una miniatura

modules/launcher/                 (qmldir)
  Launcher.qml        Entrada: IpcHandler "launcher" + ventana bajo demanda
  LauncherState.qml   Singleton: abierto, pantalla, favoritos (API pública:
                      show(screen), close(), toggle(screen), toggleFavorite…)
  FavoritesStore.qml  Lee/guarda launcher.json (esquema, migración, backup)
  AppCatalog.qml      Singleton: apps instaladas, búsqueda, cómo lanzar
  LauncherWindow.qml  Velo + tarjeta; orquesta las piezas de abajo
  SearchField, LauncherTabs, AllAppsGrid, FavoritesGrid, FavoriteDelegate,
  AppTile, EmptyMessage, StoreWarning     Piezas visuales

assets/                           chime.wav, star.png
```

Scripts que la shell invoca: `bin/executable_change-wallpaper.sh` (→ `~/bin`)
y `dot_local/bin/executable_wallpaper-*` (→ `~/.local/bin`), en la raíz del
repo de chezmoi.

## Recetas

**Cambiar un color, tamaño, fuente o duración.** Solo en `Colors.qml` o
`Theme.qml`. Si el valor que buscas no existe como rol/token, créalo ahí con
un comentario de para qué sirve, y úsalo. Nunca un hex, `Qt.alpha(...)`, nombre
de fuente o número de ms en un componente.

**Cambiar una preferencia** (terminal, workspaces, rutas, intervalos):
`Settings.qml`.

**Icono de una app en los workspaces:** agregar una entrada a `iconMap` en
`bar/components/WorkspaceButton.qml` (`match: (cls, title) => ...`, glifo como
escape `"\u{...}"`). Lo específico va antes que lo genérico.

**Agregar una pill a la barra:**
1. Si necesita datos del sistema, primero un servicio en `services/`
   (singleton + línea en `services/qmldir`).
2. `bar/components/MiPill.qml`:
   ```qml
   import QtQuick
   import "../../common"
   import "../../services"

   BarPill {
       id: miPill
       contentWidth: label.implicitWidth
       BarText { id: label; anchors.centerIn: parent; text: MiServicio.valor }
   }
   ```
3. Instanciarla en la fila `content` de `TopBar.qml`, con
   `Layout.alignment: Qt.AlignTop | Qt.AlignRight` (o `AlignLeft`).

**Agregar un desplegable bajo la barra:**
1. El panel es un `Panel { ... }` (en `bar/components/`), con `implicitWidth`
   e `implicitHeight` calculados de su contenido.
2. La pill que lo abre declara una señal (`signal fooToggleRequested`) y
   emite en el click; no decide nada.
3. En `TopBar.qml`:
   - instanciar el panel junto a los otros desplegables, con
     `anchors.top: content.bottom`, `anchors.topMargin: Theme.dropdownGap` y
     `open: topPanel.openPanel === "foo"`;
   - conectar la señal: `onFooToggleRequested: topPanel.togglePanel("foo")`;
   - **agregar una `Region { item: elPanel; intersection: Intersection.Combine }`
     a `mask`**, o no recibirá clicks.
   La exclusión mutua y el cierre con click fuera salen solos.
4. Si es más alto que `expandRoom` (460), darle scroll (ver `VolumeMixer`).

**Agregar una entrada al menú:** un `MenuEntry` más en `GlobalMenu.qml`. Si
la acción es destructiva, usar `menu.confirm(...)` como Reboot/Shutdown.

**Lanzar un programa:** `Quickshell.execDetached(["prog", "arg"])` o un
`Process` con `command: [...]`. **Siempre como array.** Nunca `sh -c` con
valores interpolados (rompe con comillas en rutas y abre inyección).

## Convenciones

- Colores solo por roles de `Colors`; medidas y tipografía por `Theme`.
- Archivos con `Repeater`/delegates/`Loader` empiezan con
  `pragma ComponentBehavior: Bound`, y todo se referencia con `id.`
  explícito: nada de `parent.` ni `modelData` sin prefijo. `qmllint` lo marca
  como `[unqualified]`.
- Modelos de listas que cambian (PipeWire, Hyprland): `ScriptModel { values: ... }`
  o una lista fija de ids. Un array JS recalculado como modelo recrea todos
  los delegates en cada cambio (se pierden animaciones, hover y arrastres).
- Nada de `SoundEffect`/`MediaPlayer` (QtMultimedia): ver "Logs". Sonidos
  con `Sounds.play()`.
- Lo que no se ve no existe: vistas grandes en `Loader`/`LazyLoader`
  (`active:` según si se muestran), sobre todo si lanzan procesos.
- Componentes exponen `signal`s; el contenedor decide qué hacer.
- Texto visible de la UI en **inglés**; comentarios en **español** y
  explicando el *porqué*. Un comentario desactualizado es peor que ninguno:
  al cambiar algo, revisar los comentarios de alrededor.
- Iconos Nerd Font como escapes `"\u{f005}"` con su nombre en un comentario
  (`// nf-fa-star`).
- Archivos cortos (~150 líneas). Si crece más, dividir en componentes.
- Directorios con `qmldir` (`config/`, `services/`, `common/`, `launcher/`)
  solo exportan lo listado: **al crear un archivo ahí, agregarlo al `qmldir`**
  o la barra entera no arranca.

## Estado en disco

| Archivo | Quién lo escribe | Formato |
|---|---|---|
| `~/.cache/wal/colors.json` | pywal (solo lectura aquí) | JSON de pywal |
| `~/.local/state/quickshell/launcher.json` | `FavoritesStore` | `{"version": 1, "favorites": [ids .desktop]}`. Si no se puede leer, se copia a `launcher.json.bak` y el launcher muestra un aviso. Para cambiar el esquema: subir `version` y migrar en `normalize()` |
| `~/.local/state/wallpaper/<monitor>` | scripts `change-wallpaper.sh`, `wallpaper-*` | `image <ruta>` / `video <ruta>` / `scene <id>` |
| `~/.local/state/wallpaper/change.log` | `change-wallpaper.sh` | log de texto, rotado a `.1` a los 256 KB |

`change-wallpaper.sh` toma un lock (`$XDG_RUNTIME_DIR/change-wallpaper.lock`):
dos cambios seguidos se esperan en vez de pisarse. Su uso:
`change-wallpaper.sh --help`.

## Trampas conocidas

- **Máscara de clicks**: el panel de la barra mide `barHeight + expandRoom`
  pero solo recibe clicks donde dice `mask`. Todo lo que cuelga o crece bajo
  la fila (desplegables, monitor expandido) tiene que estar en la máscara, y
  medir 0 de alto cerrado (`Panel` ya lo hace) o seguirá tragando clicks.
- Los desplegables van como hijos directos de `TopBar`, no dentro de la pill
  que los abre: un hijo fuera del área de su padre no recibe el mouse.
- La altura del panel es fija a propósito: si siguiera al contenido, la fila
  salta un frame al animar. La `exclusiveZone` es solo `Theme.barHeight`.
- **Hyprland usa config en Lua**: los dispatch son strings Lua, p. ej.
  `Hyprland.dispatch('hl.dsp.focus({ workspace = 3 })')`. No usar
  `workspace.activate()`: un workspace descubierto vía toplevel trae
  `id = -1`; comparar por `parseInt(ws.name)`.
- `screen` de cada barra lo inyecta `Variants`; el nombre del monitor está en
  `topPanel.monitorName`.
- El tema de iconos de Qt es hicolor: `Quickshell.iconPath(name, true)` puede
  devolver vacío; hay que tener un fallback (glifo Nerd Font).
- Reglas de capa en `hypr/windows.lua`: el namespace `quickshell` va **sin**
  blur (por eso los fondos son opacos).
- Es desktop: no hay batería. GPU NVIDIA (`nvidia-smi`).

## Logs

El log de la instancia vive en `/run/user/1000/quickshell/by-id/<id>/`, que es
**tmpfs (RAM)**: si algo spamea, llena `/run/user/1000` y se rompen Wayland,
PipeWire y D-Bus. Si la sesión se pone rara: `du -sh /run/user/1000/quickshell`.

Caso conocido (2026-10-10, resuelto): un `SoundEffect` de QtMultimedia deja
un stream abierto pegado a la salida de audio; al apagarse unos audífonos
Bluetooth, Qt entró en un bucle de `QSocketNotifier: Invalid socket` (3 GB).
Por eso **no se usa QtMultimedia**: los sonidos van por `Sounds.play()`, que
lanza `pw-play`. Para probar algo que toque audio, simular la desconexión:
`m=$(pactl load-module module-null-sink sink_name=fake); pactl set-default-sink fake;`
reproducir algo, `pactl unload-module $m`, y mirar si el log crece.

## Commits

En español, título en tercera persona del presente ("Añade…", "Arregla…"),
sin prefijos tipo `feat:`, cuerpo con el porqué. Solo commitear cuando se
pida.
