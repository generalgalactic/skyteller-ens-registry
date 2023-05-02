// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IRegistrar {
    event Register(
        string subdomain,
        address address,
    );

    event Archive(
        string subdomain,
    );

    event Delete(
        string subdomain,
    );
}
