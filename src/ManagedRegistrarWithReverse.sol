// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ManagedRegistrar} from "./ManagedRegistrar.sol";
import {INameResolver} from "./IResolver.sol";
import {Unauthorized} from "./Errors.sol";

contract ManagedRegistrarWithReverse is ManagedRegistrar, INameResolver {
    /// @notice Mapping of reverse nodes to names
    mapping(bytes32 => string) public reverseNodeToName;

    /*****************************/
    /*** adminSetter functions ***/

    function setName(bytes32 _reverseNode, string calldata _name) public {
        if (msg.sender != adminSetter && msg.sender != owner) {
            revert Unauthorized();
        }

        reverseNodeToName[_reverseNode] = _name;
        emit NameChanged(_reverseNode, _name);
    }

    /*********************************/
    /*** public external functions ***/

    function name(bytes32 node) public view returns (string memory) {
        return reverseNodeToName[node];
    }

    function supportsInterface(bytes4 interfaceID) public pure override(ManagedRegistrar) returns (bool) {
        return super.supportsInterface(interfaceID) || 
               interfaceID == 0x691f3431; // name(bytes32 node) returns (string memory);
    }

}
