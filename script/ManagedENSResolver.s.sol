// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "../src/ManagedENSResolver.sol";
import "../src/ManagedRegistrar.sol";

contract ManagedENSResolverScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address ownerAddress = vm.envAddress("OWNER_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        ManagedRegistrar registrar = new ManagedRegistrar();
        ManagedENSResolver resolver = new ManagedENSResolver(registrar);

        if (ownerAddress != address(0)) {
            registrar.transferOwnership(ownerAddress);
        }

        vm.stopBroadcast();
    }
}
