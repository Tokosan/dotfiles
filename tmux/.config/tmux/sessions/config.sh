#!/bin/bash

SESSION_NAME="config"

tmux new-session -d -s $SESSION_NAME
tmux new-window -t $SESSION_NAME:1 -n "nvim"
tmux send-keys -t $SESSION_NAME:1 "cd ~/.config/nvim && nvim init.lua" C-m
tmux new-window -t $SESSION_NAME:2 -n "tmux"
tmux send-keys -t $SESSION_NAME:2 "cd ~/.config/tmux && nvim tmux.conf" C-m
tmux new-window -t $SESSION_NAME:3 -n "bash"
tmux send-keys -t $SESSION_NAME:3 "config-bash" C-m
tmux new-window -t $SESSION_NAME:4 -n "system"
tmux send-keys -t $SESSION_NAME:4 "cd ~/.config && nvim ." C-m
