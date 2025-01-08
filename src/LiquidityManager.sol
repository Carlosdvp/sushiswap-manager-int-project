// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./interfaces/IUniswapV3Factory.sol";
import "./interfaces/IUniswapV3Pool.sol";
import "./interfaces/IERC20.sol";

contract LiquidityManager {
  // Constants with correct checksums
  address public constant FACTORY = 0x4752BA5DBc23F44D87826276bf6fdFb1c372ad24;
  address public constant WETH = 0x4200000000000000000000000000000000000006;
  address public constant USDC = 0xCe289Bb9FB0A9591317981223cbE33D5dc42268e;
  
  uint24 public constant FEE_TIER = 3000; // 0.3%
  int24 public constant TICK_SPACING = 60;

  IUniswapV3Factory public immutable factory;

  constructor() {
    factory = IUniswapV3Factory(FACTORY);
  }

  /// @notice Calculate a position's key for looking up position info.

  function getPositionKey(
    address owner,
    int24 tickLower,
    int24 tickUpper
  ) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(owner, tickLower, tickUpper));
  }

  /// @notice Create a new liquidity position
  /// @param tickLower The lower tick of the position
  /// @param tickUpper The upper tick of the position
  /// @param amount0 The amount of token0 (WETH) to add
  /// @param amount1 The amount of token1 (USDC) to add

  function createPosition(
    int24 tickLower,
    int24 tickUpper,
    uint256 amount0,
    uint256 amount1
  ) external returns (uint128 liquidity) {
    require(tickLower < tickUpper, "TL");
    require(tickLower % TICK_SPACING == 0, "TLM");
    require(tickUpper % TICK_SPACING == 0, "TUM");
    
    address poolAddress = factory.getPool(WETH, USDC, FEE_TIER);
    require(poolAddress != address(0), "PI");
    IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);

    // Transfer tokens
    if (amount0 > 0) {
      IERC20(WETH).transferFrom(msg.sender, address(this), amount0);
      IERC20(WETH).approve(address(pool), amount0);
    }
    if (amount1 > 0) {
      IERC20(USDC).transferFrom(msg.sender, address(this), amount1);
      IERC20(USDC).approve(address(pool), amount1);
    }

    // Add liquidity to pool
    uint128 liquidityAmount = uint128(amount0);

    (uint256 amount0Added, uint256 amount1Added) = pool.mint(
      address(this),
      tickLower,
      tickUpper,
      liquidityAmount,
      ""  // No callback data needed
    );
    require(amount0Added > 0 || amount1Added > 0, "NL");

    return liquidity;
  }

  /// @notice Get info about a liquidity position
  /// @param tickLower The lower tick of the position
  /// @param tickUpper The upper tick of the position

  function getPosition(
    int24 tickLower,
    int24 tickUpper
  ) external view returns (
    uint128 liquidity,
    uint256 feeGrowthInside0X128,
    uint256 feeGrowthInside1X128
  ) {
    address poolAddress = factory.getPool(WETH, USDC, FEE_TIER);
    require(poolAddress != address(0), "PI");
    
    bytes32 positionKey = getPositionKey(msg.sender, tickLower, tickUpper);
    
    // Destructure all values from positions() call
    (
      uint128 _liquidity,
      uint256 _feeGrowthInside0LastX128,
      uint256 _feeGrowthInside1LastX128,
      ,
    ) = IUniswapV3Pool(poolAddress).positions(positionKey);

    return (
      _liquidity,
      _feeGrowthInside0LastX128,
      _feeGrowthInside1LastX128
    );
  }

  /// @notice Collect accumulated fees for a position
  /// @param tickLower The lower tick of the position
  /// @param tickUpper The upper tick of the position

  function collectFees(
    int24 tickLower,
    int24 tickUpper
  ) external returns (uint256 amount0, uint256 amount1) {
    address poolAddress = factory.getPool(WETH, USDC, FEE_TIER);
    require(poolAddress != address(0), "PI");

     IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);
    
    // Collect fees
    (amount0, amount1) = pool.collect(
      address(this),
      tickLower,
      tickUpper,
      type(uint128).max,  // Collect all token0 fees
      type(uint128).max   // Collect all token1 fees
    );

    // Transfer collected fees to user
    if (amount0 > 0) {
      IERC20(WETH).transfer(msg.sender, amount0);
    }
    if (amount1 > 0) {
      IERC20(USDC).transfer(msg.sender, amount1);
    }
    
    return (amount0, amount1);
  }
}
