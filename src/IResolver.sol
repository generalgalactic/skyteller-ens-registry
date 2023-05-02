// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IResolver {
    function addr(bytes32 node) external view returns (address);
}
