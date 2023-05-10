// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/ManagedENSResolver.sol";
import "../src/ManagedRegistrar.sol";
import "../src/IRegistrar.sol";

import "./Helpers.sol";

contract ManagedENSResolverTest is Test {
    ManagedENSResolver public resolver;
    ManagedRegistrar public registrar;

    function setUp() public {
        registrar = new ManagedRegistrar();
        resolver = new ManagedENSResolver(registrar, Helpers.namehash("skyteller", "eth"));
    }

    function testResolve() public {
        bytes32 name = Helpers.namehash("batman", "skyteller", "eth");
        address addr = address(0x42);

        registrar.set(name, addr);

        address got = resolver.addr(name);
        assertEq(got, addr);
    }
}
