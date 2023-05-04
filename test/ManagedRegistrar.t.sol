// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/ManagedRegistrar.sol";
import "../src/Errors.sol";

contract ManagedRegistrarTest is Test {
    ManagedRegistrar public registrar;

    function setUp() public {
        registrar = new ManagedRegistrar();
    }

    function test_Owner() public {
        assertEq(registrar.owner(), address(this));

        vm.prank(address(0x42));
        vm.expectRevert("UNAUTHORIZED");
        registrar.set(bytes32(abi.encodePacked("a")), address(0x42));
    }

    function test_Set() public {
        address want = address(0x2000);
        bytes32 node = bytes32(abi.encodePacked("abcd"));
        registrar.set(node, want);
        assertEq(registrar.addr(node), want);

        // Invalid nodes return 0x0
        assertEq(registrar.addr(bytes32(abi.encodePacked("defg"))), address(0x0));
    }

    function test_Multiset() public {
        // Bulk set a bunch of nodes
        bytes32[] memory nodes = new bytes32[](5);
        nodes[0] = bytes32(abi.encode(1));
        nodes[1] = bytes32(abi.encode(2));
        nodes[2] = bytes32(abi.encode(3));
        nodes[3] = bytes32(abi.encode(4));
        nodes[4] = bytes32(abi.encode(5));

        address[] memory addrs = new address[](5);
        addrs[0] = address(0x1);
        addrs[1] = address(0x2);
        addrs[2] = address(0x3);
        addrs[3] = address(0x4);
        addrs[4] = address(0x5);

        assertEq(registrar.addr(nodes[3]), address(0));

        registrar.multiset(nodes, addrs);

        assertEq(registrar.addr(nodes[3]), addrs[3]);
        assertNotEq(registrar.addr(nodes[2]), registrar.addr(nodes[3]));
    }

    function test_RevertIf_LengthMismatch() public {
        bytes32[] memory nodes = new bytes32[](2);
        nodes[0] = bytes32(abi.encode(1));
        nodes[1] = bytes32(abi.encode(2));

        address[] memory addrs = new address[](3);
        addrs[0] = address(0x1);
        addrs[1] = address(0x2);
        addrs[2] = address(0x3);

        vm.expectRevert(LengthMismatch.selector);
        registrar.multiset(nodes, addrs);
    }
}
