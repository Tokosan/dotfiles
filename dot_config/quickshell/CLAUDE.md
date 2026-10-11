# CLAUDE.md — Quickshell

Barra superior (y paneles) de Hyprland hecha en Quickshell/QML. Reemplaza a
Waybar; el plan de migración y lo pendiente está en `TODO.md`.

## Dónde vive y cómo se prueba

- Este directorio es la **fuente de chezmoi** (`~/.local/share/chezmoi/dot_config/quickshell`).
  Se edita aquí, nunca en `~/.config/quickshell` (chezmoi lo sobrescribe).
- Para ver un cambio: `chezmoi apply ~/.config/quickshell`. Quickshell recarga
  en caliente al cambiar los archivos del destino.
- Reinicio completo (lo mismo que `SUPER+SHIFT+R`):
  `pkill -x qs; sleep 0.2; qs -p ~/.config/quickshell &disown`
- La recarga en caliente puede decir "Configuration Loaded" aunque el
  arranque en frío falle (p. ej. un tipo que no existe). Tras cambios de
  imports o `qmldir`, reiniciar y revisar `qs log -p ~/.config/quickshell`.
- IPC: `qs ipc show` lista los handlers; `qs ipc call launcher toggle`.
- Errores de QML: correr `qs -p ~/.config/quickshell` en foreground y leer la
  salida. No hay `qmllint`; `qmlformat` está en `~/.local/bin` (formato de 4
  espacios, una propiedad por línea, como el código existente).
- Versión: Quickshell 0.3.x (`quickshell-git` de AUR). Ante dudas de API, la
  referencia es https://quickshell.org/docs/.

## Estructura

```
shell.qml                     ShellRoot: un TopBar por pantalla (Variants sobre Quickshell.screens)
modules/config/Colors.qml     Singleton de tema (pywal + fallback Catppuccin)
modules/bar/TopBar.qml        PanelWindow de la barra; aloja también los desplegables
modules/bar/components/       Widgets de la barra y sus paneles
modules/launcher/             Launcher de apps (LauncherState singleton + ventana overlay)
modules/widgets/              Sueltos, sin instanciar todavía (SoundIndicator)
assets/                       chime.wav, star.png
```

Scripts externos que se invocan desde QML viven en el repo en `bin/`
(→ `~/bin`), p. ej. `change-wallpaper.sh`.

## Convenciones

- **Colores solo vía `Colors`** (`import "../../config"`). Nada de colores
  hardcodeados en widgets. Los widgets usan roles semánticos
  (`barBackground`, `panelBorder`, `accent`, `alert`, `loadColor(pct)`…), no
  `colorN`. Si hace falta un color nuevo, se agrega como rol en `Colors.qml`.
- Los colores de pywal se leen de `~/.cache/wal/colors.json` con `FileView`
  + `watchChanges`. Los bindings deben referenciar `root.parsed` directamente
  para que se re-evalúen al recargar.
- Colores de señal (alerta, carga, acento) son **fijos**, no de pywal: la
  paleta del wallpaper no garantiza un rojo/verde reconocible.
- Fuente: `"JetBrains Mono Nerd Font"`. Iconos Nerd Font como escapes
  `"\u{f005}"`, con un comentario del nombre si no es obvio.
- **Estética "pill colgante"**: cada módulo es un `Rectangle` con
  `color: Colors.barBackground`, esquinas superiores en 0 y
  `bottomLeftRadius`/`bottomRightRadius: 15`, pegado al borde superior.
  Paneles flotantes: `Colors.panelBackground`, `radius: 15`, borde de 2px
  `Colors.panelBorder`.
- Animaciones cortas con `Behavior` (120–200 ms, `Easing.OutCubic`).
- Hover: `Colors.accent`, `cursorShape: Qt.PointingHandCursor`.
- Sonido de feedback: `SoundEffect` con `assets/chime.wav`, volumen según el
  peso de la acción.
- Los componentes exponen `signal`s y dejan que el contenedor decida la
  acción (ver `StarButton`).
- Textos visibles de la UI en **inglés**; comentarios en **español**, y
  explican el *porqué* (decisiones y trampas), no el qué.
- Referenciar propiedades con `id.` explícito (`monitor.cpuUsage`), no por
  scope implícito.

## Trampas conocidas

- **Un directorio con `qmldir` solo exporta lo que está listado ahí.** Al
  agregar un `.qml` a `modules/config/` o `modules/launcher/`, sumarlo al
  `qmldir` o no será un tipo (y la barra entera no arranca).
- El launcher guarda favoritos en `Quickshell.statePath("launcher.json")`
  (`~/.local/state/quickshell/by-shell/<id>/`), fuera del repo a propósito.
- El tema de iconos de Qt es hicolor: `Quickshell.iconPath(name, true)` puede
  devolver vacío; hay que tener un fallback propio (glifo Nerd Font).

- **Desplegables bajo la barra**: van como hijos directos de `TopBar`, no
  dentro del widget que los abre. Un hijo fuera del área de su padre no
  recibe eventos de mouse. Además hay que:
  - agregarlos a la `mask: Region { ... }` del panel (si no, no reciben clicks);
  - poner `height: 0` al cerrarlos (si no, la máscara sigue tragando clicks).
- El panel tiene altura fija `barHeight + expandRoom`; la `exclusiveZone` es
  solo `barHeight`. No hacer que la altura siga al contenido (salta un frame
  al animar). Si algo nuevo es más alto que `expandRoom`, subir `expandRoom`.
- La fila (`content`) se ancla arriba con altura `barHeight`, no al panel.
- **Hyprland usa config en Lua**: los dispatch son strings Lua, p. ej.
  `Hyprland.dispatch('hl.dsp.focus({ workspace = 3 })')`. No usar
  `workspace.activate()`: un workspace descubierto vía toplevel trae `id = -1`;
  comparar por `parseInt(ws.name)`.
- Workspaces por monitor: DP-1 → 1-5, HDMI-A-1 → 6-10 (hoy ambos grupos se
  muestran en las dos barras).
- `screen` de cada barra lo inyecta `Variants`; para saber el monitor usar
  `topPanel.screen.name` y bajarlo como propiedad.
- Lectura de sistema: `FileView` sobre `/proc/*` + `reload()` en un `Timer`;
  comandos con `Process` + `StdioCollector.onStreamFinished`. GPU NVIDIA
  (`nvidia-smi`). Es desktop, no hay batería.
- En Hyprland, `windows.lua` aplica blur al namespace `quickshell`.

## Commits

Mensajes en español, título en tercera persona del presente
("Añade…", "Arregla…", "Evita…"), sin prefijos tipo `feat:`. Cuerpo
explicando el porqué en prosa corta. Solo hacer commit cuando se pida.
