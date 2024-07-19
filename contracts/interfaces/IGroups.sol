pragma solidity 0.8.20;

interface IGroups {

    function createGroup(address _community, string memory _name, string memory _description, address _admin) external;
    function joinGroup(address _community, string memory _name) external;

}
