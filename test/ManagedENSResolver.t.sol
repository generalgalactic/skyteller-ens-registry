// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {BytesUtils} from "ens-contracts/wrapper/BytesUtils.sol";

import "../src/ManagedENSResolver.sol";
import "../src/ManagedRegistrar.sol";

contract ManagedENSResolverTest is Test {
    using BytesUtils for *;

    ManagedENSResolver public resolver;
    ManagedRegistrar public registrar;

    function setUp() public {
        registrar = new ManagedRegistrar();
        resolver = new ManagedENSResolver(registrar);
    }

    // XXX: BytesUtils isn't working

    function testNamehash() public {
        // Just making sure it works correctly
        bytes memory name = "eth";
        bytes32 got = name.namehash(0);
        bytes32 want = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;

        assertEq(got, want);
    }

    function testResolve() public {
        bytes memory name = "hello";
        bytes32 node = name.namehash(0);
        address addr = address(0x42);

        registrar.set(node, addr);

        address got = resolver.addr(node);
        assertEq(got, addr);
    }
}
