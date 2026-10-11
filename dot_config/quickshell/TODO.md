# TODO — Quickshell

Lo que falta para que la barra reemplace del todo a Waybar, más deudas
conocidas. Lo hecho no se lista: si algo está en el código, ya existe.
Actualizar este archivo al terminar una tarea (borrar la línea).

## Ya existe (para no reimplementarlo)

Barra por monitor con: botón estrella (launcher / menú), dos grupos de
workspaces con iconos de apps, monitor de CPU/RAM/GPU con detalle, volumen de
mic y salida con mezclador, reloj. Menú con wallpapers (imagen, vídeo,
scene), launcher, reiniciar y apagar. Launcher de apps con favoritos. Colores
de pywal. Waybar ya no arranca con Hyprland.

## Funcionalidad pendiente

- [ ] **Media** (centro de la barra): `Artista - Título` cortado a 45
      caracteres, con `Quickshell.Services.Mpris` (no un script con polling).
      Click izq play/pause, rueda volumen. Va como servicio `Media.qml` en
      `modules/services/` + pill en `bar/components/`.
- [ ] **Tray** (`Quickshell.Services.SystemTray`), iconos de 16 px.
- [ ] **Tooltips** en CPU/RAM/GPU y reloj. Conviene un componente en
      `modules/common/`.
- [ ] **Workspace urgente**: parpadeo. El dato está en `ws.urgent`
      (`Workspaces.qml`, delegate `entry`).
- [ ] **Workspaces por monitor**: hoy las dos barras muestran los dos grupos
      (`Settings.workspaceGroups`). Decidir si cada barra muestra solo el suyo
      (DP-1 → 1-5, HDMI-A-1 → 6-10).
- [ ] **Reloj**: Waybar mostraba `Sunday, 20 of September  09:26:02`; hoy es
      `yyyy-MM-dd HH:mm:ss`. Decidir el formato.
- [ ] Entradas del menú sin implementar (`GlobalMenu.qml`, `enabled: false`):
      **Screenshot** y **Restart Hyprland**.
- [ ] Paneles por IPC que el atajo de Hyprland podría llamar: `wallpaper`,
      `dashboard`, `music`. Solo existe `launcher` (`qs ipc show`).
- [ ] Botón de dashboard al extremo derecho (no existe el dashboard).

## Deuda técnica

- [ ] `expandRoom` en `TopBar.qml` es un número fijo (460). Si un desplegable
      nuevo es más alto, subirlo o darle scroll.
- [ ] Los glifos de `WorkspaceButton.iconMap` no tienen el nombre Nerd Font
      en un comentario.
