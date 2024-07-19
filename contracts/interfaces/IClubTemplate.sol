pragma solidity 0.8.20;

interface IClubTemplate {
    function isMember(address _member) external view returns (bool);
}