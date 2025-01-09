// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./interfaces/IUniswapV3Factory.sol";
import "./interfaces/IUniswapV3Pool.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/INonfungiblePositionManager.sol";

contract LiquidityManager {
  address public immutable factory;
  address public immutable weth;
  address public immutable usdc;
  uint24 public immutable feeTier;
  int24 public immutable tickSpacing;
  INonfungiblePositionManager public immutable positionManager;

  // Events for important state changes
  event PositionCreated(uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
  event FeesCollected(uint256 tokenId, uint256 amount0, uint256 amount1);

  constructor(
    address _factory,
    address _weth,
    address _usdc,
    address _positionManager,
    uint24 _feeTier,
    int24 _tickSpacing
  ) {
    require(_factory != address(0), "Invalid factory address");
    require(_weth != address(0), "Invalid WETH address");
    require(_usdc != address(0), "Invalid USDC address");
    require(_positionManager != address(0), "Invalid position manager address");
    
    factory = _factory;
    weth = _weth;
    usdc = _usdc;
    positionManager = INonfungiblePositionManager(_positionManager);
    feeTier = _feeTier;
    tickSpacing = _tickSpacing;
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

  function createPosition(INonfungiblePositionManager.MintParams calldata params)
    external
    returns (
      uint256 tokenId,
      uint128 liquidity,
      uint256 amount0,
      uint256 amount1
    )
  {
    // Verify tokens match our configuration
    require(
      (params.token0 == weth && params.token1 == usdc) ||
      (params.token0 == usdc && params.token1 == weth),
      "Invalid token pair"
    );
    
    // Verify fee tier matches configuration
    require(params.fee == feeTier, "Invalid fee tier");
    require(params.tickLower < params.tickUpper, "Invalid tick range");
    require(params.tickLower % tickSpacing == 0, "Invalid lower tick");
    require(params.tickUpper % tickSpacing == 0, "Invalid upper tick");

    // Transfer tokens to this contract
    IERC20(params.token0).transferFrom(msg.sender, address(this), params.amount0Desired);
    IERC20(params.token1).transferFrom(msg.sender, address(this), params.amount1Desired);

    // Approve position manager to spend tokens
    IERC20(params.token0).approve(address(positionManager), params.amount0Desired);
    IERC20(params.token1).approve(address(positionManager), params.amount1Desired);

    // Create the position
    (tokenId, liquidity, amount0, amount1) = positionManager.mint(params);

    // Handle refunds
    if (amount0 < params.amount0Desired) {
      IERC20(params.token0).approve(address(positionManager), 0); // Clear approval
      IERC20(params.token0).transfer(msg.sender, params.amount0Desired - amount0);
    }
    if (amount1 < params.amount1Desired) {
      IERC20(params.token1).approve(address(positionManager), 0); // Clear approval
      IERC20(params.token1).transfer(msg.sender, params.amount1Desired - amount1);
    }

    emit PositionCreated(tokenId, liquidity, amount0, amount1);
  }

  /// @notice Gets information about a liquidity position

  function  getPosition(uint256 tokenId) 
    external 
    view 
    returns (
      uint128 liquidity,
      uint256 feeGrowthInside0LastX128,
      uint256 feeGrowthInside1LastX128,
      uint128 tokensOwed0,
      uint128 tokensOwed1
    )
  {
    (
      ,
      ,
      ,
      ,
      ,
      ,
      ,
      liquidity,
      feeGrowthInside0LastX128,
      feeGrowthInside1LastX128,
      tokensOwed0,
      tokensOwed1
    ) = positionManager.positions(tokenId);
  }

  /// @notice Collect accumulated fees for a position

  function collectFees(uint256 tokenId) external returns (uint256 amount0, uint256 amount1) {
    // Create collection parameters
    INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
      tokenId: tokenId,
      recipient: msg.sender,
      amount0Max: type(uint128).max,
      amount1Max: type(uint128).max
    });

    // Collect the fees through the position manager
    (amount0, amount1) = positionManager.collect(params);

    emit FeesCollected(tokenId, amount0, amount1);
  }
}
