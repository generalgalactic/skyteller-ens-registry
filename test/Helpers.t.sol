// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "./Helpers.sol";

contract HelpersTest is Test {
    function test_Namehash() public {
        // Just making sure it works correctly
        {
            // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-137.md#namehash-algorithm
            bytes32 got = Helpers.namehash("eth");
            bytes32 want = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;
            assertEq(got, want);
        }

        {
            bytes32 got = Helpers.namehash("skyteller", "eth");
            bytes32 want = 0x32e875667cb1f7a08d7df7a538d8cbab9c4aeecd1856824909c6dae63dfc03f2;
            assertEq(got, want);
            // Can confirm in terminal:
            // $ cast namehash skyteller.eth
            // 0x32e875667cb1f7a08d7df7a538d8cbab9c4aeecd1856824909c6dae63dfc03f2
            // $ cast call --flashbots 0x4976fb03C32e5B8cfe2b6cCB31c09Ba78EBaBa41 "addr(bytes32) returns (address)" "0x32e875667cb1f7a08d7df7a538d8cbab9c4aeecd1856824909c6dae63dfc03f2"
            // 0x7c543D205ef669eF43f5Ae095B4d70125b90893b
        }

        {
            // $ cast namehash batman.skyteller.eth
            bytes32 got = Helpers.namehash("batman", "skyteller", "eth");
            bytes32 want = 0x4930afdb2361eb3ba4e29c1a2e843807e48eaa57987ec4df35ff8d9f1949aa60;
            assertEq(got, want);
        }
    }
}
