pragma solidity 0.8.20;

interface IPointTemplate {
    function initialize(address admin, address club, string memory name, string memory symbol)  external;
    function mintPoints(address to, uint256 amount) external;
    function totalSupply() external view returns (uint256);
}