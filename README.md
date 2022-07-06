# Dapp tools by DappHub [![Chat](https://img.shields.io/badge/community-chat-blue.svg?style=flat-square)](https://dapphub.chat)

Hello!

`dapptools` is a suite of Ethereum focused CLI tools following the Unix design philosophy,
favoring composability, configurability and extensibility.

This repository contains the source code for several programs
hand-crafted and maintained by DappHub, along with dependency management, courtesy of Nix.

- [dapp](./src/dapp) - All you need Ethereum development tool. Build, test, fuzz, formally verify, debug & deploy solidity contracts.
- [seth](./src/seth) - Ethereum CLI. Query contracts, send transactions, follow logs, slice & dice data.
- [hevm](./src/hevm) - Testing oriented EVM implementation. Debug, fuzz, or symbolically execute code against local or mainnet state.
- [ethsign](./src/ethsign) - Sign Ethereum transactions from a local keystore or hardware wallet.

## Development Status

dapptools is currently in a stage of clandestine development where support for the casual user may
be deprived. The software can now be considered free as in free puppy. Users seeking guidance can
explore using foundry as an alternative

## Installation

Install Nix if you haven't already ([instructions](https://nixos.org/download.html)). Then install dapptools:

```
curl https://dapp.tools/install | sh
```

This configures the dapphub binary cache and installs the `dapp`, `solc`, `seth` and `hevm` executables.