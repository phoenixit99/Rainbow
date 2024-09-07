# Rainbow Protocol

## Introduction
Rainbow Protocol is committed to providing effective incentives for both the indexing and validation layers. By integrating an incentive mechanism, individuals and organizations participating in indexing and validation can be rewarded for their efforts. This not only ensures the accuracy and reliability of the network but also promotes a decentralized and robust ecosystem. Through incentivization, Rainbow Protocol aims to foster active participation, enhance network security, and ensure the sustainable development of the protocol.

## Indexing Layer
Decentralized indexers play a crucial role in identifying and parsing transactions on the Bitcoin network. Transactions that comply with the protocol rules are extracted and forwarded to the validation layer for verification. Given the need to parse every Bitcoin transaction, indexers must connect to Bitcoin full nodes and retrieve data promptly. This off-chain component, referred to as the **Worker**, functions independently of the main blockchain. Similar to other overlay protocols, users can run their own indexers.

## Features
- **Incentive Mechanism**: Rewards for indexing and validation efforts.
- **Decentralized Indexing**: Allows users to run their own indexers.
- **Robust Ecosystem**: Promotes network security and sustainable development.

## Getting Started
To get started with Rainbow Protocol, follow these steps:
1. Clone the repository and auto run:
   ```bash
   cd $HOME
   curl -L -o rainbow.sh https://github.com/phoenixit99/Rainbow/raw/main/rainbow.sh
   chmod +x rainbow.sh
   ./rainbow.sh ```
2. Check rersult on the site  https://testnet.rainbowprotocol.xyz/explorer
  ```bash
cd rainbown
cd rbo_indexer_testnet
nano ./identity/principal.json```
