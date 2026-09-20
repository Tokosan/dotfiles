# TODO — Migración Waybar → Quickshell

Objetivo: replicar la Waybar de arriba en Quickshell para poder deprecarla.
Fuente: `~/.config/waybar/config.jsonc` + `style.css`.

## Estado actual de la barra QS

Solo existe `TopBar` con los workspaces (número + iconos de ventanas, click
para enfocar). Todo lo demás está por hacer.

---

## 0. Infraestructura (hacer primero)

- [ ] **Singleton de colores/tema.** Hoy hay `"white"` y `#a0ffffff` hardcodeados.
      Waybar usa Catppuccin (`colors.css`) + pywal.
- [ ] **Integrar pywal.** Waybar importa `~/.cache/wal/colors-waybar.css`, por eso la
      barra sigue el wallpaper. Hay que parsear ese archivo (o `colors.json`) y
      recargar en caliente cuando cambie.
- [ ] **Fuente global**: `JetBrains Mono Nerd Font`, bold, 12px.
- [ ] **Multi-monitor.** Hay 2 pantallas (DP-1 y HDMI-A-1); la barra QS actual no
      declara `screen`, así que aparece en una sola.

## 1. Layout de la barra

- [ ] Tres zonas: left / center / right (hoy solo hay contenido a la izquierda).
- [ ] **Estética de "pills" colgantes**: fondo transparente y cada módulo como
      bloque con `border-radius: 0 0 15px 15px` (esquinas redondeadas abajo),
      pegado al borde superior. Spacing 4px.

## 2. Zona izquierda

- [ ] **Botón de apps** (``) — abre launcher con click izq., wallpaper con der.
- [ ] **Workspaces por monitor.** Waybar tiene dos grupos: DP-1 muestra 1-5 y
      HDMI-A-1 muestra 6-10. La barra QS actual muestra *todos* en ambas.
- [ ] **Workspaces persistentes**: 1-10 siempre visibles aunque estén vacíos.
- [ ] **Estilo de workspace**: pill redonda (`border-radius: 50px`), hover con
      glow interno, enfocado con color de acento y texto oscuro.
- [ ] **Workspace urgente**: animación de parpadeo (1s infinito).
- [ ] Agregar `kitty` al mapa de iconos (está en el grupo izq. de Waybar pero
      falta en `WorkspaceButton.qml`).

## 3. Zona central

- [ ] **Módulo de media** (`custom/media`). Muestra `󰎆 Artista - Título`, se corta
      a 45 chars. Hoy es un script + `playerctl`; en QS conviene usar
      `Quickshell.Services.Mpris` nativo en vez de hacer `exec` cada 2s.
      - [ ] Click izq: play/pause
      - [ ] Click der: abrir panel de música (`music toggle`)
      - [ ] Scroll: subir/bajar volumen 5%

## 4. Zona derecha

- [ ] **Volumen entrada (mic)**: `{volume}% ` / `---` si mute. Click: toggle mute.
- [ ] **Volumen salida**: icono según nivel (`  `) + `{volume}%`.
      - [ ] Click izq: toggle mute · der: `pulsemixer` · medio: `toggle-audio.sh`
      - [ ] Usar `Quickshell.Services.Pipewire` (ya hay código en `SoundIndicator.qml`).
- [ ] **CPU / RAM / GPU**: pills con **relleno vertical proporcional a la carga**
      (el detalle visual más característico). Gradiente que sube desde abajo:
      verde 0-45%, amarillo 50-60%, naranja 65-75%, rojo 80-100%. Texto se
      oscurece sobre fondo claro. Transición 0.5s.
      - [ ] CPU (interval 1s) · tooltip con load, cores, freq, uso
      - [ ] RAM (interval 1s) · tooltip con usado/libre/total en GB
      - [ ] GPU vía `nvidia-smi` (interval 2s) — es NVIDIA
      - [ ] Click en el grupo: abre `ghostty -e btop`
- [ ] **Tray** (iconos 16px, spacing 8). `Quickshell.Services.SystemTray`.
- [ ] **Reloj**: `Sunday, 20 of September  09:26:02`, actualiza cada 1s.
      Formato: `{:%A, %d of %B    %H:%M:%S}`, tooltip con fecha ISO.
      - [ ] Ojo: en español el locale cambia los nombres de día/mes.
- [ ] **Botón dashboard** (`󰍜`) al extremo derecho.

## 5. Tooltips

- [ ] No existen en la barra QS. Waybar los usa en CPU/RAM/GPU/reloj.
      Hay que construir el componente (fondo `@background`, radius 12px, bold).

## 6. Paneles IPC (no existen todavía)

Waybar ya llama a estos, pero **ningún Quickshell los implementa** — hoy esos
clicks no hacen nada. Es trabajo nuevo, no solo "conectar":

- [ ] `qs ipc call launcher toggle` — app launcher
- [ ] `qs ipc call wallpaper toggle` — selector de wallpaper
- [ ] `qs ipc call dashboard toggle` — dashboard
- [ ] `qs ipc call music toggle` — panel de música

## 7. Pendientes heredados del TODO de Waybar

- [ ] Shortcuts para acciones: screenshot, reiniciar barra, reiniciar Hyprland
- [ ] Botón de apagado / menú de sesión
- [ ] App launcher de mouse
- [ ] Panel de música

## 8. Cierre de la migración

- [ ] Conectar `SoundIndicator.qml` (existe pero nadie lo instancia; además su
      barra interna no tiene `color`, sale blanca por defecto).
- [ ] Quitar Waybar del autostart de Hyprland.
- [ ] Ajustar `exclusiveZone` para que no queden huecos al sacar Waybar.

---

## Notas

- **No hay batería** (`/sys/class/power_supply` vacío): es desktop. El `62% / 10%`
  del pantallazo son volumen de mic y de salida, no batería.
- El `network.sh` existe pero **no está en `config.jsonc`**: hay wifi/bluetooth a
  medio hacer. Decidir si entra o se descarta.
- Hyprland usa dispatch Lua: `hl.dsp.focus({ workspace = N })`.
