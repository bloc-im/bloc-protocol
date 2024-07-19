pragma solidity 0.8.20;

interface ICommunityData {
    function addCommunity(address _community) external;
    function addMemberToCommunity(address _community, address _user) external;
    function removeMemberFromCommunity(address _community, address _user) external;
}
