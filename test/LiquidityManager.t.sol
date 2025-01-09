// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {LiquidityManager} from "../src/LiquidityManager.sol";
import {MockERC20} from "./mocks/MockERC20.sol";
import {MockPool} from "./mocks/MockPool.sol";
import {MockPositionManager} from "./mocks/MockPositionManager.sol";
import {MockFactory} from "./mocks/MockFactory.sol";
import {INonfungiblePositionManager} from "../src/interfaces/INonfungiblePositionManager.sol";

contract LiquidityManagerTest is Test {
  // Contracts
  LiquidityManager public manager;
  MockERC20 public weth;
  MockERC20 public usdc;
  MockPositionManager public positionManager;
  MockFactory public factory;

  // Test accounts
  address public liquidityProvider;

  // Constants
  uint24 constant FEE = 3000;
  int24 constant TICK_SPACING = 60;
  int24 constant TICK_LOWER = -60;
  int24 constant TICK_UPPER = 60;
  uint256 constant AMOUNT_WETH = 1e17; // 0.1 WETH
  uint256 constant AMOUNT_USDC = 1e8;  // 100 USDC

  function setUp() public {
    // Create test accounts
    liquidityProvider = makeAddr("liquidityProvider");

    // Deploy mock contracts
    weth = new MockERC20("Wrapped Ether", "WETH", 18);
    usdc = new MockERC20("USD Coin", "USDC", 6);
    factory = new MockFactory();
    positionManager = new MockPositionManager();

    // Deploy manager with mock addresses
    manager = new LiquidityManager(
      address(factory),
      address(weth),
      address(usdc),
      address(positionManager),
      FEE,
      TICK_SPACING
    );

    // Setup liquidity provider
    weth.mint(liquidityProvider, AMOUNT_WETH);
    usdc.mint(liquidityProvider, AMOUNT_USDC);

    vm.startPrank(liquidityProvider);
    weth.approve(address(manager), AMOUNT_WETH);
    usdc.approve(address(manager), AMOUNT_USDC);
    vm.stopPrank();
  }

    function testCreatePosition() public {
    vm.startPrank(liquidityProvider);

    INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
      token0: address(weth),
      token1: address(usdc),
      fee: FEE,
      tickLower: TICK_LOWER,
      tickUpper: TICK_UPPER,
      amount0Desired: AMOUNT_WETH,
      amount1Desired: AMOUNT_USDC,
      amount0Min: 0,
      amount1Min: 0,
      recipient: liquidityProvider,
      deadline: block.timestamp + 1 days
    });

    (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = 
      manager.createPosition(params);

    // Verify position
    assertGt(tokenId, 0, "Token ID should be non-zero");
    assertGt(liquidity, 0, "Liquidity should be non-zero");
    assertEq(amount0, AMOUNT_WETH, "Incorrect amount0");
    assertEq(amount1, AMOUNT_USDC, "Incorrect amount1");

    vm.stopPrank();
  }

    function testCollectFees() public {
    // First create a position
    vm.startPrank(liquidityProvider);
    
    INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
      token0: address(weth),
      token1: address(usdc),
      fee: FEE,
      tickLower: TICK_LOWER,
      tickUpper: TICK_UPPER,
      amount0Desired: AMOUNT_WETH,
      amount1Desired: AMOUNT_USDC,
      amount0Min: 0,
      amount1Min: 0,
      recipient: liquidityProvider,
      deadline: block.timestamp + 1 days
    });

    (uint256 tokenId,,, ) = manager.createPosition(params);

    // Simulate some time passing and fees accruing
    vm.warp(block.timestamp + 1 days);

    // Collect fees
    (uint256 fees0, uint256 fees1) = manager.collectFees(tokenId);

    // Verify fees were collected
    assertGt(fees0 + fees1, 0, "Should collect some fees");

    vm.stopPrank();
  }

  function testIntegrationWithWethUsdc() public {
    vm.startPrank(liquidityProvider);

    // First ensure pool exists by creating it if needed
    address poolAddress = factory.getPool(address(weth), address(usdc), FEE);
    if (poolAddress == address(0)) {
      factory.createPool(address(weth), address(usdc), FEE);
      poolAddress = factory.getPool(address(weth), address(usdc), FEE);
    }

    // Initialize pool with a reasonable price if needed
    MockPool pool = MockPool(poolAddress);

    if (pool.sqrtPriceX96() == 0) {
      // Calculate initial price (assuming 1 ETH = 1800 USDC)
      uint160 initialSqrtPrice = sqrtPriceX96(1800e6);
      pool.initialize(initialSqrtPrice);
    }

    // Create position parameters
    INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
      token0: address(weth),
      token1: address(usdc),
      fee: FEE,
      tickLower: TICK_LOWER,
      tickUpper: TICK_UPPER,
      amount0Desired: AMOUNT_WETH,
      amount1Desired: AMOUNT_USDC,
      amount0Min: 0,
      amount1Min: 0,
      recipient: liquidityProvider,
      deadline: block.timestamp + 1 days
    });

    // Create position through our manager
    (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = 
      manager.createPosition(params);

    // Verify position was created successfully
    assertGt(tokenId, 0, "Invalid token ID");
    assertGt(liquidity, 0, "No liquidity added");
    assertGt(amount0, 0, "No token0 added");
    assertGt(amount1, 0, "No token1 added");

    // Verify position details through manager
    (
      uint128 posLiquidity,
      uint256 feeGrowthInside0LastX128,
      uint256 feeGrowthInside1LastX128,
      uint128 tokensOwed0,
      uint128 tokensOwed1
    ) = manager.getPosition(tokenId);

    // Verify position details
    assertEq(posLiquidity, liquidity, "Liquidity mismatch");
    assertEq(tokensOwed0, 0, "Should start with no fees");
    assertEq(tokensOwed1, 0, "Should start with no fees");

    // Simulate some time passing and trading activity
    vm.warp(block.timestamp + 1 days);

    // Collect fees
    (uint256 collectedFees0, uint256 collectedFees1) = manager.collectFees(tokenId);

    // Verify fee collection
    assertGe(collectedFees0 + collectedFees1, 0, "Should collect some fees");

    vm.stopPrank();
  }

  // Helper function to calculate sqrtPriceX96
  function sqrtPriceX96(uint256 price) internal pure returns (uint160) {
    uint256 baseAmount = 1e18;  // 1 ETH (18 decimals)
    uint256 quoteAmount = price;  // USDC amount (6 decimals)
    uint256 ratioX96 = (quoteAmount << 96) / baseAmount;
    return uint160(sqrt(ratioX96));
  }

  // Helper function to calculate square root
  function sqrt(uint256 x) internal pure returns (uint256 y) {
    uint256 z = (x + 1) / 2;
    y = x;
    while (z < y) {
      y = z;
      z = (x / z + z) / 2;
    }
  }
}
