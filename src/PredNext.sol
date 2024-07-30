// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./PToken.sol";
import "./PoolToken.sol";

contract PredNext is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    PoolToken public poolToken;
    PToken public yesToken;
    PToken public noToken;

    uint256 public minIncrement;
    uint256 public totalPoolLiquidity;
    address public creator;

    enum Result {
        Pending,
        Yes,
        No
    }

    Result public result = Result.Pending;

    event SupplyLiquidity(address indexed provider, uint256 amount);
    event WithdrawLiquidity(address indexed provider, uint256 amount);
    event Swap(address indexed user, string option, uint256 amount);
    event ResultSet(string result);
    event Redeem(address indexed user, uint256 amount);

    constructor(uint256 _minIncrement, address initialAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
        _grantRole(ADMIN_ROLE, initialAdmin);

        poolToken = new PoolToken("Pool Token", "POOL", address(this));
        yesToken = new PToken("Yes Token", "YES", address(this));
        noToken = new PToken("No Token", "NO", address(this));
        minIncrement = _minIncrement;
        creator = msg.sender; // Set creator to deployer

        poolToken.mint(initialAdmin, 1000000 * 10 ** 18);
        yesToken.mint(initialAdmin, 1000000 * 10 ** 18);
        noToken.mint(initialAdmin, 1000000 * 10 ** 18);
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    function supplyLiquidity(uint256 amount) external {
        require(amount >= minIncrement, "Amount less than minimum increment");

        poolToken.transferFrom(msg.sender, address(this), amount);
        totalPoolLiquidity += amount;

        emit SupplyLiquidity(msg.sender, amount);
    }

    function withdrawLiquidity(uint256 amount) external {
        require(poolToken.balanceOf(msg.sender) >= amount, "Insufficient balance");

        totalPoolLiquidity -= amount;

        poolToken.transfer(msg.sender, amount);

        emit WithdrawLiquidity(msg.sender, amount);
    }

    function swap(string calldata option, uint256 amount) external {
        require(poolToken.balanceOf(msg.sender) >= amount, "Insufficient balance");

        // Transfer tokens from the caller to the contract
        poolToken.transferFrom(msg.sender, address(this), amount);

        // Mint corresponding tokens based on the option
        if (keccak256(bytes(option)) == keccak256(bytes("buy_yes"))) {
            yesToken.mint(msg.sender, amount);
        } else if (keccak256(bytes(option)) == keccak256(bytes("buy_no"))) {
            noToken.mint(msg.sender, amount);
        } else {
            revert("Invalid option");
        }

        emit Swap(msg.sender, option, amount);
    }

    function setResult(string calldata outcome) external onlyAdmin {
        require(result == Result.Pending, "Result already set");

        if (keccak256(bytes(outcome)) == keccak256(bytes("yes"))) {
            result = Result.Yes;
        } else if (keccak256(bytes(outcome)) == keccak256(bytes("no"))) {
            result = Result.No;
        } else {
            revert("Invalid outcome");
        }

        emit ResultSet(outcome);
    }

    function redeem(uint256 amount) external {
        require(result != Result.Pending, "Result not set");

        if (result == Result.Yes) {
            require(yesToken.balanceOf(msg.sender) >= amount, "Insufficient balance");
            yesToken.transferFrom(msg.sender, address(this), amount);
            poolToken.transfer(msg.sender, amount);
        } else if (result == Result.No) {
            require(noToken.balanceOf(msg.sender) >= amount, "Insufficient balance");
            noToken.transferFrom(msg.sender, address(this), amount);
            poolToken.transfer(msg.sender, amount);
        }

        emit Redeem(msg.sender, amount);
    }
}
