// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

interface IUniswapV3Pool {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function fee() external view returns (uint24);
  function tickSpacing() external view returns (int24);
  
  function positions(bytes32 key) external view returns (
    uint128 liquidity,
    uint256 feeGrowthInside0LastX128,
    uint256 feeGrowthInside1LastX128,
    uint128 tokensOwed0,
    uint128 tokensOwed1
  );

  function mint(
    address recipient,
    int24 tickLower,
    int24 tickUpper,
    uint128 amount,
    bytes calldata data
  ) external returns (uint256 amount0, uint256 amount1);

  function collect(
    address recipient,
    int24 tickLower,
    int24 tickUpper,
    uint128 amount0Requested,
    uint128 amount1Requested
  ) external returns (uint128 amount0, uint128 amount1);
}
