// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // before vm. --> not a real tx - all are simulated in a local env
        HelperConfig helperConfig = new HelperConfig();
        (address priceFeed) = helperConfig.activeNetworkConfig();
        // after vm. --> real tx
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);  
        vm.stopBroadcast();
        return fundMe;
    }
}