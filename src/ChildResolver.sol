// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IRegistrar} from "./IRegistrar.sol";
import {IFullResolver} from "./IResolver.sol";

import {Resolver} from "./Resolver.sol";


/// @notice ChildResolver a Resolver wrapper that proxies additional interfaces
/// from a parent resolver, to inherit attributes that have already been set.
/// @dev Parent takes precedence.
abstract contract ChildResolver is Resolver, IFullResolver {
    IFullResolver public parentResolver;

    constructor(IFullResolver _parentResolver, IRegistrar _registrar)
        Resolver(_registrar)
    {
        parentResolver = _parentResolver;
    }

    // Borrowed from https://github.com/ensdomains/ens-contracts/blob/883a0a2d64d07df54f3ebbb0e81cf2e9d012c14d/contracts/resolvers/profiles/AddrResolver.sol#L82
    function addressToBytes(address a) internal pure returns (bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }

    /************************/
    /*** public functions ***/

    // Overrides

    function addr(bytes32 nodeID) public view override(Resolver, IFullResolver) returns (address payable) {
        address payable r = parentResolver.addr(nodeID);
        if (r != address(0)) {
            return r;
        }
        return registrar.addr(nodeID);
    }

    function addr(bytes32 nodeID, uint256 coinType) external view override(IFullResolver) returns (bytes memory) {
        if (coinType == 60) {
            return addressToBytes(addr(nodeID));
        }
        return parentResolver.addr(nodeID, coinType);
    }

    function supportsInterface(bytes4 interfaceID) public view override(IFullResolver, Resolver) returns (bool) {
        return parentResolver.supportsInterface(interfaceID) || super.supportsInterface(interfaceID);
    }

    // TODO: Override?
    // function resolve(bytes memory name, bytes memory data, bytes memory context) external view returns (bytes memory) { return parentResolver.resolve(name, data, context); }

    // IFullResolver Proxies
    // TODO: We may be able to do this in a more generic proxy router, but not sure how overrides would interract. Could research.

    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory) { return parentResolver.ABI(node, contentTypes); }
    function contenthash(bytes32 node) external view returns (bytes memory) { return parentResolver.contenthash(node); }
    function dnsRecord(bytes32 node, bytes32 _name, uint16 resource) external view returns (bytes memory) { return parentResolver.dnsRecord(node, _name, resource); }
    function zonehash(bytes32 node) external view returns (bytes memory) { return parentResolver.zonehash(node); }
    function interfaceImplementer(bytes32 node, bytes4 interfaceID) external view returns (address) { return parentResolver.interfaceImplementer(node, interfaceID); }
    function name(bytes32 node) external view returns (string memory) { return parentResolver.name(node); }
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y) { return parentResolver.pubkey(node); }
    function text(bytes32 node, string calldata key) external view returns (string memory) { return parentResolver.text(node, key); }
}
