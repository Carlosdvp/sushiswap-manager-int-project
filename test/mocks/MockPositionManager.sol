// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../../src/interfaces/INonfungiblePositionManager.sol";

contract MockPositionManager {
  uint256 private nextTokenId = 1;
  
  mapping(uint256 => Position) public positions;
  
  struct Position {
    uint96 nonce;
    address operator;
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint128 liquidity;
    uint256 feeGrowthInside0LastX128;
    uint256 feeGrowthInside1LastX128;
    uint128 tokensOwed0;
    uint128 tokensOwed1;
  }

  function mint(INonfungiblePositionManager.MintParams calldata params)
    external
    returns (
      uint256 tokenId,
      uint128 liquidity,
      uint256 amount0,
      uint256 amount1
    )
  {
    tokenId = nextTokenId++;
    liquidity = 1e18; // Mock liquidity amount
    amount0 = params.amount0Desired;
    amount1 = params.amount1Desired;

    positions[tokenId] = Position({
      nonce: 0,
      operator: address(0),
      token0: params.token0,
      token1: params.token1,
      fee: params.fee,
      tickLower: params.tickLower,
      tickUpper: params.tickUpper,
      liquidity: liquidity,
      feeGrowthInside0LastX128: 0,
      feeGrowthInside1LastX128: 0,
      tokensOwed0: 0,
      tokensOwed1: 0
    });
  }

  function collect(INonfungiblePositionManager.CollectParams calldata params)
    external
    returns (uint256 amount0, uint256 amount1)
  {
    Position storage position = positions[params.tokenId];
    
    // Return accumulated fees
    amount0 = position.tokensOwed0;
    amount1 = position.tokensOwed1;
    
    // Reset accumulated fees after collection
    position.tokensOwed0 = 0;
    position.tokensOwed1 = 0;
    
    return (amount0, amount1);
  }
}
