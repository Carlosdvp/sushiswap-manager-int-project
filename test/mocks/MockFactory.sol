// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../../src/interfaces/IUniswapV3Factory.sol";
import "./MockPool.sol";

contract MockFactory is IUniswapV3Factory {
  // Mapping to store pool addresses for token pairs and fee combinations
  mapping(address => mapping(address => mapping(uint24 => address))) public getPool;
  
  // Mapping to store fee amounts and their corresponding tick spacings
  mapping(uint24 => int24) public feeAmountTickSpacing;

  constructor() {
    // Initialize standard fee tiers and tick spacings
    feeAmountTickSpacing[500] = 10;   // 0.05% fee tier
    feeAmountTickSpacing[3000] = 60;  // 0.3% fee tier
    feeAmountTickSpacing[10000] = 200; // 1% fee tier
  }

  function createPool(
    address tokenA,
    address tokenB,
    uint24 fee
  ) external returns (address pool) {
    require(tokenA != tokenB, "Same token");
    require(tokenA != address(0) && tokenB != address(0), "Zero address");
    require(getPool[tokenA][tokenB][fee] == address(0), "Pool exists");
    require(feeAmountTickSpacing[fee] != 0, "Invalid fee");

    // Ensure tokens are sorted
    (address token0, address token1) = tokenA < tokenB 
      ? (tokenA, tokenB) 
      : (tokenB, tokenA);

    // Create new mock pool
    pool = address(new MockPool(token0, token1, fee));

    // Store pool address in mappings (both directions)
    getPool[token0][token1][fee] = pool;
    getPool[token1][token0][fee] = pool;

    return pool;
  }
}
