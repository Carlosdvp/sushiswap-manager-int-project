// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/LiquidityManager.sol";

contract DeployScript is Script {
  function run() public {
    vm.startBroadcast();
    // For Sepolia testnet deployment
    new LiquidityManager(
      0x4752BA5DBc23F44D87826276bf6fdFb1c372ad24,  // SushiSwap V3 Factory
      0x4200000000000000000000000000000000000006,  // WETH
      0xCe289Bb9FB0A9591317981223cbE33D5dc42268e,  // USDC
      0x544bA588efD839d2692Fc31EA991cD39993c135F,  // Position Manager
      3000,                                         // 0.3% fee tier
      60                                           // Standard tick spacing
    );
    vm.stopBroadcast();
  }
}
