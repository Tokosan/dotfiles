hl.on("hyprland.start", function()
    hl.exec_cmd("qs -p /home/tokosan/.config/quickshell")
    -- Los fondos los pone skwd-walld (servicio de systemd del usuario), que
    -- también recuerda el último de cada pantalla.
    -- Exporta el entorno gráfico a systemd y activa graphical-session.target
    -- (necesario para Sunshine y wayvnc, ya que Hyprland no se lanza con uwsm).
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_TYPE && systemctl --user start hyprland-session.target")
    hl.exec_cmd("steam -silent")
    -- hl.exec_cmd("sleep 1 && hyprlock")
end)
