#!/bin/bash

SESSION_NAME="memoria"

tmux new-session -d -s $SESSION_NAME
tmux new-window -t $SESSION_NAME:1 -n 'project'
tmux send-keys -t $SESSION_NAME:1 'cd ~/Documents/memoria/ && nvim .' C-m
tmux new-window -t $SESSION_NAME:2 -n 'frontend'
tmux send-keys -t $SESSION_NAME:2 'cd ~/Documents/memoria/frontend && nvim .' C-m
tmux new-window -t $SESSION_NAME:3 -n 'backend'
tmux send-keys -t $SESSION_NAME:3 'cd ~/Documents/memoria/backend && nvim .' C-m
tmux new-window -t $SESSION_NAME:4 -n 'runner'
tmux send-keys -t $SESSION_NAME:4 'cd ~/Documents/memoria' C-m
tmux split-window -h -t $SESSION_NAME:4
tmux split-window -v -t $SESSION_NAME:4.1
tmux send-keys -t $SESSION_NAME:4.0 'cd ~/Documents/memoria/backend && uv run uvicorn app.api.main:app --reload --host 0.0.0.0' C-m
tmux send-keys -t $SESSION_NAME:4.1 'cd ~/Documents/memoria/frontend && npm run dev -- --host' C-m
tmux send-keys -t $SESSION_NAME:4.2 'cd ~/Documents/memoria/backend && docker compose up -d && docker compose logs -f' C-m

