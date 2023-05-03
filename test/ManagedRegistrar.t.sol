// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/ManagedRegistrar.sol";

contract ManagedRegistrarTest is Test {
    ManagedRegistrar public registrar;

    function setUp() public {
        registrar = new ManagedRegistrar();
    }

    function testOwner() public {
        assertEq(registrar.owner(), address(this));

        vm.prank(address(0x42));
        vm.expectRevert("UNAUTHORIZED");
        registrar.set(bytes32(abi.encodePacked("a")), address(0x42));
    }

    function testSet() public {
        address want = address(0x2000);
        bytes32 node = bytes32(abi.encodePacked("abcd"));
        registrar.set(node, want);
        assertEq(registrar.addr(node), want);

        // Invalid nodes return 0x0
        assertEq(registrar.addr(bytes32(abi.encodePacked("defg"))), address(0x0));
    }

    function testMultiset() public {
        // TODO: ...
    }
}
