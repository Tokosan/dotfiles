# Cómo deshacer la revisión de Quickshell (2026-10-10)

Todo el trabajo está en la rama **`quickshell-review`**, que sale de `main`
(`9f04d86`). `main` no se tocó. Este archivo no se despliega (está en
`.chezmoiignore`).

Lo que se aplicó a tu sistema con `chezmoi apply`:
`~/.config/quickshell/`, `~/bin/change-wallpaper.sh` y
`~/.local/bin/wallpaper-{import-we,restore,scene,video}`. Nada más (los
cambios locales que tenías en `hypr/autostart.lua` y nvim no se tocaron).

## Deshacer todo

```sh
cd ~/.local/share/chezmoi
git switch main
# chezmoi no borra archivos que ya no existen en la fuente: se limpia la
# carpeta para que no queden componentes nuevos sueltos.
rm -rf ~/.config/quickshell
chezmoi apply ~/.config/quickshell ~/bin/change-wallpaper.sh \
    ~/.local/bin/wallpaper-import-we ~/.local/bin/wallpaper-restore \
    ~/.local/bin/wallpaper-scene ~/.local/bin/wallpaper-video
pkill -x qs; sleep 0.2; qs -p ~/.config/quickshell -d
# Opcional: borrar la rama
git branch -D quickshell-review
```

Los favoritos del launcher no se pierden: la versión vieja lee
`~/.local/state/quickshell/by-shell/<id>/launcher.json`, que sigue ahí (la
nueva copió de ahí a `~/.local/state/quickshell/launcher.json` sin borrar el
original). Los favoritos que agregues después del cambio solo estarán en el
archivo nuevo.

## Quedarse con los cambios

```sh
cd ~/.local/share/chezmoi
git switch main && git merge --ff-only quickshell-review
```

## Deshacer solo una parte

Cada commit es un cambio. `git revert <hash>` deshace uno y deja el resto.
Después: `./dot_config/quickshell/check.sh` y `chezmoi apply` como arriba.
Los commits de una misma área dependen entre sí: revertir uno del medio
puede romper los siguientes; si `check.sh` falla, revertir también los
posteriores de esa área (de más nuevo a más viejo).

Lista: `git log --oneline main..quickshell-review`. Por área:

**Base (todo lo demás depende de esta)**
- `7423cc6` Theme, Settings, roles de Colors, servicios Audio/SystemStats/
  Sounds, componentes comunes y `check.sh`.

**Barra** (depende de la base)
- `4a98ae0` La barra usa servicios y componentes comunes; un solo
  desplegable abierto, que se cierra con un click fuera (antes el mezclador
  no se cerraba así); modelos estables en workspaces; mezclador con scroll;
  slider sin desfase; pill de GPU oculta sin nvidia-smi; grilla de wallpapers
  solo existe mientras se mira.
- `19e6d70` Borra `SoundIndicator.qml` (no se usaba).
- `62cad67` El mezclador baja si el monitor de sistema está expandido.
- `53a155e` Sonidos con `pw-play` en vez de `SoundEffect` (arregla el spam de
  `QSocketNotifier` al desconectarse unos audífonos Bluetooth). **No
  revertir sin otro arreglo**: volvería el riesgo de llenar `/run/user`.

**Launcher** (rama integrada en `51d795e`)
- `bc010b1` Divide Launcher.qml en componentes.
- `31a1ec7` Reordenar favoritos ya no borra los de apps no resueltas.
- `4bb21b7` launcher.json a ruta fija, relectura si cambia en disco.
- `47f7f7b` Esquema versionado de launcher.json.
- `078af9a` launcher.json dañado: backup `.bak` y aviso, no se sobrescribe.
- `aaecaf3` Favoritos se actualizan al instalar/desinstalar apps.
- `2c1420a` Arrastre cancelado no traba la grilla.
- `cd22804` Apps de terminal usan `Settings.terminalCommand`.
- `c4a9ae5` Pedir el launcher desde otra pantalla lo mueve en vez de cerrarlo.
- `872afc5` Rutas de iconos escapadas.
- `af5489e` Tab durante una búsqueda cambia de pestaña.
- `048db32` Pestañas del launcher en su propio archivo.
- `9449664` Navegación con flechas (ojo: izq/der ya no mueven el cursor del
  texto de búsqueda; revertir este si molesta).

**Wallpapers y scripts** (rama integrada en `f84a2f7`)
- `9eed466` change-wallpaper.sh sale con error si falla; log en
  `~/.local/state/wallpaper/change.log` (antes `/tmp/change-wallpaper.log`).
- `b06c80a` Lock para que dos cambios no se pisen.
- `5314597` Estado `image <ruta>` por monitor.
- `fe781c1` Uso del script en español, opción `--`.
- `9e9ec27` Sockets de mpvpaper en `$XDG_RUNTIME_DIR` (antes `/tmp`).
- `017aadb` wallpaper-import-we pasa datos a Python por argv.
- `2834852`, `6a0a3b3`, `ca35c3d`, `070acca` Grilla de wallpapers: base
  común, listados sin `sh -c`, fondo actual leído del estado por monitor,
  borde rojo si falla. **Los scripts y la grilla van juntos**: la grilla nueva
  llama `change-wallpaper.sh --monitor X -- <ruta>`; si revertís los scripts,
  revertí también estos.

**Documentación**
- `b3b0ba0` CLAUDE.md y TODO.md reescritos.

## Archivos creados fuera del repo

Inofensivos; se pueden borrar si se deshace todo:

- `~/.local/state/quickshell/launcher.json` (copia de los favoritos)
- `~/.local/state/wallpaper/change.log` (y `.1`)
- `$XDG_RUNTIME_DIR/change-wallpaper.lock`, `$XDG_RUNTIME_DIR/mpvpaper-*.sock`
  (se borran solos al reiniciar)
