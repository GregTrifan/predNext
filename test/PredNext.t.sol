// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {PredNext} from "../src/PredNext.sol";
import {PToken} from "../src/PToken.sol";
import {PoolToken} from "../src/PoolToken.sol";

contract PredNextTest is Test {
    PredNext predNext;
    PoolToken poolToken;
    PToken yesToken;
    PToken noToken;

    address admin;
    address user1;
    address user2;
    uint256 minIncrement;

    function setUp() public {
        address initialAdmin = address(this);
        user1 = address(0x2);
        user2 = address(0x3);
        admin = initialAdmin;

        // Deploy the PredNext contract with admin role
        predNext = new PredNext(100, initialAdmin); // Min increment is 100 tokens
        poolToken = predNext.poolToken();
        yesToken = predNext.yesToken();
        noToken = predNext.noToken();

        // Transfer initial tokens for users
        vm.startPrank(initialAdmin);

        poolToken.transfer(user1, 1000 * 10 ** 18);
        poolToken.transfer(user2, 1000 * 10 ** 18);

        vm.stopPrank();

        // Approve the PredNext contract to spend tokens
        vm.startPrank(user1);
        poolToken.approve(address(predNext), 1000 * 10 ** 18);
        vm.stopPrank();

        vm.startPrank(user2);
        poolToken.approve(address(predNext), 1000 * 10 ** 18);
        vm.stopPrank();
    }

    function testSupplyLiquidity() public {
        vm.prank(user1);

        predNext.supplyLiquidity(500 * 10 ** 18);

        assertEq(poolToken.balanceOf(address(predNext)), 500 * 10 ** 18);
        assertEq(predNext.totalPoolLiquidity(), 500 * 10 ** 18);
        assertEq(poolToken.balanceOf(user1), 500 * 10 ** 18);
    }

    function testWithdrawLiquidity() public {
        vm.prank(user1);
        predNext.supplyLiquidity(500 * 10 ** 18);
        vm.prank(user1);
        predNext.withdrawLiquidity(500 * 10 ** 18);

        assertEq(poolToken.balanceOf(address(predNext)), 0);
        assertEq(poolToken.balanceOf(user1), 1000 * 1e18);
    }

    function testSwapTokens() public {
        vm.prank(user1);
        poolToken.approve(address(predNext), 100 * 10 ** 18);

        uint256 initialBalance = poolToken.balanceOf(user1);

        vm.prank(user1);
        predNext.swap("buy_yes", 100 * 10 ** 18);

        assertEq(yesToken.balanceOf(user1), 100 * 10 ** 18);
        assertEq(poolToken.balanceOf(user1), initialBalance - 100 * 10 ** 18);

        vm.prank(user1);
        poolToken.approve(address(predNext), 100 * 10 ** 18);

        vm.prank(user1);
        predNext.swap("buy_no", 100 * 10 ** 18);

        assertEq(noToken.balanceOf(user1), 100 * 10 ** 18);
        assertEq(poolToken.balanceOf(user1), initialBalance - (2 * 100) * 10 ** 18);
    }

    function testSetResult() public {
        vm.prank(admin);
        predNext.setResult("yes");

        assertEq(uint256(predNext.result()), uint256(PredNext.Result.Yes));
    }

    function testRedeem() public {
        uint256 initialBalance = poolToken.balanceOf(user1);

        vm.prank(user1);
        predNext.swap("buy_yes", 100 * 10 ** 18);

        assertEq(yesToken.balanceOf(user1), 100 * 10 ** 18);
        assertEq(poolToken.balanceOf(user1), initialBalance - 100 * 10 ** 18);
        uint256 initialYESBalance = yesToken.balanceOf(user1);

        vm.prank(admin);
        predNext.setResult("yes");

        vm.prank(user1);
        yesToken.approve(address(predNext), initialYESBalance);

        vm.prank(user1);
        predNext.redeem(initialYESBalance);
        assertEq(poolToken.balanceOf(user1), initialBalance);
        assertEq(yesToken.balanceOf(user1), 0);
    }

    function testRedeemInsufficientBalance() public {
        vm.prank(user1);
        predNext.swap("buy_yes", 100 * 10 ** 18);

        vm.prank(admin);
        predNext.setResult("no");

        vm.prank(user1);
        vm.expectRevert("Insufficient balance");
        predNext.redeem(100 * 10 ** 18);
    }

    function testSwapInsufficientBalance() public {
        vm.prank(user1);
        vm.expectRevert("Insufficient balance");
        predNext.swap("buy_yes", 1001 * 10 ** 18);
    }

    function testSetResultByNonAdmin() public {
        vm.prank(user1);
        vm.expectRevert("Caller is not an admin");
        predNext.setResult("yes");
    }

    function testSetInvalidResult() public {
        vm.prank(admin);
        vm.expectRevert("Invalid outcome");
        predNext.setResult("maybe");
    }
}
