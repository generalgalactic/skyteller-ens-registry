// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Owned} from "solmate/auth/Owned.sol";

import {IRegistrar} from "./IRegistrar.sol";

// References:
// - https://github.com/ensdomains/subdomain-registrar/blob/1ffde8a296a071358fd2811e51a9df2ffcd72616/contracts/SubdomainRegistrar.sol

/// @notice ManagedRegistrar is a subdomain registrar that is fully managed by the owner.
/// @dev ManagedRegistrar is kept separate from ENSResolver to allow for
/// swapping resolvers without having to re-instantiate the registrar state
/// (which has all of the mappings)
contract ManagedRegistrar is IRegistrar, Owned {
    /// @notice Mapping of subdomain to address
    mapping(string => address) public subdomainToAddress;

    // TODO: Could change archived mapping to be a timestamp for expiration?

    /// @notice Archived domains are locked and hidden.
    mapping(string => bool) public isArchived;

    // TODO: addressToName for reverse resolver?

    constructor()
        Owned(msg.sender)
    {
        
    }

    /************************************/
    /*** onlyOwner external functions ***/

    function add(string calldata subdomain, address addr) external onlyOwner {
        require(!isArchived[subdomain], "ManagedRegistrar: subdomain is archived");
        subdomainToAddress[subdomain] = addr;

        emit Register(subdomain, addr);
    }

    // TODO: addBulk

    // TODO: archive - Lock and hide name from listing
    function archive(string calldata subdomain) external onlyOwner {
        isArchived[subdomain] = true;

        emit Archive(subdomain);
    }

    // TODO: delete
    /// @notice Deletes a subdomain (even if it's archived), should generally use archive instead (to avoid hijacking)
    function delete(string calldata subdomain) external onlyOwner {
        delete subdomainToAddress[subdomain];
        delete isArchived[subdomain];

        emit Delete(subdomain);
    }

    /*********************************/
    /*** public external functions ***/
}
