// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Helpers {

    // Basic helper for generating a single-level namehash (does not recurse)
    function namehash(bytes memory _tld) internal pure returns (bytes32) {
        bytes32 base = bytes32(0x0);
        bytes32 node = keccak256(_tld);
        return keccak256(abi.encodePacked(base, node));
    }

    function namehash(bytes memory _domain, bytes memory _tld) internal pure returns (bytes32) {
        bytes32 base = namehash(_tld);
        bytes32 node = keccak256(_domain);
        return keccak256(abi.encodePacked(base, node));
    }

    function namehash(bytes memory _subdomain, bytes memory _domain, bytes memory _tld) internal pure returns (bytes32) {
        bytes32 base = namehash(_domain, _tld);
        bytes32 node = keccak256(_subdomain);
        return keccak256(abi.encodePacked(base, node));
    }
}


library ReverseHelpers {
    // Borrowed from https://github.com/ensdomains/ens-contracts/blob/883a0a2d64d07df54f3ebbb0e81cf2e9d012c14d/contracts/reverseRegistrar/ReverseRegistrar.sol
    // (MIT License)

    // namehash('addr.reverse')
    bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    bytes32 constant lookup = 0x3031323334353637383961626364656600000000000000000000000000000000;

    /**
     * @dev Returns the node hash for a given account's reverse records.
     * @param addr The address to hash
     * @return The ENS node hash.
     */
    function reverseNode(address addr) private pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr))
            );
    }

    /**
     * @dev An optimised function to compute the sha3 of the lower-case
     *      hexadecimal representation of an Ethereum address.
     * @param addr The address to hash
     * @return ret The SHA3 hash of the lower-case hexadecimal encoding of the
     *         input address.
     */
    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {
        assembly {
            for {
                let i := 40
            } gt(i, 0) {

            } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }
}
