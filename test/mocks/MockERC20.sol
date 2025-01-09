// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../../src/interfaces/IERC20.sol";

contract MockERC20 is IERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  mapping(address => uint256) public balances;
  mapping(address => mapping(address => uint256)) public allowances;

  constructor(string memory _name, string memory _symbol, uint8 _decimals) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }

  function balanceOf(address account) external view returns (uint256) {
    return balances[account];
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    balances[msg.sender] -= amount;
    balances[recipient] += amount;
    return true;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    allowances[msg.sender][spender] = amount;
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    balances[sender] -= amount;
    balances[recipient] += amount;
    allowances[sender][msg.sender] -= amount;
    return true;
  }

  function allowance(address owner, address spender) external view returns (uint256) {
    return allowances[owner][spender];
  }

  // Helper method for testing
  function mint(address to, uint256 amount) external {
    balances[to] += amount;
  }
}
