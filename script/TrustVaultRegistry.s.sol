// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {TrustVaultRegistry} from "../src/TrustVaultRegistry.sol";

contract DeploySepolia is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        console2.log("Deploying TrustVaultRegistry to Sepolia...");
        TrustVaultRegistry registry = new TrustVaultRegistry();

        console2.log("Registry deployed at:", address(registry));
        console2.log("Etherscan: https://sepolia.etherscan.io/address/", address(registry));
        console2.log("ABI ready for frontend integration");

        vm.stopBroadcast();
    }
}