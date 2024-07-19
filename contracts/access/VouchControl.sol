pragma solidity 0.8.20;

import "./AdminControl.sol";
import "../interfaces/IVouch.sol";

contract VouchControl is AdminControl  {

    address public vouch;

    // if a user of the vouch contract has more than 1 vouch, then it will be counted as 1

    // get the vouch count from the vouch contract

    function initVouch(address _vouch) external {
        require(vouch == address(0), "Already initialized");
        vouch = _vouch;
    }

    function getVouchCount(address user) public view returns (uint256) {
        address[] memory trustMembers = IVouch(vouch).getTrustMembers(user);
        return trustMembers.length;
    }

}