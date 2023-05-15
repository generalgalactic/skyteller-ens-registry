// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Owned} from "solmate/auth/Owned.sol";

import {IRegistrar} from "./IRegistrar.sol";
import "./Errors.sol";

// References:
// - https://github.com/ensdomains/subdomain-registrar/blob/1ffde8a296a071358fd2811e51a9df2ffcd72616/contracts/SubdomainRegistrar.sol

/// @notice ManagedRegistrar is a subdomain registrar that is fully managed by the owner.
/// @dev ManagedRegistrar happens to be a valid basic ENS Resolver, but we still
/// use a separate IResolver contract in front of it so that we can add
/// functionality without having to reinitialize the accumulated state.
contract ManagedRegistrar is IRegistrar, Owned {
    /// @notice Mapping of subdomain to address
    mapping(bytes32 => address) public subdomainToAddress;

    /// @notice Address that is allowed to call set admin functions.
    /// @dev We keep these separate to allow other contracts to call in.
    address public adminSetter;

    constructor()
        Owned(msg.sender)
    {
        adminSetter = msg.sender;
    }

    /***************************/
    /*** onlyOwner functions ***/

    function setAdminSetter(address _adminSetter) external onlyOwner {
        adminSetter = _adminSetter;
    }

    /*****************************/
    /*** adminSetter functions ***/

    /// @notice Set a subdomain -> addr mapping, can be used to remove by setting to 0.
    /// @dev Careful reassigning existing names to new users, could be an attack vector.
    /// @param _node Namehash of the subdomain, in EIP-137 format
    /// @param _addr Ethereum address to map subdomain to
    function set(bytes32 _node, address _addr) public {
        if (msg.sender != adminSetter && msg.sender != owner) {
            revert Unauthorized();
        }

        subdomainToAddress[_node] = _addr;
        emit AddrChanged(_node, _addr);
    }

    function multiset(bytes32[] calldata _nodes, address[] calldata _addrs) public {
        if (msg.sender != adminSetter && msg.sender != owner) {
            revert Unauthorized();
        }

        if (_nodes.length != _addrs.length) {
            revert LengthMismatch();
        }

        for (uint256 i = 0; i < _nodes.length; i++) {
            subdomainToAddress[_nodes[i]] = _addrs[i];
            emit AddrChanged(_nodes[i], _addrs[i]);
        }
    }

    /*********************************/
    /*** public external functions ***/

    function addr(bytes32 _node) external view returns (address payable) {
        return payable(subdomainToAddress[_node]);
    }

    function supportsInterface(bytes4 interfaceID) public virtual pure returns (bool) {
        return interfaceID == 0x3b3b57de || // addr(bytes32 node) returns (address)
               interfaceID == 0x01ffc9a7;   // supportsInterface
    }

    // Per Resolver specification: https://eips.ethereum.org/EIPS/eip-137#resolver-specification
    // "Resolvers MUST specify a fallback function that throws."
    fallback() external {
        revert();
    }
}
