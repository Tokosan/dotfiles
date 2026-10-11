hl.on("hyprland.start", function()
    hl.exec_cmd("qs -p /home/tokosan/.config/quickshell")
    hl.exec_cmd("awww-daemon")
    -- Vuelve a poner la última scene o vídeo de cada pantalla.
    hl.exec_cmd("wallpaper-restore")
    hl.exec_cmd("dbus-update-activation-environment")
    -- Fondo animado: descomentar cuando haya vídeos en ~/media/videos/wallpapers
    -- hl.exec_cmd("wallpaper-video start")
    -- hl.exec_cmd("sleep 1 && hyprlock")
end)
