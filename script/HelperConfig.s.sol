// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed; // ETH/USD feed address 
    }

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == 1) {
            // priceFeed ETH mainnet
            activeNetworkConfig = getMainnetEthConfig();
        } else if (block.chainid == 11155111) {
            // priceFeed ETH sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            // priceFeed ETH Anvil foundry 
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS, 
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        return NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
    }
}
