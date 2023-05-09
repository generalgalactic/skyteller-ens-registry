#!/usr/bin/env bash
set -xe

export ETH_RPC_URL="http://127.0.0.1:8545"

NEW_RESOLVER="$1"
if [[ ! "$NEW_RESOLVER" ]]; then
    echo "Usage: $0 <resolver address>"
    exit 1
fi

ENS_CONTRACT="0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"

NAMEHASH=$(cast namehash "skyteller.eth")
OWNER=$(cast call "$ENS_CONTRACT" "owner(bytes32) returns (address)" "$NAMEHASH")
cast rpc anvil_impersonateAccount "$OWNER"

cast send --from "$OWNER" "$ENS_CONTRACT" "setResolver(bytes32, address)" "$NAMEHASH" "$NEW_RESOLVER"

# One way to add a subdomain using the global registrar (74,392 gas)
cast send --from "$OWNER" "$ENS_CONTRACT" "setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl)" \
    "$(cast namehash "skyteller.eth")" \
    "$(cast keccak "owner")" \
    "$OWNER" \
    "$NEW_RESOLVER" \
    "0"

#cast rpc anvil_mine 1  # Should not be necessary?

GOT_RESOLVER=$(cast call "$ENS_CONTRACT" "resolver(bytes32) returns (address)" "$NAMEHASH")
if [[ "$GOT_RESOLVER" != "$NEW_RESOLVER" ]]; then
    echo "impersonated setResolver failed"
    exit 1
fi

