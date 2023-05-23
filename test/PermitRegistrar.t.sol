// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {PermitRegistrarWithReverse } from "../src/extended/PermitRegistrarWithReverse.sol";
import {Unauthorized, InvalidSignature, PermitExpired} from "../src/Errors.sol";

import {Helpers} from "./Helpers.sol";

contract PermitRegistrarTest is Test {
    PermitRegistrarWithReverse public registrar;

    uint256 internal signerKey = 12345;
    address internal signer;

    function setUp() public {
        signer = vm.addr(signerKey);

        registrar = new PermitRegistrarWithReverse(
            Helpers.namehash("skyteller", "eth") // parentNode
        );
        registrar.setAdminSigner(signer);
    }

    function test_registerWithPermit() public {
        bytes32 node = Helpers.namehash("foo", "skyteller", "eth");

        string memory name = "foo";
        address caller = address(0x42);
        uint256 deadline = block.timestamp + 1;

        bytes32 digest = registrar.digestRegister(name, caller, deadline);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, digest);

        assertEq(registrar.addr(node), address(0));
        assertEq(registrar.name(node), "");

        vm.prank(caller);
        registrar.permitRegister(name, caller, deadline, v, r, s);

        assertEq(registrar.addr(node), caller);
        assertEq(registrar.name(node), name);
    }
}
