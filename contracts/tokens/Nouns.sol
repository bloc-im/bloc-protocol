pragma solidity 0.8.20;

import "../apps/nix/ERC721PresetMinterPauserAutoId.sol";

contract Nouns is ERC721PresetMinterPauserAutoId {
    constructor() ERC721PresetMinterPauserAutoId("Nouns", "NOUN", "ipfs://QmZi1n79FqWt2tTLwCqiy6nLM6xLGRsEPQ5JmReJQKNNzX/") {
    }
}

