-- See https://wiki.hyprland.org/Configuring/Window-Rules/
-- Workspace specific rules

-- Kitty on 1
hl.window_rule({
    name = "kitty-on-workspace-1",
    match = { initial_class = "kitty" },
    workspace = "1",
    no_blur = true,
    opacity = "0.95 override 0.8 override 0.9 override",
})

-- Firefox on 2
hl.window_rule({
    name = "firefox-on-workspace-2",
    match = { initial_class = "firefox" },
    workspace = "2",
})

-- Zen on 2
hl.window_rule({
    name = "zen-on-workspace-2",
    match = { initial_class = "zen" },
    workspace = "2",
})

-- Whatsapp and Telegram on 6
hl.window_rule({
    name = "whatsapp-on-workspace-6",
    match = { initial_class = "chrome-web.whatsapp.com__-Default" },
    workspace = "6",
})

hl.window_rule({
    name = "telegram-on-workspace-7",
    match = { initial_class = "org.telegram.desktop" },
    workspace = "6",
})

-- Vesktop on 9
hl.window_rule({
    name = "vesktop-on-workspace-9",
    match = { initial_class = "vesktop" },
    workspace = "9",
})

-- Spotify on 10
hl.window_rule({
    name = "spotify-on-workspace-10",
    match = { initial_class = "chrome-spotify.com__-Default" },
    workspace = "10",
})

-- LocalSend: ventana flotante (no reserva espacio en el tiling al abrir desde el tray)
hl.window_rule({
    name = "localsend-floating",
    match = { initial_class = "localsend" },
    float = true,
    center = true,
    size = "950 984",
})

hl.layer_rule({
    name = "quickshell-blur",
    match = { namespace = "quickshell" },
    blur = false,
    ignore_alpha = 0,
})

hl.layer_rule({
    name = "rofi-no-anim",
    match = { class = "^(rofi)$" },
    no_anim = true,
})
