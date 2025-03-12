// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address immutable USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant GAS_PRICE = 1; // in gwei 

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        // add starting balance to USER
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        console.log("Testing minimum dollar is five");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log("Testing owner is msg sender");
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        console.log("Testing price feed version is accurate");
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        console.log("Testing fund fails without enough ETH");

        vm.startPrank(USER);
        vm.expectRevert();
        fundMe.fund{value: 1}();
        vm.stopPrank();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance == SEND_VALUE);
        _;
    }

    function testFundUpdatesFundDataStructure() public funded {
        console.log("Testing fund updates fund data structure");
        
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
    }

    function testAddFunderToArrayOfFunders() public funded {
        address firstFunder = fundMe.getFunder(0);
        assertEq(firstFunder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // assert 
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded { 
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // hoax = prank + deal
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act 
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        // uint256 gasStart = gasleft();
        fundMe.cheaperWithdraw();
        // uint256 gasEnd = gasleft();

        // logging gas usage
        // console.log("Gas price  :", tx.gasprice);
        // console.log("Gas used   :", gasStart - gasEnd);
        // console.log("Tx price   :", tx.gasprice * (gasStart - gasEnd));

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance; 
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
        assertEq(
            (numberOfFunders + 1) * SEND_VALUE,
            endingOwnerBalance - startingOwnerBalance);
    }   

    function testWithdrawFromMultipleFunders() public funded {
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for(uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // hoax = prank + deal
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // act 
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        // uint256 gasStart = gasleft();
        fundMe.withdraw();
        // uint256 gasEnd = gasleft();

        // logging gas usage
        // console.log("Gas price  :", tx.gasprice);
        // console.log("Gas used   :", gasStart - gasEnd);
        // console.log("Tx price   :", tx.gasprice * (gasStart - gasEnd));

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance; 
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
        assertEq(
            (numberOfFunders + 1) * SEND_VALUE,
            endingOwnerBalance - startingOwnerBalance);
    }   

    function testFallbackFunction() public {
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        vm.prank(USER);
        (bool callSucceed, ) = payable(fundMe).call{value: SEND_VALUE}("");

        uint256 endingFundMeBalance = address(fundMe).balance;
        
        assertEq(callSucceed, true);
        assertEq(endingFundMeBalance, startingFundMeBalance + SEND_VALUE);
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
        assertEq(fundMe.getFunder(0), USER);
    }
    
    function testReceiveFunction() public {
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        vm.prank(USER);
        (bool callSucceed, ) = payable(fundMe).call{value: SEND_VALUE}("Calling receive function"); 

        uint256 endingFundMeBalance = address(fundMe).balance;
        
        assertEq(callSucceed, true);
        assertEq(endingFundMeBalance, startingFundMeBalance + SEND_VALUE);
        assertEq(fundMe.getAddressToAmountFunded(USER), SEND_VALUE);
        assertEq(fundMe.getFunder(0), USER);
    }
}
