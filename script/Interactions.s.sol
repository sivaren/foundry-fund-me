// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.003 ether;

    function fundFundMe(address mostRecentlyDeployedFundMe) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedFundMe)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployedFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        fundFundMe(mostRecentlyDeployedFundMe);
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployedFundMe) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployedFundMe)).withdraw();
        vm.stopBroadcast(); 
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployedFundMe = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        withdrawFundMe(mostRecentlyDeployedFundMe);
    }
}
