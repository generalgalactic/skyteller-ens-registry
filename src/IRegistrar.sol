// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IRegistrar {
    event Register(
        string subdomain,
        bytes32 address,
    );

    event Archive(
        bytes32 subdomain,
    );

    event Delete(
        bytes32 subdomain,
    );
}
