// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/ManagedENSResolver.sol";
import "../src/ManagedRegistrar.sol";

import "../test/Helpers.sol";

contract Deploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("ETH_PRIVATE_KEY");
        address ownerAddress = vm.envAddress("ETH_OWNER_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        ManagedRegistrar registrar = new ManagedRegistrar();
        new ManagedENSResolver(registrar, Helpers.namehash("skyteller", "eth"));

        bytes32 ownerNode = Helpers.namehash("owner", "skyteller", "eth");
        registrar.set(ownerNode, ownerAddress);

        if (ownerAddress != address(0)) {
            console.log("Changing registrar owner: %s -> %s", registrar.owner(), ownerAddress);
            registrar.transferOwnership(ownerAddress);
        }

        vm.stopBroadcast();
    }
}
