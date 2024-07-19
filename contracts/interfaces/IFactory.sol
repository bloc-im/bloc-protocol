pragma solidity 0.8.20;

interface IFactory {

    function deployTemplate(
        bytes32 _templateId,
        bytes calldata _data
    )
        external payable returns (address newClone);

}
