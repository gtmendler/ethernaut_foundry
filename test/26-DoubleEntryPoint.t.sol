// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

//import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";

import "../src/26-DoubleEntryPoint/DoubleEntryPointFactory.sol";
import "../src/Ethernaut.sol";

contract DoubleEntryPointTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testDoubleEntryPointHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        DoubleEntryPointFactory factory = new DoubleEntryPointFactory();
        ethernaut.registerLevel(factory);
        vm.startPrank(eoaAddress, eoaAddress);
        address levelAddress = ethernaut.createLevelInstance{value: 1 ether}(factory);
        DoubleEntryPoint level = DoubleEntryPoint(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        Bot bot = new Bot(level.cryptoVault());
        Forta(level.forta()).setDetectionBot(address(bot));

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

contract Bot is IDetectionBot {
    address vault;

    constructor (address source) {
        vault = source;
    }

    function handleTransaction(address user, bytes calldata msgData) external {
        (,,address from) = abi.decode(msgData[4:], (address, uint, address));

        bytes memory callSig = abi.encodePacked(msgData[0], msgData[1], msgData[2], msgData[3]);
        bytes memory monitorSig = abi.encodeWithSignature("delegateTransfer(address,uint256,address)");
        if (from == vault && keccak256(callSig) == keccak256(monitorSig)) {
            Forta(msg.sender).raiseAlert(user);
        }
    }
}