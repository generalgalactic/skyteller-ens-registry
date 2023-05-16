// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ManagedRegistrarWithReverse} from "./ManagedRegistrarWithReverse.sol";
import {Unauthorized} from "../Errors.sol";

interface IPermit {
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external
    function nonces(address owner) external view returns (uint)
    function DOMAIN_SEPARATOR() external view returns (bytes32)
}

/// @notice Registrar that works with EIP-2612-style permits
/// https://eips.ethereum.org/EIPS/eip-2612
contract PermitRegistrarWithReverse is ManagedRegistrarWithReverse {
    /// @dev keccak256("PermitRegistrarWithReverse") of version used for verifying permit signature.
    bytes32 private constant nameHash = 0x7f02f7f18bbf0266296c6dbd6c9de3c0aeb5ca7f38822c459c5e7ea81764e77f;

    /// @dev keccak256("1") of version used for verifying permit signature.
    bytes32 private constant versionHash = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;

    /// @dev keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)",
    bytes32 private constant typeHash = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    /// @dev keccak256("Register(address addr,bytes32 node,uint256 deadline)");
    bytes32 public constant override PERMIT_TYPEHASH = 0xe074d326c0cc873b1c97ead47b9bd18bbb7c9cd414c75875acf5f1f092996750;

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return keccak256(
            abi.encode(
                typeHash,
                nameHash,
                versionHash,
                block.chainid,
                address(this)
        ));
    }

}
