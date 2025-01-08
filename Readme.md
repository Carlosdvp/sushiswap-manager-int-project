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


****************************************************************************************************************

# Project Structure

src/
├── LiquidityManager.sol       # Main contract
└── interfaces/               # Only needed interfaces
    ├── IUniswapV3Pool.sol    
    └── IERC20.sol           

test/
└── LiquidityManager.t.sol    # Test suite

script/
└── Deploy.s.sol             # Deployment script



// Sepolia Addresses
address constant FACTORY = 0x4752ba5DBc23f44D87826276BF6FDfb1C372aD24;
address constant WETH = 0x4200000000000000000000000000000000000006;
address constant USDC = 0xce289bb9fb0A9591317981223cbE33d5dc42268E;

// Pool Parameters
uint24 constant FEE_TIER = 3000; // 0.3% standard fee tier
int24 constant TICK_SPACING = 60; // For 0.3% fee tier