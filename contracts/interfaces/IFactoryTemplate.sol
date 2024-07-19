pragma solidity 0.8.20;

import "./IMasterContract.sol";  

interface IFactoryTemplate is IMasterContract {
    function templateId() external view returns (bytes32);
    function initTemplate(bytes calldata _data) external payable;
}
