local terminal = "kitty"
local mainMod = "SUPER"
local secondMod = "CTRL_SHIFT_ALT_SUPER"

-- # Main bindings
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + R", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + CONTROL + Q", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"))
hl.bind("SUPER + SHIFT + CONTROL + L", hl.dsp.exec_cmd("hyprlock --grace 10"))

-- Workspace navigation
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind("SUPER + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

for i = 1, 5 do
  hl.bind(secondMod .. " + " .. i, hl.dsp.focus({workspace = i+5}))
end

-- Apps
hl.bind( { secondMod .. " + E", hl.dsp.exec_cmd ( "fol-telegram" ) } )
hl.bind( { secondMod .. " + A", hl.dsp.exec_cmd ( "fol-zen" ) } )
hl.bind( { secondMod .. " + T", hl.dsp.exec_cmd ( "fol-kitty" ) } )
hl.bind( { secondMod .. " + D", hl.dsp.exec_cmd ( "fol-vesktop" ) } )
hl.bind( { secondMod .. " + W", hl.dsp.exec_cmd ( "fol-whatsapp" ) } )
hl.bind( { secondMod .. " + M", hl.dsp.exec_cmd ( "fol-spotify" ) } )
hl.bind = mainMod, RETURN, Terminal, exec, $terminal
hl.bind = mainMod SHIFT, RETURN, Floating terminal, exec, [float; size 700 400] kitty
hl.bind = mainMod, SPACE, Rofi, exec, rofi -show drun
hl.bind = mainMod SHIFT, D, Docker, exec, $terminal -e lazydocker
hl.bind = mainMod SHIFT, T, Activity, exec, $terminal -e btop
hl.bind = mainMod SHIFT, O, Obsidian, exec, obsidian

unbind = $mainMod, J
unbind = $mainMod, K
bindd = $mainMod, H, Move focus left, movefocus, l
bindd = $mainMod, L, Move focus right, movefocus, r
bindd = $mainMod, K, Move focus up, movefocus, u
bindd = $mainMod, J, Move focus down, movefocus, d
bindd = $mainMod, LEFT, Move focus left, movefocus, l
bindd = $mainMod, RIGHT, Move focus right, movefocus, r
bindd = $mainMod, UP, Move focus up, movefocus, u
bindd = $mainMod, DOWN, Move focus down, movefocus, d
bindd = $mainMod, TAB, Cycle focus, cyclenext
bindd = $mainMod CTRL, F, Tiled full screen, fullscreenstate, 1

# Swap active window with the one next to it with SUPER + SHIFT + arrow keys
bindd = SUPER SHIFT, H, Swap window to the left, swapwindow, l
bindd = SUPER SHIFT, L, Swap window to the right, swapwindow, r
bindd = SUPER SHIFT, K, Swap window up, swapwindow, u
bindd = SUPER SHIFT, J, Swap window down, swapwindow, d
# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
binde = $mainMod CTRL, Left, resizeactive, -20 0
binde = $mainMod CTRL, Right, resizeactive, 20 0
binde = $mainMod CTRL, Up, resizeactive, 0 -20
binde = $mainMod CTRL, Down, resizeactive, 0 20
binde = $mainMod CTRL, H, resizeactive, -20 0
binde = $mainMod CTRL, L, resizeactive, 20 0
binde = $mainMod CTRL, K, resizeactive, 0 -20
binde = $mainMod CTRL, J, resizeactive, 0 20

# Laptop multimedia keys for volume and LCD brightness
bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
bindel = ,XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+
bindel = ,XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-

# Requires playerctl
bindl = , XF86AudioNext, exec, playerctl next
bindl = , XF86AudioPause, exec, playerctl play-pause
bindl = , XF86AudioPlay, exec, playerctl play-pause
bindl = , XF86AudioPrev, exec, playerctl previous

bindd = $mainMod SHIFT, M, Toggle audio output, exec, toggle-audio.sh

bindd = $mainMod, BACKSPACE, Toggle transparency on current window, setprop, active opaque toggle
bindd = $mainMod, T, Toggle bouyancy, togglefloating
bind = SUPER, N, exec, swaync-client -t -sw
bind = SUPER SHIFT, N, exec, swaync-client -C


# Tools
bindd = $mainMod SHIFT, S, Take screenshot, exec, hyprshot -m region --output-folder ~/drives/hdd/media/images/hyprshot
bindd = $mainMod CONTROL, SPACE, Change wallpaper, exec, hyprctl dispatch exec pick-random-wallpaper
bind = $mainMod, R, exec, gpu-screen-recorder -w DP-1 -f 30 -a default_output -o ~/drives/hdd/media/videos/screenrecord/$(date +%Y-%m-%d_%H-%M-%S).mp4 & notify-send "Recording Started"
bind = $mainMod CONTROL, R, exec, killall -SIGINT gpu-screen-recorder && notify-send "Recording Stopped"

