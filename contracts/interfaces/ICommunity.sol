pragma solidity 0.8.20;

interface ICommunity {
    function getApprovedMembers() external view returns (address[] memory);
    function getAdmins() external view returns (address[] memory);
    function getCommunity() external view returns (string memory, string memory, string memory, uint, bool);

}
