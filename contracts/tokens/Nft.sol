pragma solidity 0.8.20;

import "./ERC721S.sol";
import "../access/AdminControl.sol";
import "../openzeppelin/utils/Strings.sol";

contract Nft is ERC721S, AdminControl {
    using Strings for uint256;

    bytes32 public immutable templateId = keccak256("Nft");
    string private _baseTokenURI;
    uint256 private _tokenIdTracker;

    constructor() {}

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_ownerOf[tokenId] != address(0), "ERC721Metadata: URI query for nonexistent token");
        return bytes(_baseTokenURI).length > 0 ? string(abi.encodePacked(_baseTokenURI, tokenId.toString())) : "";
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721S, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(address to) public virtual {
        require(hasAdminRole(msg.sender), "ERC721S: must have admin role to mint");
        _mint(to, _tokenIdTracker);
        _tokenIdTracker++ ;
    }

    // burn if revokable and admin
    // set mint cap / uncapped
    // set mint price / price curve


    ///--------------------------------------------------------
    /// Factory
    ///--------------------------------------------------------

    function initTemplate(bytes calldata _data) external  payable {
        (
        string memory _name, 
        string memory _symbol, 
        string memory _tokenURI,
        address _admin

        ) = abi.decode(_data, (string, string, string, address));
        initToken(
            _name, 
            _symbol
        );
        _baseTokenURI = _tokenURI;
        initAccessControls(_admin);

    }

    function getInitData(
        string memory _name, 
        string memory _symbol, 
        string memory _tokenURI,
        address _admin
    )
        external
        pure
        returns (bytes memory _data)
    {
        return abi.encode(
                            _name, 
                            _symbol,
                            _tokenURI, 
                            _admin
                        );
    }

}

