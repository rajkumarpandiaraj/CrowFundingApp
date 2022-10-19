// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFunding {
    
    struct Campaign{
        address creator;
        uint pledge;
        uint goal;
        uint start;
        uint end;

    }

    uint campaignCount ;
    mapping(uint => Campaign) campaign;
    mapping(uint => mapping(address => uint)) pledgedAmount; 
    mapping(address => bool) isAlreadyCampaignRunning;


    function launch (uint _goal) external {
        require(!isAlreadyCampaignRunning[msg.sender], "Wait till the running Campaign gets end");
        campaignCount++ ;
        campaign[campaignCount] = Campaign(msg.sender,0,_goal, block.timestamp, block.timestamp + 120);

    }

    function pledge (uint _id) external payable {
        require(msg.value > 0, "Please send some Amount");
        require(_id <= campaignCount , "Campaign Doesn't Exists");
        campaign[_id].pledge += msg.value;
        pledgedAmount[_id][msg.sender] += msg.value;
    }

    function unPledge (uint _id) public payable{
        require(_id <= campaignCount , "Campaign Doesn't Exists");
        require(pledgedAmount[_id][msg.sender] != 0, "Sender not exist");
        payable(msg.sender).transfer(pledgedAmount[_id][msg.sender]);
    }

    function unPledge (uint _id, address receiver) public payable{
        require(_id <= campaignCount , "Campaign Doesn't Exists");
        require(pledgedAmount[_id][msg.sender] != 0, "Sender not exist");
        payable(receiver).transfer(pledgedAmount[_id][msg.sender]);
    }

    function claim (uint _id) external {
        require(_id <= campaignCount , "Campaign Doesn't Exists");
        require(campaign[_id].creator == msg.sender,  "Only creator can claim");
        require(block.timestamp > campaign[_id].end, "campaign not stopped yet");
        require(campaign[_id].pledge >= campaign[_id].goal, "Not goal accomplised");

        payable(msg.sender).transfer(campaign[_id].pledge);

    }

    function refund (uint _id) external {
         require(_id <= campaignCount , "Campaign Doesn't Exists");
         require(block.timestamp > campaign[_id].end, "campaign not stopped yet");
         require(campaign[_id].pledge < campaign[_id].goal, "goal accomplised");

        unPledge(_id, msg.sender);
    }

}