// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/LiquidityManager.sol";

contract DeployScript is Script {
  function run() public {
    vm.startBroadcast();
    new LiquidityManager();
    vm.stopBroadcast();
  }
}
