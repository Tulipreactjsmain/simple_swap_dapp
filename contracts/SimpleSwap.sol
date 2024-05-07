// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract SimpleSwap {
    address public owner; // Owner of the contract
    IERC20 public usdt; // USDT contract address
    uint public exchangeRate; // Exchange rate of 1 USDT to ETH (wei)

    event Swapped(address indexed from, uint amount);

    constructor(address _usdtAddress, uint _exchangeRate) {
        owner = msg.sender;
        usdt = IERC20(_usdtAddress);
        exchangeRate = _exchangeRate;
    }

    function swap(uint _usdtAmount) external {
        require(_usdtAmount > 0, "USDT amount must be greater than zero");

        require(
            usdt.transferFrom(msg.sender, address(this), _usdtAmount),
            "USDT transfer failed"
        );
        uint ethAmount = (_usdtAmount * exchangeRate) / (10 ** 18);
        (bool success, ) = msg.sender.call{value: ethAmount}("");
        require(success, "ETH transfer failed");

        emit Swapped(msg.sender, _usdtAmount);
    }
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw ETH");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "ETH withdrawal failed");
    }
}
