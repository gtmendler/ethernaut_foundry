// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/18-MagicNum/MagicNumFactory.sol";
import "../src/Ethernaut.sol";

contract MagicNumTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testMagicNumHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        MagicNumFactory factory = new MagicNumFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        MagicNum level = MagicNum(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        bytes memory code = hex'600a_600c_6000_39_600a_6000_f3_602a_6080_52_6020_6080_f3';
        Creator creator = new Creator();
        address solver = creator.deploy(code);
        level.setSolver(solver);

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

contract Creator {
    function deploy(bytes memory bytecode) public returns (address) {
        address child;
        assembly {
            mstore(0x0, bytecode)
            child := create(0,0xa0,calldatasize())
        }
        return child;
    }
}