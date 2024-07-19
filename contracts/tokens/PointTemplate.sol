pragma solidity 0.8.20;

import {ERC20Upgradeable} from "@openzeppelin-contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {IClubTemplate} from "../interfaces/IClubTemplate.sol";

contract PointTemplate is ERC20Upgradeable {
    bytes32 public constant templateId = keccak256("PointTemplate");
    address public clubAddress;

    event PointsTransfer(
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes32 cid
    );

    function initialize(
        address admin,
        address club,
        string memory name,
        string memory symbol
    ) external initializer {
        __ERC20_init(name, symbol);
        clubAddress = club;
        _mint(admin, 1000000000e18); // 1 billion
    }

    function transferPoints(address to, uint256 amount, bytes32 cid) public {
        transfer(to, amount);
        emit PointsTransfer(msg.sender, to, amount, cid);
    }

    function mintPoints(address to, uint256 amount) public {
        require(msg.sender == clubAddress, "Only the club can mint points");
        _mint(to, amount);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (from != address(0)) {
            require(
                IClubTemplate(clubAddress).isMember(to),
                "Recipient is not a club member"
            );
        }
        super._update(from, to, value);
    }
}
