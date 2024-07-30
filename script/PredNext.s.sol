// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {PredNext} from "../src/PredNext.sol";
import {PToken} from "../src/PToken.sol";
import {PoolToken} from "../src/PoolToken.sol";

contract DeployPredictionAMMScript is Script {
    PredNext public predNext;
    PToken public yesToken;
    PToken public noToken;
    PoolToken public poolToken;

    address initialOwner;

    function setUp() public {
        // Set the initial owner to the address that deploys this script
        initialOwner = msg.sender;
    }

    function run() public {
        vm.startBroadcast();

        // Deploy the PredNext contract with the initial owner
        predNext = new PredNext(100, initialOwner); // Min increment is 100 tokens

        // Get the deployed tokens from the PredNext contract
        yesToken = predNext.yesToken();
        noToken = predNext.noToken();
        poolToken = predNext.poolToken();

        // Log the addresses of the deployed contracts
        console.log("PredNext deployed at:", address(predNext));
        console.log("Yes Token deployed at:", address(yesToken));
        console.log("No Token deployed at:", address(noToken));
        console.log("Pool Token deployed at:", address(poolToken));

        vm.stopBroadcast();
    }
}
