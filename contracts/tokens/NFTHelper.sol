pragma solidity 0.8.20;

import "../openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import "../openzeppelin/token/ERC721/extensions/IERC721Metadata.sol";

contract NFTHelper  {

    struct TokenData {
        address collection;
        uint256 tokenId;
        string tokenURI;
        string name;
        string symbol;
    }

    address boredApeAddress;
    address nounsAddress;

    constructor(address boredApe, address nouns) {
        boredApeAddress = boredApe;
        nounsAddress = nouns;
    }

    function getOwnedTokens(address user) public view returns(TokenData[] memory) {
        uint256 boredApeBalance = IERC721Enumerable(boredApeAddress).balanceOf(user);
        // uint256 nounceBalance = IERC721Enumerable(nounsAddress).balanceOf(user);
       
        TokenData[] memory ownedTokens = new TokenData[](boredApeBalance);
       
        for (uint256 i = 0; i < boredApeBalance; i++) {
            uint256 tokenId = IERC721Enumerable(boredApeAddress).tokenOfOwnerByIndex(user, i);
            ownedTokens[i].collection = boredApeAddress;
            ownedTokens[i].tokenId = tokenId;
            ownedTokens[i].tokenURI = IERC721Metadata(boredApeAddress).tokenURI(tokenId);
            ownedTokens[i].name = IERC721Metadata(boredApeAddress).name();
            ownedTokens[i].symbol = IERC721Metadata(boredApeAddress).symbol();
        }

        // for (uint256 i = 0; i < nounceBalance; i++) {
        //     uint256 tokenId = IERC721Enumerable(nounsAddress).tokenOfOwnerByIndex(user, i);
        //     ownedTokens[boredApeBalance+i].collection = nounsAddress;
        //     ownedTokens[boredApeBalance+i].tokenId = tokenId;
        //     ownedTokens[boredApeBalance+i].tokenURI = IERC721Metadata(nounsAddress).tokenURI(tokenId);
        //     ownedTokens[boredApeBalance+i].name = IERC721Metadata(nounsAddress).name();
        //     ownedTokens[boredApeBalance+i].symbol = IERC721Metadata(nounsAddress).symbol();
        // }
        return ownedTokens;
    }
}

