pragma solidity 0.8.20;

interface IBlocDocuments {
    function setDocument(
        address _contractAddr,
        string calldata _name,
        string calldata _data
    ) external;

    function setDocuments(
        address _contractAddr,
        string[] calldata _name,
        string[] calldata _data
    ) external;

    function removeDocument(address _contractAddr, string calldata _name)
        external;
    function getDocument(address _contractAddr, string calldata _name) external view returns (string memory, uint256);
}
