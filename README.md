# Bloom Finance

## Introduction

### What is Bloom?

Bloom is a Real Estate Investment Trust or REIT that allows investors to invest in both crypto currency and fiat. Like any other REIT, Bloom invests in Real Estate and leases space and collects rent on it's properties. The company generates income which is then paid out to shareholders.

This repository contains the source code for the smart contracts that make up the Bloom Finance Protocol.

- [Treasury](./src/Treasury.sol) - The Treasury contract will be the focal point within the protocol in which all assets will flow. This contract will keep track of all accounting within the protocol. It will account for all assets, investors, and dividends for all projects within the Bloom Project.
  
- [SwapInterface](./src/SwapInterface.sol) - The SwapInterface.sol file will be in charge of incoming assets and will use curve protocol to swap the incoming asset to USDC. It will then send the asset to the Treasury where it's accounted for. This contract will be the direct contract being interfaced by the Investor UI.
  
- [BloomToken](./src/BloomToken.sol) - This contract will be used to mint investors "soulbound" tokens which will act as their receipt for investing into the fund. The investor will be minted the USD equivalent of their investment in BLOOM tokens.

**NOTE:** This framework is [dapptools](https://github.com/dapphub/dapptools), a suite of Ethereum focused CLI tools following the Unix design philosophy, favoring composability, configurability and extensibility. If you do not have dapptools installed, please locate the dapptools github repo and follow the installation instructions.

[![Homepage](https://img.shields.io/badge/Elevate%20Software-Homepage-brightgreen)](https://www.elevatesoftware.io/)