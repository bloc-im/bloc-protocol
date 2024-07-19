pragma solidity ^0.8.20;

import "./DeployHelpers.s.sol";

contract BaseScript is ScaffoldETHDeploy {
    error InvalidPrivateKey(string);

    AddressDecoder addressDecoder = new AddressDecoder();
    uint256 deployerPrivateKey;
    address deployer;
    string fileName =
        string(abi.encodePacked(vm.toString(block.chainid), ".json"));
    string deployedContractsPath =
        string(abi.encodePacked("./script/deployedContracts/", fileName));
    string contractsJsonString = vm.readFile(deployedContractsPath);

    function initializeDeployer() internal {
        deployerPrivateKey = setupLocalhostEnv();
        if (deployerPrivateKey == 0) {
            revert InvalidPrivateKey(
                "You don't have a deployer account. Make sure you have set DEPLOYER_PRIVATE_KEY in .env or use `yarn generate` to generate a new random account"
            );
        }
        deployer = vm.addr(deployerPrivateKey);
        console.log("deployer:", deployer);
    }

    function getDeployedContract(
        string memory contractName
    ) public view returns (address) {
        bytes memory contractAddressBytes;

        // Try to parse the JSON
        try vm.parseJson(contractsJsonString, contractName) returns (
            bytes memory result
        ) {
            contractAddressBytes = result;
        } catch {
            // Handle the failure of vm.parseJson here
            return address(0);
        }

        try addressDecoder.decodeAddress(contractAddressBytes) returns (
            address contractAddress
        ) {
            return contractAddress;
        } catch {
            // Handle the failure of abi.decode here
            return address(0);
        }
    }


    // function getDeployedContract(string memory contractName) public view returns (address) {
    //     return abi.decode(vm.parseJson(contractsJsonString, contractName), (address));
    // }
}


contract AddressDecoder {
    function decodeAddress(bytes memory data) public pure returns (address) {
        return abi.decode(data, (address));
    }
}