
pragma solidity 0.8.20;

interface IERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint tokenId, bytes memory data) external returns(bytes4);
}
