pragma solidity 0.8.20;
import "../apps/nix/ERC721PresetMinterPauserAutoId.sol";

contract BoredApes is ERC721PresetMinterPauserAutoId {
    constructor() ERC721PresetMinterPauserAutoId("BoredApeYachtClub", "BAYC", "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/") {
    }
}
