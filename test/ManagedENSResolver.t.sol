// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/ManagedENSResolver.sol";
import "../src/ManagedRegistrar.sol";
import "../src/IRegistrar.sol";

library Helpers {

    // Basic helper for generating a single-level namehash (does not recurse)
    function namehash(bytes memory _tld) internal pure returns (bytes32) {
        bytes32 base = bytes32(0x0);
        bytes32 node = keccak256(_tld);
        return keccak256(abi.encodePacked(base, node));
    }

    function namehash(bytes memory _domain, bytes memory _tld) internal pure returns (bytes32) {
        bytes32 base = namehash(_tld);
        bytes32 node = keccak256(_domain);
        return keccak256(abi.encodePacked(base, node));
    }
}

contract ManagedENSResolverTest is Test {
    ManagedENSResolver public resolver;
    ManagedRegistrar public registrar;

    function setUp() public {
        registrar = new ManagedRegistrar();
        resolver = new ManagedENSResolver(registrar);
    }

    function test_Namehash() public {
        // Just making sure it works correctly
        bytes32 got = Helpers.namehash("eth");
        bytes32 want = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;

        assertEq(got, want);
    }

    function testResolve() public {
        bytes32 name = Helpers.namehash("hello", "eth");
        address addr = address(0x42);

        registrar.set(name, addr);

        address got = resolver.addr(name);
        assertEq(got, addr);
    }
}
