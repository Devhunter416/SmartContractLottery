## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```


# Proveably Random Raffle Contracts

## About


This code is to create Proveably Random Raffle Contractsa

## Objective
1. Users can enter by paying a ticket
    -  The ticket fees are going to go to the winner during the draw.
2. After X period of time the winner will be decided by the lottery.
    - And this will be done programmatically
3. Using Chainlink VRF & Chainlink Automation
    - Chainlink VRF -> Randomness
    - Chainlink Automation -> Time based trigger


## Tests!
1. Write deploy scripts
2. write tests
    1. work on local
    2. forked testnet
    3. forked mainnet
## TODO
In video it fails if you dont add deployerKey to funding, but I tried now and it works perfectly, so if it fails, must add the deployerKey in FUndSUb
