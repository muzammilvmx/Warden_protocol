#!/bin/bash

# Get absolute path to home directory
HOME_DIR=$(realpath ~)

# Print Cipher_Airdrop in big bold text
echo "========================================================================="
echo "  _____   _____   _____    _    _   ______   _____                 "
echo " / ____| |_   _| |  __ \  | |  | | |  ____| |  __ \               "
echo "| |        | |   | |__) | | |__| | | |__    | |__) |             "
echo "| |        | |   |  ___/  |  __  | |  __|   |  _  /             "
echo "| |____   _| |_  | |      | |  | | | |____  | | \ \              "
echo " \_____| |_____| |_|      |_|  |_| |______| |_|  \_\           "
echo "========================================================================="

# Social media links
echo "Follow us on social media:"
echo "Twitter: https://twitter.com/cipher_airdrop"
echo "Telegram: https://t.me/+tFmYJSANTD81MzE1"
echo

# Ask user if they want to install Wardend Node
read -p "Do you want to install Wardend Node? (Y/n): " choice
if [ "$choice" != "Y" ]; then
    echo "Aborted."
    exit 0
fi

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

# Wait for the prompt to appear and then send "y"
sleep 20
tmux send-keys -t warden_session "y" Enter

# Detach from the tmux session
tmux detach -s warden_session

echo "Command is running in a tmux session. You can close this terminal."
