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
    "$(cast keccak "foo")" \
    "$OWNER" \
    "$NEW_RESOLVER" \
    "0"

# Other way: (49525 + 48315 gas + 48114 gas registrar call)
cast send --from "$OWNER" "$ENS_CONTRACT" "setSubnodeOwner(bytes32 node, bytes32 label, address owner)" \
    "$(cast namehash "skyteller.eth")" \
    "$(cast keccak "bar")" \
    "$OWNER" \
cast send --from "$OWNER" "$ENS_CONTRACT" "setResolver(bytes32, address)" \
    "$(cast namehash "bar.skyteller.eth")" \
    "$NEW_RESOLVER"

REGISTRAR_CONTRACT="0x1c39BA375faB6a9f6E0c01B9F49d488e101C2011"
cast send --from "$OWNER" "$REGISTRAR_CONTRACT" "set(bytes32, address)" \
    "$(cast namehash "bar.skyteller.eth")" \
    "$OWNER"

#cast rpc anvil_mine 1  # Should not be necessary?

GOT_RESOLVER=$(cast call "$ENS_CONTRACT" "resolver(bytes32) returns (address)" "$NAMEHASH")
if [[ "$GOT_RESOLVER" != "$NEW_RESOLVER" ]]; then
    echo "impersonated setResolver failed"
    exit 1
fi

