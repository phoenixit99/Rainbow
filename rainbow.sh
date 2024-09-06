#!/bin/bash
cd $HOME
rm rainbow.sh
rm -r rainbow

mkdir rainbow

git clone https://github.com/rainbowprotocol-xyz/btc_testnet4
cd btc_testnet4
# Prompt user for input
read -p "Enter your username: " username
read -s -p "Enter your password: " password
echo ""
read -p "Enter your walletName: " walletname

# Check if jq is needed or not (can be used for further processing)
# Here, we are just outputting the variables to show how you could use jq
echo "{\"username\": \"$username\", \"password\": \"$password\", \"walletname\": \"$walletname\"}" | jq .

# Generate docker-compose.yml with the provided input
cat > docker-compose.yml <<EOL
version: '3'
services:
  bitcoind:
    image: mocacinno/btc_testnet4:bci_node
    privileged: true
    container_name: bitcoind
    volumes:
      - /root/project/run_btc_testnet4/data:/root/.bitcoin/
    command: ["bitcoind", "-testnet4", "-server", "-txindex", "-rpcuser=$username", "-rpcpassword=$password", "-rpcallowip=0.0.0.0/0", "-rpcbind=0.0.0.0:5000"]
    ports:
      - "8333:8333"
      - "48332:48332"
      - "5000:5000"
EOL

echo "docker-compose.yml has been generated successfully."


docker compose up -d

docker exec -it bitcoind /bin/bash

bitcoin-cli -testnet4 -rpcuser=$username -rpcpassword=$password -rpcport=5000 createwallet $wallet

exit

# Download and run the upgrade script
echo "Connect Bitcoin Core and Run Indexert..."


