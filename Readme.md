# SushiSwap V3 Liquidity Management Challenge Solution

## Overview
Successfully implemented a smart contract solution for managing liquidity positions in SushiSwap V3 pools, with focus on the WETH/USDC pair.

## Deployment 
- Contract Address: 0xd8604D72626FB914dA8c3A5AcF3D877a611A3EEd
- Network: Sepolia Testnet
- Deployment script included in `script/Deploy.s.sol`

## Features Implemented
1. Position Creation:
   - Create concentrated liquidity positions in WETH/USDC pool
   - Configurable fee tier and tick range
   - Handles token approvals and refunds

2. Position Monitoring:
   - Query current position status
   - Track liquidity and fees earned
   - Monitor current pool price 

3. Fee Collection:
   - Collect accumulated trading fees
   - Support for both WETH and USDC fees

4. Gas Optimization:
   - Efficient storage layout
   - Minimal state changes
   - Batched operations where possible

## Testing
- Comprehensive test suite in `test/LiquidityManager.t.sol`
- Mock contracts for isolated testing
- Integration tests with forked mainnet

## Quality Assurance
- Clean, documented code
- Gas optimized implementation
- Follows Solidity best practices
- Full test coverage

# SushiSwap V3 Liquidity Manager

## Features

- Create new liquidity positions
- Monitor position status and fees
- Collect accumulated fees
- Gas-optimized operations
- WETH/USDC pool support

## Technical Stack

- Solidity ^0.8.20
- Foundry for testing and deployment
- SushiSwap V3 core contracts

## Installation

Clone the repository:

```
git clone [repository-url]
cd liquidity-manager
```

## Install dependencies:

```
forge install
```

## Run tests:

```
forge test
```

# Usage

## Create Position

```
INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
  token0: WETH_ADDRESS,
  token1: USDC_ADDRESS,
  fee: 3000,
  tickLower: -60,
  tickUpper: 60,
  amount0Desired: 0.1 ether,
  amount1Desired: 100e6,
  amount0Min: 0,
  amount1Min: 0,
  recipient: msg.sender,
  deadline: block.timestamp + 1 days
});

(uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = 
  manager.createPosition(params);
```

## Collect Fees

```
(uint256 amount0, uint256 amount1) = manager.collectFees(tokenId);
```

## Monitor Position

```
(
  uint128 liquidity,
  uint256 feeGrowthInside0LastX128,
  uint256 feeGrowthInside1LastX128,
  uint128 tokensOwed0,
  uint128 tokensOwed1
) = manager.getPosition(tokenId);
```

# Testing

## Run the test suite:

```
forge test
```

## Run with gas reporting:
```
forge test --gas-report
```

****************************************************************************************************************

# Project Structure

```
src/
  ├── LiquidityManager.sol
  └── interfaces/
      ├── IERC20.sol
      ├── IUniswapV3Pool.sol
      ├── IUniswapV3Factory.sol
      └── INonfungiblePositionManager.sol
test/
  ├── LiquidityManager.t.sol
  └── mocks/
      ├── MockERC20.sol
      ├── MockPool.sol
      ├── MockFactory.sol
      └── MockPositionManager.sol

script/
└── Deploy.s.sol             # Deployment script
```


