// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

interface ENS {
    function resolver(bytes32 node) external view returns (address);
    function owner(bytes32 node) external view returns (address);

    function setResolver(bytes32 node, address resolver) external;
}

// FIXME: This isn't working with impersonate. Use the cast-based script instead for now.

// Override replaces the ENS resolver in a forked environment, for testing.
// We use --unlocked --sender "0x4863A39d26F8b2e40d2AAbFf1eEe55E4B5015C4f"
contract Override is Script {
    function run() public {
        address resolverAddress = vm.envAddress("RESOLVER_ADDRESS");

        ENS ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

        // Original owner:
        // address owner = 0x4863A39d26F8b2e40d2AAbFf1eEe55E4B5015C4f;
        bytes32 skytellerNode = 0x32e875667cb1f7a08d7df7a538d8cbab9c4aeecd1856824909c6dae63dfc03f2;
        address currentOwner = ens.owner(skytellerNode);

        vm.startBroadcast(currentOwner);

        // Replace the resolver
        ens.setResolver(skytellerNode, resolverAddress);

        console.log("New resolver: %s", ens.resolver(skytellerNode));

        vm.stopBroadcast();

        // $ cast call --rpc-url "http://127.0.0.1:8545" 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e "resolver(bytes32) returns (address)" "0x32e875667cb1f7a08d7df7a538d8cbab9c4aeecd1856824909c6dae63dfc03f2"
    }
}
