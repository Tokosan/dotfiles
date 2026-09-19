local terminal = "kitty"
local mainMod = "SUPER"
local secondMod = "CTRL + SHIFT + ALT + SUPER"

-- Main bindings
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(), { desc = "Fullscreen" })
hl.bind(mainMod .. " + W", hl.dsp.window.close(), { desc = "Close Active Window" })
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("pkill waybar; hyprctl dispatch exec waybar"), { desc = "Reload Waybar" })
hl.bind(mainMod .. " + SHIFT + CONTROL + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"), { desc = "Exit Hyprland", long_press = true })
hl.bind(mainMod .. " + SHIFT + CONTROL + L", hl.dsp.exec_cmd("hyprlock --grace 10"), { desc = "Lock screen" })

-- Tiling
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }), { desc = "Move focus left" })
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), { desc = "Move focus right" })
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), { desc = "Move focus up" })
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), { desc = "Move focus down" })
hl.bind(mainMod .. " + LEFT", hl.dsp.focus({ direction = "left" }), { desc = "Move focus left" })
hl.bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "right" }), { desc = "Move focus right" })
hl.bind(mainMod .. " + UP", hl.dsp.focus({ direction = "up" }), { desc = "Move focus up" })
hl.bind(mainMod .. " + DOWN", hl.dsp.focus({ direction = "down" }), { desc = "Move focus down" })
hl.bind(mainMod .. " + TAB", hl.dsp.window.cycle_next(), { desc = "Cycle focus" })
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { desc = "Tiled full screen" })

-- Workspace navigation
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Second monitor: secondMod + 1..5 -> workspaces 6..10
for i = 1, 5 do
    hl.bind(secondMod .. " + " .. i, hl.dsp.focus({ workspace = i + 5 }))
end

-- Swap active window with the one next to it
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }), { desc = "Swap window to the left" })
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }), { desc = "Swap window to the right" })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }), { desc = "Swap window up" })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }), { desc = "Swap window down" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { drag = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { drag = true })

-- Resize active window
hl.bind(mainMod .. " + CTRL + Left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + Up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + Down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("toggle-audio.sh"), { desc = "Toggle audio output" })

hl.bind(mainMod .. " + BACKSPACE", hl.dsp.window.set_prop({ prop = "opaque", value = "toggle" }), { desc = "Toggle transparency on current window" })
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }), { desc = "Toggle bouyancy" })
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -C"))

-- Apps
hl.bind(secondMod .. " + E", hl.dsp.exec_cmd("fol-telegram"), { desc = "Focus-or-launch Telegram" })
hl.bind(secondMod .. " + A", hl.dsp.exec_cmd("fol-zen"), { desc = "Focus-or-launch Browser" })
hl.bind(secondMod .. " + T", hl.dsp.exec_cmd("fol-kitty"), { desc = "Focus-or-launch Terminal" })
hl.bind(secondMod .. " + D", hl.dsp.exec_cmd("fol-vesktop"), { desc = "Focus-or-launch Vesktop" })
hl.bind(secondMod .. " + W", hl.dsp.exec_cmd("fol-whatsapp"), { desc = "Focus-or-launch WhatsApp" })
hl.bind(secondMod .. " + M", hl.dsp.exec_cmd("fol-spotify"), { desc = "Focus-or-launch Spotify" })
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal), { desc = "Terminal" })
hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("[float; size 700 400] " .. terminal), { desc = "Floating terminal" })
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("rofi -show drun"), { desc = "Rofi" })
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(terminal .. " -e lazydocker"), { desc = "Docker" })
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(terminal .. " -e btop"), { desc = "Activity" })
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.exec_cmd("obsidian"), { desc = "Obsidian" })

-- Tools
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region --output-folder ~/drives/hdd/media/images/hyprshot"), { desc = "Take screenshot" })
hl.bind(mainMod .. " + CONTROL + SPACE", hl.dsp.exec_cmd("pick-random-wallpaper"), { desc = "Change wallpaper" })
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd('gpu-screen-recorder -w DP-1 -f 30 -a default_output -o ~/drives/hdd/media/videos/screenrecord/$(date +%Y-%m-%d_%H-%M-%S).mp4 & notify-send "Recording Started"'), { desc = "Start recording" })
hl.bind(mainMod .. " + CONTROL + R", hl.dsp.exec_cmd('killall -SIGINT gpu-screen-recorder && notify-send "Recording Stopped"'), { desc = "Stop recording" })
