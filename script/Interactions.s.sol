// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";
contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;
    function fundFundMe (address mostRecent) public {
        vm.startBroadcast();
        FundMe(payable(mostRecent)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }
    
    
    function run() external {
        // so我们要fund的是最新deploy的contract 
        // 会需要用到一个包 foundry-devops
        address mostRecent = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecent);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe (address mostRecent) public {
        vm.startBroadcast();
        FundMe(payable(mostRecent)).withdraw();
        vm.stopBroadcast();
    }
    
    
    function run() external {
        // so我们要fund的是最新deploy的contract 
        // 会需要用到一个包 foundry-devops
        address mostRecent = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostRecent);
        vm.stopBroadcast();
    }}