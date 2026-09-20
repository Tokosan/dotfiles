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
    animations = {
        enabled = true,
    },
})

-- Curves are declared outside of hl.config(). The four numbers of a .conf
-- `bezier = name, x1, y1, x2, y2` become the two control points below.
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

-- `animation = leaf, enabled, speed, curve[, style]`
hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "default" })

-- # https://wiki.hypr.land/Configuring/Variables/#animations
