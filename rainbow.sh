#!/bin/bash


echo "Cloning Rainbowprotocol repository..."

cd $HOME 
mkdir Rainbowprotocol
git clone https://github.com/rainbowprotocol-xyz/btc_testnet4
cd btc_testnet4

# Prompt user for username and password
read -p "Enter your username: " username
read -p "Enter your password: " password
read -p "Enter your walletName: " walletname

jq --arg username "$username" --arg password "$password" --arg wallet "$walletname" 

cat > docker-compose.yml <<EOL
version: '3'
services:
  bitcoind:
    image: mocacinno/btc_testnet4:bci_node
    privileged: true
    container_name: bitcoind
    volumes:
      - /root/project/run_btc_testnet4/data:/root/.bitcoin/
    command: ["bitcoind", "-testnet4", "-server","-txindex", "-rpcuser=$username", "-rpcpassword=$password", "-rpcallowip=0.0.0.0/0", "-rpcbind=0.0.0.0:5000"]
    ports:
      - "8333:8333"
      - "48332:48332"
      - "5000:5000"
EOL


docker-compose up -d

docker exec -it bitcoind /bin/bash

bitcoin-cli -testnet4 -rpcuser=$username -rpcpassword=$password -rpcport=5000 createwallet $wallet

exit

# Download and run the upgrade script
echo "Connect Bitcoin Core and Run Indexert..."


