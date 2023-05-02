// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ManagedENSResolver.sol";
import "../src/ManagedRegistrar.sol";

contract ManagedENSResolverTest is Test {
    ManagedENSResolver public resolver;
    ManagedRegistrar public registrar;

    function setUp() public {
        registrar = new ManagedRegistrar();
        resolver = new ManagedENSResolver(registrar);
    }

    function testResolve() public {
        // TODO: ...
    }
}
