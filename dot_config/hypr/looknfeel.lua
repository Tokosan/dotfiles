hl.config({
    general = {
        gaps_in = 2,
        gaps_out = 0,
        border_size = 2,
        layout = "dwindle",
        col = {
            active_border = "rgb(aaaaaa)",
            inactive_border = "rgb(313244)",
        },
    },

    decoration = {
        rounding = 0,
        rounding_power = 2,
        -- Change transparency of focused and unfocused windows
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        fullscreen_opacity = 1,
        shadow = {
            enabled = true,
            range = 8,
            -- render_power = 3,
            color = "rgba(00000066)",
        },
        blur = {
            enabled = true,
            size = 4,
            passes = 3,
            noise = 0.02,
            brightness = 1.0,
            contrast = 1.0,
            new_optimizations = true,
            xray = false,
            popups = true,
            special = true,
        },
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        disable_hyprland_logo = true,
    },
    -- animations = {
    --     enabled = true,
    --     bezier = myBezier, 0.05, 0.9, 0.1, 1.05,
    --     animation = windows, 1, 2, myBezier,
    --     animation = windowsOut, 1, 3, default, popin 80%,
    --     animation = border, 1, 2, default,
    --     animation = borderangle, 1,2, default,
    --     animation = fade, 1, 2, default,
    --     animation = workspaces, 1, 2, default,
    -- }
})

-- # https://wiki.hypr.land/Configuring/Variables/#animations
