// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        (address priceFeed) = helperConfig.activeNetworkConfig();

        // console.log("Deploying contract...");
        // console.log("Chain ID   :", block.chainid);
        // console.log("Price Feed :", priceFeed);

        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();

        return fundMe;
    }
}
