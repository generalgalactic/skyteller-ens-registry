// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/ManagedENSResolver.sol";
import "../src/ManagedRegistrarWithReverse.sol";

import "../src/IResolver.sol";

import "../test/Helpers.sol";

contract Deploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("ETH_PRIVATE_KEY");
        address ownerAddress = vm.envAddress("ETH_OWNER_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        ManagedRegistrarWithReverse registrar = new ManagedRegistrarWithReverse();
        new ManagedENSResolver(
            registrar, // IRegistrar
            registrar, // INameResolver
            Helpers.namehash("skyteller", "eth") // parentNode
        );

        bytes32 ownerNode = Helpers.namehash("owner", "skyteller", "eth");
        registrar.set(ownerNode, ownerAddress);

        if (ownerAddress != address(0)) {
            console.log("Changing registrar owner: %s -> %s", registrar.owner(), ownerAddress);
            registrar.transferOwnership(ownerAddress);
        }

        vm.stopBroadcast();
    }
}
