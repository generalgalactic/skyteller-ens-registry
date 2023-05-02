// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// References:
// - https://github.com/ensdomains/resolvers/blob/master/contracts/profiles/AddrResolver.sol

contract ManagedENSResolver {
    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == 0x3b3b57de || // addr(bytes32 node) returns (address)
               interfaceID == 0x691f3431 || // name(bytes32 node) returns (string memory);
               interfaceID == 0x01ffc9a7; // supportsInterface
    }

    function addr(bytes32 nodeID) external view returns (address) {
        // XXX: Unhardcode this
        return address(this);
    }

    function name(bytes32 node) external view returns (string memory) {
    }
}
