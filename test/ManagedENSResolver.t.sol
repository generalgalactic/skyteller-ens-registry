// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ManagedENSResolver.sol";
import "../src/ManagedRegistrar.sol";

contract ManagedENSResolverTest is Test {
    ManagedENSResolver public resolver;

    function setUp() public {
        resolver = new ManagedENSResolver();
    }

    function testResolve() public {
        // TODO: ...
    }
}
