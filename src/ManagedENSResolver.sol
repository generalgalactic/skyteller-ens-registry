// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Owned} from "solmate/auth/Owned.sol";
import {ExtendedResolver} from "ens-contracts/resolvers/profiles/ExtendedResolver.sol";

import {IRegistrar} from "./IRegistrar.sol";
import {IResolver} from "./IResolver.sol";

interface IENS {
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;
}


// References:
// - https://github.com/ensdomains/resolvers/blob/master/contracts/profiles/AddrResolver.sol
// - https://eips.ethereum.org/EIPS/eip-137#appendix-b-sample-resolver-implementations
// - https://github.com/ensdomains/subdomain-registrar/blob/1ffde8a296a071358fd2811e51a9df2ffcd72616/contracts/SubdomainRegistrar.sol

/// @notice ManagedENSResolver is a wrapper around a ManagedRegistrar which
/// maintains the stored state of subdomain node-to-address mappings.
/// @dev ManagedENSResolver can be replaced to add functionality without losing
/// mapping state that is stored in the ManagedRegistrar.
contract ManagedENSResolver is IResolver, Owned, ExtendedResolver {
    // FIXME: Do we want this resolver to support other functions for the parent node?

    /// @notice IRegistrar manages the assignment mappings.
    IRegistrar public registrar;

    /// @notice parentNode is the namehash of the node that this is the resolver for.
    /// @dev Used for doing setSubnodeRecord during set.
    bytes32 public parentNode;

    IENS constant internal ens = IENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    uint64 constant internal ttl = 0;

    constructor(IRegistrar _registrar)
        Owned(msg.sender)
    {
        registrar = _registrar;
    }

    /***********************/
    /*** admin functions ***/

    /// @notice Wrapper around registrar.set but also does setSubnodeRecord.
    function set(bytes32 _subnode, address _addr) public onlyOwner {
        bytes32 node = keccak256(abi.encodePacked(parentNode, _subnode));
        registrar.set(node, _addr);

        ens.setSubnodeRecord(parentNode, _subnode, address(this), address(this), ttl);
    }

    /************************/
    /*** public functions ***/

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == 0x3b3b57de || // addr(bytes32 node) returns (address)
               // TODO: interfaceID == 0x691f3431 || // name(bytes32 node) returns (string memory);
               interfaceID == 0x9061b923 || // resolve(bytes calldata name, bytes calldata data) returns(bytes);
               interfaceID == 0x0178b8bf || // resolver(bytes32 node) returns (address)
               interfaceID == 0x01ffc9a7;   // supportsInterface
    }

    function addr(bytes32 nodeID) external view returns (address) {
        return registrar.addr(nodeID);
    }

    function resolver(bytes32) external view returns (address) {
        // This resolver handles all subnodes.
        return address(this);
    }

    // Per Resolver specification: https://eips.ethereum.org/EIPS/eip-137#resolver-specification
    // "Resolvers MUST specify a fallback function that throws."
    fallback() external {
        revert();
    }
}
