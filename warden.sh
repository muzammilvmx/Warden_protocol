#!/bin/bash

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

# Update system and install necessary packages
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade

# Install Go
ver="1.21.3"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version

# Clone and install Wardend
cd $HOME
git clone https://github.com/warden-protocol/wardenprotocol.git
cd wardenprotocol
git checkout v0.3.0
make install

# Configure cosmovisor
cd $HOME
mkdir -p ~/.warden/cosmovisor/upgrades/v0.3.0/bin
mv $HOME/go/bin/wardend ~/.warden/cosmovisor/upgrades/v0.3.0/bin/
sudo ln -s ~/.warden/cosmovisor/genesis ~/.warden/cosmovisor/current -f
sudo ln -s ~/.warden/cosmovisor/current/bin/wardend /usr/local/bin/wardend -f
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0

# Create and enable systemd service for Wardend
sudo tee /etc/systemd/system/wardend.service > /dev/null << EOF
[Unit]
Description=warden node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=~/.warden"
Environment="DAEMON_NAME=wardend"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:~/.warden/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable wardend

# Initialize Wardend configuration
wardend config chain-id buenavista-1
wardend config keyring-backend os
wardend config node tcp://localhost:26657
read -p "Enter your custom moniker: " moniker
wardend init $moniker

# Download configuration files
curl https://config-t.noders.services/warden/genesis.json -o ~/.warden/config/genesis.json
curl https://config-t.noders.services/warden/addrbook.json -o ~/.warden/config/addrbook.json

# Update configuration settings
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"64fc01489d8fda6b6aa859aef438e4131df6bcda@warden-t-rpc.noders.services:23656\"/" ~/.warden/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.001uward\"|" ~/.warden/config/app.toml
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  ~/.warden/config/app.toml

# Start Wardend service
sudo systemctl start wardend
sudo journalctl -u wardend -f --no-hostname -o cat


# Update system and install necessary packages
sudo apt update
sudo apt install snapd -y
sudo snap install lz4

# Stop Wardend
sudo systemctl stop wardend

# Backup priv_validator_state.json
cp ~/.warden/data/priv_validator_state.json  ~/.warden/priv_validator_state.json

# Download and extract snapshot data
cd $HOME
sudo rm -rf ~/.warden/data
sudo rm -rf ~/.warden/wasm
curl -o - -L https://config-t.noders.services/warden/data.tar.lz4 | lz4 -d | tar -x -C ~/.warden
curl -o - -L https://config-t.noders.services/warden/wasm.tar.lz4 | lz4 -d | tar -x -C ~/.warden

# Restore priv_validator_state.json
cp ~/.warden/priv_validator_state.json  ~/.warden/data/priv_validator_state.json

# Restart Wardend
sudo systemctl restart wardend
sudo journalctl -fu wardend --no-hostname -o cat
