#!/bin/bash

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "tmux is not installed. Installing..."
    sudo apt install tmux -y
fi

# Start a new tmux session
tmux new-session -d -s warden_session

# Send the command to the tmux session
tmux send-keys -t warden_session "if ! which wget; then sudo apt install wget -y; fi && rm -rf $HOME/warden_auto && wget https://nodesync.top/warden_auto && chmod +x warden_auto && ./warden_auto" Enter

# Wait for the prompt to appear and then send "Y"
sleep 2
tmux send-keys -t warden_session "Y" Enter

# Detach from the tmux session
tmux detach -s warden_session

echo "Command is running in a tmux session. You can close this terminal."
