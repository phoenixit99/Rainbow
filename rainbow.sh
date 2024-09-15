#!/bin/bash

# Welcome message with ASCII art
clear
cat << "EOF"
                                                                    
  H   H  EEEEE  N   N  RRRR   Y    Y     N   N  OOO   DDDD   EEEEE 
  H   H  E      NN  N  R   R    Y Y      NN  N O   O  D   D  E     
  HHHHH  EEEE   N N N  RRRR      Y       N N N O   O  D   D  EEEE  
  H   H  E      N  NN  R  R      Y       N  NN O   O  D   D  E     
  H   H  EEEEE  N   N  R   R     Y       N   N  OOO   DDDD   EEEEE 
                                                                    
EOF

# Exit script on error
set -e

# Setup directory and clean up any previous run
cd "$HOME"
rm -f rainbow.sh
mkdir -p rainbown
cd rainbown

# Clone the repository if it doesn't exist
if [ ! -d "btc_testnet4" ]; then
  initial_setup=0
  git clone https://github.com/rainbowprotocol-xyz/btc_testnet4
else
  initial_setup=1
fi

cd btc_testnet4

# Setup message based on initial setup status
if [ "$initial_setup" -eq 0 ]; then
  echo "{\"The Rainbow prepare for setup\"}" | jq .
else
  echo "{\"The Rainbow already setup, Should prepare for update\"}" | jq .
fi

# Prompt user for input
read -p "Enter your username: " username
read -s -p "Enter your password: " password
echo ""
read -p "Enter your wallet name: " walletname

# Ensure username, password, and wallet name are not empty
if [[ -z "$username" || -z "$password" || -z "$walletname" ]]; then
  echo "Error: All fields (username, password, wallet name) must be filled."
  exit 1
fi

# Check if jq is installed, install it if not
# if ! command -v jq &> /dev/null; then
#   echo "jq is not installed. Installing jq..."
#   if [[ "$OSTYPE" == "linux-gnu"* ]]; then
#     sudo apt-get update
#     sudo apt-get install -y jq
#   elif [[ "$OSTYPE" == "darwin"* ]]; then
#     brew install jq
#   else
#     echo "Unsupported OS. Please install jq manually."
#     exit 1
#   fi
# fi

# Output input variables with jq (optional)
echo "{\"username\": \"$username\", \"password\": \"$password\", \"walletname\": \"$walletname\"}" | jq .

if [ "$initial_setup" -eq 0 ]; then
  # Generate docker-compose.yml
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
  until docker exec bitcoind bitcoin-cli -testnet4 -rpcuser="$username" -rpcpassword="$password" -rpcport=5000 getblockchaininfo > /dev/null 2>&1; do
    echo "Waiting for bitcoind..."
    sleep 10
  done

  # Create the Bitcoin wallet
  echo "Creating Bitcoin wallet..."
  docker exec -it bitcoind /bin/bash -c "
    bitcoin-cli -testnet4 -rpcuser=$username -rpcpassword=$password -rpcport=5000 createwallet $walletname
  "
fi

# Define Bitcoin Core RPC endpoint
bitcoin_core_endpoint="http://localhost:5000"

# Clone the indexer repository and setup the RBO worker
cd "$HOME/rainbown"

if [ ! -d "rbo_indexer_testnet" ]; then
  echo "Cloning RBO indexer..."
  git clone https://github.com/rainbowprotocol-xyz/rbo_indexer_testnet.git
else
  echo "Pulling updates for RBO indexer..."
  git pull https://github.com/rainbowprotocol-xyz/rbo_indexer_testnet.git
fi

cd rbo_indexer_testnet

# Download and extract the RBO worker
worker_version="rbo_worker-linux-amd64-0.0.2-20240914-4ec80a8"
worker_url="https://storage.googleapis.com/rbo/rbo_worker/$worker_version.tar.gz"

wget "$worker_url"
tar -xzvf "$worker_version.tar.gz"
rm "$worker_version.tar.gz"

cp "$worker_version/rbo_worker" rbo_worker
rm -r "$worker_version"

chmod +x rbo_worker

# Start the RBO worker
echo "Starting RBO worker..."
./rbo_worker worker --rpc "$bitcoin_core_endpoint" --password "$password" --username "$username" --start_height 42000

echo "Script completed successfully."