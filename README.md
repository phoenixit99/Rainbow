# Rainbow Protocol 

<img height="100" alt="logo" src="https://github.com/phoenixit99/Rainbow/blob/main/Screenshot%202024-09-08%20at%207.56.20%E2%80%AFAM.png">


Docs (https://github.com/rainbowprotocol-xyz)

## Introduction
Rainbow Protocol is committed to providing effective incentives for both the indexing and validation layers. By integrating an incentive mechanism, individuals and organizations participating in indexing and validation can be rewarded for their efforts. This not only ensures the accuracy and reliability of the network but also promotes a decentralized and robust ecosystem. Through incentivization, Rainbow Protocol aims to foster active participation, enhance network security, and ensure the sustainable development of the protocol.

## Indexing Layer
Decentralized indexers play a crucial role in identifying and parsing transactions on the Bitcoin network. Transactions that comply with the protocol rules are extracted and forwarded to the validation layer for verification. Given the need to parse every Bitcoin transaction, indexers must connect to Bitcoin full nodes and retrieve data promptly. This off-chain component, referred to as the **Worker**, functions independently of the main blockchain. Similar to other overlay protocols, users can run their own indexers.

## Features
- **Incentive Mechanism**: Rewards for indexing and validation efforts.
- **Decentralized Indexing**: Allows users to run their own indexers.
- **Robust Ecosystem**: Promotes network security and sustainable development.

## Getting Started with Rainbow Protocol
### Manual Install
1. Run bitcoin for testnet4 at https://github.com/rainbowprotocol-xyz/btc_testnet4 
2. Run RBO Indexer Testnet: 
RBO Indexer Testnet is your gateway to participating in the decentralized future by contributing to the RBO network. By running this application, you can:

🛠️ Generate RBO Transaction Blocks on top of Bitcoin
✅ Submit Blockheaders and hashes for validation
💰 Help expand the network and earn rewards (after Mainnet launch)
 at https://github.com/rainbowprotocol-xyz/rbo_indexer_testnet 

### Auto Install
1. Clone the repository and auto run:
   ```bash
   cd $HOME
   curl -L -o rainbow.sh https://github.com/phoenixit99/Rainbow/raw/main/rainbow.sh
   chmod +x rainbow.sh
   ./rainbow.sh ```
2. Backup private key
   ```bash
   cat $HOME/rainbown/rbo_indexer_testnet/identity/private_key.pem
      
4. Check rersult on the site  https://testnet.rainbowprotocol.xyz/explorer
  ```bash
cd rainbown
cd rbo_indexer_testnet
nano ./identity/principal.json
