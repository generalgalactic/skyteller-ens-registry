// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Owned} from "solmate/auth/Owned.sol";

import {IRegistrar} from "./IRegistrar.sol";
import {*} from "./Errors.sol";

// References:
// - https://github.com/ensdomains/subdomain-registrar/blob/1ffde8a296a071358fd2811e51a9df2ffcd72616/contracts/SubdomainRegistrar.sol

/// @notice ManagedRegistrar is a subdomain registrar that is fully managed by the owner.
/// @dev ManagedRegistrar is kept separate from ENSResolver to allow for
/// swapping resolvers without having to re-instantiate the registrar state
/// (which has all of the mappings)
contract ManagedRegistrar is IRegistrar, Owned {
    /// @notice Mapping of subdomain to address
    mapping(bytes32 => address) public subdomainToAddress;

    // TODO: addressToName for reverse resolver?

    constructor()
        Owned(msg.sender)
    {
        
    }

    /************************************/
    /*** onlyOwner external functions ***/

    /// @notice Set a subdomain -> addr mapping, can be used to remove by setting to 0.
    /// @param node Namehash of the subdomain, in EIP-137 format
    /// @param addr Ethereum address to map subdomain to
    function set(bytes32 calldata node, address addr) external onlyOwner {
        subdomainToAddress[node] = addr;

        emit AddrChanged(node, addr);
    }

    function multiset(bytes32[] calldata nodes, address[] calldata addrs) external onlyOwner {
        require(nodes.length == addrs.length, LengthMismatch());

        for (uint256 i = 0; i < nodes.length; i++) {
            // TODO: Could do some micro-optimizations for bulk adding?
            add(nodes[i], addrs[i]);
        }
    }

    /*********************************/
    /*** public external functions ***/

    function addr(bytes32 nodeID) external view returns (address) {
        return subdomainToAddress[nodeId];
    }
}
