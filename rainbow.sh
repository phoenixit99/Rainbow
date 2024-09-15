#!/bin/bash
echo "                                                                   "
echo "                                                                   "
echo "                                                                   "
echo "                                                                   "
echo "  H   H  EEEEE  N   N  RRRR   Y    Y     N   N  OOO   DDDD   EEEEE "
echo "  H   H  E      NN  N  R   R    Y Y      NN  N O   O  D   D  E     "
echo "  HHHHH  EEEE   N N N  RRRR      Y       N N N O   O  D   D  EEEE  "
echo "  H   H  E      N  NN  R  R      Y       N  NN O   O  D   D  E     "
echo "  H   H  EEEEE  N   N  R   R     Y       N   N  OOO   DDDD   EEEEE "
echo "                                                                   "
echo "                                                                   "
echo "                                                                   "

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

# Check if jq is installed, install it if not
if ! command -v jq &> /dev/null
then
    echo "jq is not installed. Installing jq..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # For Debian/Ubuntu-based systems
        sudo apt-get update
        sudo apt-get install -y jq
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # For macOS
        brew install jq
    else
        echo "Unsupported OS. Please install jq manually."
        exit 1
    fi
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
  echo "Waiting for bitcoind..."
  sleep 10
done

# Connect to the Docker container and create the Bitcoin wallet
echo "Creating Bitcoin wallet..."
docker exec -it bitcoind /bin/bash -c "
  bitcoin-cli -testnet4 -rpcuser=$username -rpcpassword=$password -rpcport=5000 createwallet $walletname
"

# Define the Bitcoin Core RPC endpoint
bitcoin_core_endpoint="http://localhost:5000"

# Clone the indexer repository and download the worker
echo "Setting up the RBO indexer..."
cd $HOME/rainbown

if [ ! -d "rbo_indexer_testnet" ]; then
  echo "Clone the rbo..."
  git clone https://github.com/rainbowprotocol-xyz/rbo_indexer_testnet.git && cd rbo_indexer_testnet
fi
else 
  echo "pull the rbo..."
  git pull https://github.com/rainbowprotocol-xyz/rbo_indexer_testnet.git && cd rbo_indexer_testnet
fi

wget https://storage.googleapis.com/rbo/rbo_worker/rbo_worker-linux-amd64-0.0.2-20240914-4ec80a8.tar.gz && tar -xzvf rbo_worker-linux-amd64-0.0.2-20240914-4ec80a8.tar.gz
rm rbo_worker-linux-amd64-0.0.2-20240914-4ec80a8.tar.gz
cp rbo_worker-linux-amd64-0.0.2-20240914-4ec80a8/rbo_worker rbo_worker
rm -r rbo_worker-linux-amd64-0.0.2-20240914-4ec80a8

chmod +x rbo_worker




# Start the RBO worker
echo "Starting RBO worker..."
./rbo_worker worker --rpc $bitcoin_core_endpoint --password $password --username $username --start_height 42000

echo "Script completed successfully."
