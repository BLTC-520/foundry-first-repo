//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe; // 之所以在这边定义是因为我们需要在多个测试用例中使用它 

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
    uint256 constant STARTING_BALANCE = 1000 ether; // 1000000000000000000
    
    function setUp() external {
        // 18,19的目的其实就是你直接在deploy的script上面做一次更改，这边不用再改
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // fundMe就是用着deployFundMe.run()返回的fundMe（地址）
        // 有点类似create an instance of the contract这样 （oop）
        vm.deal (USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
        }   

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // hey, the next line should revert! 
        fundMe.fund(); // send 0 value 
    }

    function testFundUpdatesFundedDataStructure () public {
        vm.prank(USER); // the next vm will be send be this USER 
        fundMe.fund{value:SEND_VALUE} ();
        // create a var to store the value of the address that funded   
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);

        assertEq(amountFunded, SEND_VALUE);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _; // 表明说他会先跑 之后再跑function主体
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); // hey, the next line should revert! 
        fundMe.withdraw(); // send 0 value 
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange 
        // 1. 先拿owner的balance， 2. 拿到fundMe的Balance
        uint256 ownerStartingBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // Act 
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + ownerStartingBalance, endingOwnerBalance);
        }
        
        function testWithdrawFromMultipleFunders() public funded {
            uint160 numbersOfFunders = 10;
            uint160 startingFunderIndex = 1;

            for(uint160 i = startingFunderIndex; i < numbersOfFunders;i++) {
                // 我们这个for loop要做的是给fundMe增加10个funders
                // 先vm.prank, vm.deal, fund the fundMe
                hoax(address(i), SEND_VALUE); // hoax = .prank + .deal
                fundMe.fund{value:SEND_VALUE}();
            }

            uint256 ownerStartingBalance = fundMe.getOwner().balance;
            uint256 startingFundMeBalance = address(fundMe).balance;
            

            vm.startPrank(fundMe.getOwner());
            fundMe.withdraw();
            vm.stopPrank();


            // Assert
            assertEq(address(fundMe).balance, 0); 
            assert(startingFundMeBalance + ownerStartingBalance == fundMe.getOwner().balance);
        }

        function testWithdrawFromMultipleFundersCheaper() public funded {
            uint160 numbersOfFunders = 10;
            uint160 startingFunderIndex = 1;

            for(uint160 i = startingFunderIndex; i < numbersOfFunders;i++) {
                // 我们这个for loop要做的是给fundMe增加10个funders
                // 先vm.prank, vm.deal, fund the fundMe
                hoax(address(i), SEND_VALUE); // hoax = .prank + .deal
                fundMe.fund{value:SEND_VALUE}();
            }

            uint256 ownerStartingBalance = fundMe.getOwner().balance;
            uint256 startingFundMeBalance = address(fundMe).balance;
            

            vm.startPrank(fundMe.getOwner());
            fundMe.cheaperWithdraw();
            vm.stopPrank();


            // Assert
            assertEq(address(fundMe).balance, 0); 
            assert(startingFundMeBalance + ownerStartingBalance == fundMe.getOwner().balance);
        }
}


// What can we do to work with addresses outside of our system?
// 1. Unit - testing a specific function of our code 
// 2. Integration - testing how our code work with other parts of our code
// 3. Forked - testing our code on a simulated blockchain
// 4. Staging - testing our code in a real env that is not production

