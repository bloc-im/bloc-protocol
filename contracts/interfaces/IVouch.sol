pragma solidity 0.8.20;

// IVouch interface for getting trust members
import {Vouch} from "../vouch/VouchStructs.sol";

interface IVouch {
    function vouch(address recipient) external payable;
    function vouchWithSignature(
        Vouch memory vouchData,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external;
    function getTrustMembers(
        address member
    ) external view returns (address[] memory);
    function getTrustScore(
        address user,
        address vouched
    ) external view returns (uint256);
    function doesVouch(
        address sender,
        address recipient
    ) external view returns (bool);
    function generateVouchHash(
        address sender,
        address recipient
    ) external view returns (bytes32);
    function getVouchesReceivedAddresses(
        address user
    ) external view returns (address[] memory);

    function vouchReceivedCount(address user) external view returns (uint256);
    function vouchSentCount(address user) external view returns (uint256);
}