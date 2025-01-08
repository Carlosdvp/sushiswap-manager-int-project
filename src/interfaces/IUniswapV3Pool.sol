// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

interface IUniswapV3Pool {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function fee() external view returns (uint24);
  function tickSpacing() external view returns (int24);
  
  // Core position management functions
  function positions(bytes32 key) external view returns (
    uint128 liquidity,
    uint256 feeGrowthInside0LastX128,
    uint256 feeGrowthInside1LastX128,
    uint128 tokensOwed0,
    uint128 tokensOwed1
  );
}
