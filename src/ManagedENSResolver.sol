// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Owned} from "solmate/auth/Owned.sol";

import {IRegistrar} from "./IRegistrar.sol";
import {IResolver} from "./IResolver.sol";

// References:
// - https://github.com/ensdomains/resolvers/blob/master/contracts/profiles/AddrResolver.sol
// - https://eips.ethereum.org/EIPS/eip-137#appendix-b-sample-resolver-implementations

contract ManagedENSResolver is IResolver, Owned {
    // FIXME: Do we want this resolver to support other functions for the parent node?

    /// @notice IRegistrar manages the assignment mappings.
    IRegistrar private registrar;

    constructor(IRegistrar _registrar)
        Owned(msg.sender)
    {
        registrar = _registrar;
    }

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == 0x3b3b57de || // addr(bytes32 node) returns (address)
               // TODO: interfaceID == 0x691f3431 || // name(bytes32 node) returns (string memory);
               // TODO: interfaceID == 0x9061b923 || // resolve(bytes calldata name, bytes calldata data) returns(bytes);
               interfaceID == 0x01ffc9a7;   // supportsInterface
    }

    function addr(bytes32 nodeID) external view returns (address) {
        return registrar.addr(nodeID);
    }

    // Per Resolver specification: https://eips.ethereum.org/EIPS/eip-137#resolver-specification
    // "Resolvers MUST specify a fallback function that throws."
    fallback() external {
        revert();
    }
}
