// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe public fundMe;
    DeployFundMe deployFundMe;

    uint256 constant SEND_VALUE = 0.003 ether;
    uint256 constant STARTING_USER_BALANCE = 10 ether;

    address immutable USER = makeAddr("user");

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();    
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testUserCanFundAndOwnerCanWithdrawInteractions() public {
        // test user can fund
        uint256 startingFundMeBalance = address(fundMe).balance;

        FundFundMe fundFundMe = new FundFundMe(); 
        fundFundMe.fundFundMe(address(fundMe)); 
        
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, startingFundMeBalance + SEND_VALUE);

        // test owner can withdraw
        uint256 startingOwnerBalance = address(fundMe.getOwner()).balance;

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 endingOwnerBalance = address(fundMe.getOwner()).balance;
        uint256 afterWithdrawFundMeBalance = address(fundMe).balance;

        assertEq(endingOwnerBalance, startingOwnerBalance + endingFundMeBalance);
        assertEq(afterWithdrawFundMeBalance, 0);
    }
}
