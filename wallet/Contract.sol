// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Wallet {
    address public owner;

    event Received(address indexed sender, uint256 amount);
    event SentETH(address indexed recipient, uint256 amount);
    event SentToken(address indexed token, address indexed recipient, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Получение ETH на контракт
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // Отправка ETH с контракта
    function sendETH(address payable _recipient, uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Insufficient balance");
        _recipient.transfer(_amount);
        emit SentETH(_recipient, _amount);
    }

    // Получение токенов ERC-20 (пользователь должен сначала сделать approve)
    function receiveToken(address _token, uint256 _amount) external {
        IERC20 token = IERC20(_token);
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        emit Received(msg.sender, _amount);
    }

    // Отправка токенов ERC-20
    function sendToken(address _token, address _recipient, uint256 _amount) external onlyOwner {
        IERC20 token = IERC20(_token);
        require(token.balanceOf(address(this)) >= _amount, "Insufficient token balance");
        require(token.transfer(_recipient, _amount), "Transfer failed");
        emit SentToken(_token, _recipient, _amount);
    }

    // Проверка баланса контракта
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance(address _token) external view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }
}
