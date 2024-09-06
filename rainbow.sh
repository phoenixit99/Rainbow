#!/bin/bash

set -e  # Exit script on error

# Setup directory and clean up any previous run
cd $HOME
rm -f rainbow.sh
mkdir -p rainbown
cd rainbown

# Clone the repository
if [ ! -d "btc_testnet4" ]; then
  git clone https://github.com/rainbowprotocol-xyz/btc_testnet4
fi
cd btc_testnet4

# Prompt user for input
read -p "Enter your username: " username
read -s -p "Enter your password: " password
echo ""
read -p "Enter your walletName: " walletname

# Ensure username, password, and wallet name are not empty
if [[ -z "$username" || -z "$password" || -z "$walletname" ]]; then
  echo "Error: All fields (username, password, wallet name) must be filled."
  exit 1
fi

# Output variables with jq (optional)
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

# Start Docker container
echo "Starting Docker container..."
docker compose up -d

# Wait until the container is fully ready
echo "Waiting for bitcoind service to be ready..."
until docker exec bitcoind bitcoin-cli -testnet4 -rpcuser=$username -rpcpassword=$password -rpcport=5000 getblockchaininfo > /dev/null 2>&1; do
  sleep 5
done

# Connect to the Docker container
echo "Connecting to bitcoind container..."
docker exec -it bitcoind /bin/bash -c "
  echo 'Creating Bitcoin wallet...'
  bitcoin-cli -testnet4 -rpcuser=$username -rpcpassword=$password -rpcport=5000 createwallet $walletname
"

# Download and run the upgrade script (if necessary)
echo "Connect Bitcoin Core and Run Indexert..."
# Your upgrade or indexer script goes here

echo "Script completed successfully."
exit
