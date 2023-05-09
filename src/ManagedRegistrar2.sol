// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Owned} from "solmate/auth/Owned.sol";

import {IRegistrar} from "./IRegistrar.sol";
import "./Errors.sol";

interface IENS {
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;
}

// References:
// - https://github.com/ensdomains/subdomain-registrar/blob/1ffde8a296a071358fd2811e51a9df2ffcd72616/contracts/SubdomainRegistrar.sol

/// @notice ManagedRegistrar is a subdomain registrar that is fully managed by the owner.
/// @dev ManagedRegistrar happens to be a valid ENS Resolver, but we still
/// use a separate IResolver contract in front of it so that we can add
/// functionality without having to reinitialize the accumulated state.
contract ManagedRegistrar2 is IRegistrar, Owned {
    /// @notice Mapping of subdomain to address
    mapping(bytes32 => address) public subdomainToAddress;

    bytes32 public parentNode;

    IENS constant internal ens = IENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);

    // TODO: addressToName for reverse resolver?

    constructor(bytes32 _parentNode)
        Owned(msg.sender)
    {
        parentNode = _parentNode;
    }

    /************************************/
    /*** onlyOwner external functions ***/

    /// @notice Set a subdomain -> addr mapping, can be used to remove by setting to 0.
    /// @dev Careful reassigning existing names to new users, could be an attack vector.
    /// @param _label keccak256 hash of the subdomain label, in EIP-137 format
    /// @param _addr Ethereum address to map subdomain to
    function set(bytes32 _subnode, address _addr) public onlyOwner {
        bytes32 node = sha3(parentNode, subnode);
        subdomainToAddress[_node] = _addr;
        ens.setSubnodeRecord(parentNode, _subnode, address(this), resolver, uint64 ttl)

        emit AddrChanged(_node, _addr);
    }

    function multiset(bytes32[] calldata _subnode, address[] calldata _addrs) public onlyOwner {
        if (_nodes.length != _addrs.length) {
            revert LengthMismatch();
        }

        for (uint256 i = 0; i < _nodes.length; i++) {
            // TODO: Could do some micro-optimizations for bulk adding?
            set(_nodes[i], _addrs[i]);
        }
    }

    /*********************************/
    /*** public external functions ***/

    function addr(bytes32 _node) external view returns (address) {
        return subdomainToAddress[_node];
    }

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == 0x3b3b57de || // addr(bytes32 node) returns (address)
               interfaceID == 0x01ffc9a7;   // supportsInterface
    }

    // Per Resolver specification: https://eips.ethereum.org/EIPS/eip-137#resolver-specification
    // "Resolvers MUST specify a fallback function that throws."
    fallback() external {
        revert();
    }
}
