// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../../src/interfaces/IUniswapV3Pool.sol";

contract MockPool is IUniswapV3Pool {
  uint160 public sqrtPriceX96;
  mapping(bytes32 => Position) private _positions;

  address public immutable token0;
  address public immutable token1;
  uint24 public immutable fee;

  struct Position {
    uint128 liquidity;
    uint256 feeGrowthInside0LastX128;
    uint256 feeGrowthInside1LastX128;
    uint128 tokensOwed0;
    uint128 tokensOwed1;
  }

  // Constructor to initialize token addresses and fee tier
  constructor(address _token0, address _token1, uint24 _fee) {
    token0 = _token0;
    token1 = _token1;
    fee = _fee;
  }

  function tickSpacing() external pure returns (int24) {
    return 60;
  }

  function initialize(uint160 _sqrtPriceX96) external {
    require(sqrtPriceX96 == 0, "Already initialized");
    sqrtPriceX96 = _sqrtPriceX96;
  }

  function positions(bytes32 key) external view returns (
    uint128 liquidity,
    uint256 feeGrowthInside0LastX128,
    uint256 feeGrowthInside1LastX128,
    uint128 tokensOwed0,
    uint128 tokensOwed1
  ) {
    Position memory position = _positions[key];
    return (
      position.liquidity,
      position.feeGrowthInside0LastX128,
      position.feeGrowthInside1LastX128,
      position.tokensOwed0,
      position.tokensOwed1
    );
  }

  function mint(
    address owner,
    int24 tickLower,
    int24 tickUpper,
    uint128 amount,
    bytes calldata
  ) external returns (uint256 amount0, uint256 amount1) {
    bytes32 key = keccak256(abi.encodePacked(owner, tickLower, tickUpper));
    Position storage position = _positions[key];
    position.liquidity += amount;

    // Simulate returning amounts proportional to the liquidity
    return (amount, amount);
  }

  function collect(
    address,
    int24,
    int24,
    uint128,
    uint128
  ) external pure returns (uint128 amount0, uint128 amount1) {
    return (0, 0);
  }

  function burn(
    int24 tickLower,
    int24 tickUpper,
    uint128 amount
  ) external returns (uint256 amount0, uint256 amount1) {
    bytes32 positionKey = keccak256(abi.encodePacked(msg.sender, tickLower, tickUpper));
    require(_positions[positionKey].liquidity >= amount, "Not enough liquidity");
    _positions[positionKey].liquidity -= amount;

    return (amount, amount);
  }

  function swap(
    address recipient,
    bool zeroForOne,
    int256 amountSpecified,
    uint160 sqrtPriceLimitX96,
    bytes calldata data
  ) external returns (int256 amount0, int256 amount1) {
    return (amountSpecified, -amountSpecified);
  }

  function flash(
    address recipient,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external {}

  function slot0() external view returns (
    uint160 sqrtPriceX96_,
    int24 tick,
    uint16 observationIndex,
    uint16 observationCardinality,
    uint16 observationCardinalityNext,
    uint8 feeProtocol,
    bool unlocked
  ) {
    require(sqrtPriceX96 != 0, "Not initialized");
    return (sqrtPriceX96, 0, 0, 0, 0, 0, true);
  }
}
