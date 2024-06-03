//SPDX-License-Identifier: MIT

// 目标 ： 我们不需要在每个测试中都hardcode一个价格feed的地址 

// 做法 : creating a mock contract that will return a fixed price
// 1. Deploy a mock when we are on a local anvil chain 
// 2. Keep track contract addresses as we are on different chains 

// SEPOLIA ETH/USD 
// Mainnet ETH/USD 

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // if we are on a local anvil chain, we deploy mocks 
    // otherwise grab the real address from the other network 

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public activeNetworkConfig;
    // create types? (Struct keyword)
    struct NetworkConfig {
        address priceFeed;
    }

    constructor () {
        if(block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();}
        else if(block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();}
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();}
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
    //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig(
        {priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306}
        ); 
        return sepoliaConfig;
    }
    
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // if we have already deployed a mock, return it, we don't want to deploy twice
        if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // Deploy the mock 
        // Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        // create the instance which is 
        // mockPriceFeed stores the address of the deployed MockV3Aggregator contract 
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig( {
            priceFeed : address(mockPriceFeed)
            });
        // The anvilConfig variable is created, 
        // storing the address of the mockPriceFeed contract in the priceFeed field of the NetworkConfig struct.
        return anvilConfig;
        }
    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig(
        {priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419}
        );
        return mainnetConfig;
    }
}

// Note : Try to get good pratice on naming the function names and write readble code 