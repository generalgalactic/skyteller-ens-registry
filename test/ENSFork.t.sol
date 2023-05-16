// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ManagedENSResolver} from "../src/extended/ManagedENSResolver.sol";
import {ManagedRegistrarWithReverse} from "../src/extended/ManagedRegistrarWithReverse.sol";

import {Helpers} from "./Helpers.sol";

interface ENS {
    function resolver(bytes32 node) external view returns (address);
    function owner(bytes32 node) external view returns (address);

    function setResolver(bytes32 node, address resolver) external;
    function setOwner(bytes32 node, address owner) external;
}

// End-to-end forked ENS testing
contract ENSForkTest is Test {
    ManagedENSResolver public resolver;
    ManagedRegistrarWithReverse public registrar;

    function setUp() public {
        string memory rpcUrl = vm.envString("ETH_RPC_URL");
        vm.createSelectFork(rpcUrl);

        registrar = new ManagedRegistrarWithReverse();
        resolver = new ManagedENSResolver(
            registrar,
            registrar,
            Helpers.namehash("skyteller", "eth"));

        registrar.setAdminSetter(address(resolver));
    }

    // TODO: Could also mock ENS altogether using https://github.com/ethereum/EIPs/blob/master/EIPS/eip-137.md#appendix-a-registry-implementation

    function testEndToEnd() public {
        bytes32 skytellerNode = Helpers.namehash("skyteller", "eth");

        ENS ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
        address currentOwner = ens.owner(skytellerNode);

        // Impersonate currentOwner to change the resolver/owner
        vm.startBroadcast(currentOwner);

        // Replace the resolver
        ens.setResolver(skytellerNode, address(resolver));
        ens.setOwner(skytellerNode, address(resolver));

        vm.stopBroadcast();

        assertEq(ens.owner(skytellerNode), address(resolver));

        bytes32 name = Helpers.namehash("batman", "skyteller", "eth");
        bytes32 subdomain = keccak256("batman");
        address addr = address(0x42);

        // We set via the resolver, rather than the registrar.
        resolver.register(subdomain, addr);

        {
            address got = ens.resolver(name);
            assertEq(got, address(resolver));
        }
        {
            address got = resolver.addr(name);
            assertEq(got, addr);
        }
    }
}
