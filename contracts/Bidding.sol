// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface CentralAuthorityContractData {
    function CheckCompanyAuth(address _address) external returns (bool);
    function getCentralAuthorityAddress() external view returns (address);
}

interface GetRequiredTenderDetailes {
    function getTenderAnnouncement(uint _tenderNum) external view returns (address, uint, uint, uint);
    function getTenderDetailes(uint _tenderNum) external view returns (string[] memory, uint[] memory, string[] memory, uint[] memory);
}

contract Bidding {
    // Winning Bid and Bidder
    mapping (uint => uint) winnerBid;
    mapping (uint => address) winnerBidder;

    // Variables to store Central Authority and Create Bid contract Addresses
    address CentralAuthorityContractAddress;
    address CreateBidContractAddress;

    // Required tender details
    struct RequiredTender{
        address owner;
        uint publishTime;
        uint duration;
        uint fee;        
        string[] materialsDetaile;
        uint[] materialsQuantity;
        string[] materialsunit;
        uint[] materialsPrice;
    }

    mapping (uint => RequiredTender) requiredTender;

    mapping (uint => uint) jobCount;
    mapping (uint => uint) biddingEndTime;
    mapping (uint => uint) newBiddingEndTime;
    
    mapping (uint => bool) feeReturned;

    // Submitted bids details
    struct Bid{
        uint value;
        uint duration;
    }

    struct BidDetailes {        
        string materialNames;
        uint materialQuantities;
        string materialUnits;
        uint materialPrices;
    }

    // Store all bidder addresses
    mapping (uint => address[]) bidders;

    // Store accepted bidder addresses
    mapping (uint => address[]) acceptedBidders;

    // Store equal bidder addresses
    mapping (uint => address[]) equalBidders;

    // Store each bidder's bid
    mapping (uint => mapping(address => Bid)) bids;

    // Store each bid detailes
    mapping (uint => mapping(address => BidDetailes[])) bidsDetailes;

    // Variables to store necessary data from another contracts
    bool authorized;
    address centralAuthority;

    // Check if the bidder submitted a bid previously
    mapping (uint => mapping (address => bool)) bidSubmitted;
    mapping (uint => mapping (address => bool)) newBidSubmitted;
    
    mapping (uint => bool) rebidAllowed;

    constructor(address _CentralAuthorityContractAddress, address _CreateBidContractAddress) {
        CentralAuthorityContractAddress = _CentralAuthorityContractAddress;
        CreateBidContractAddress = _CreateBidContractAddress;
        getCentralAuthority();
        require(msg.sender == centralAuthority, "Only central authority can deploy this contract");
    }

    function CheckCompany(address _address) internal {
        authorized = CentralAuthorityContractData(CentralAuthorityContractAddress).CheckCompanyAuth(_address);
    }

    function getCentralAuthority() internal {
        centralAuthority = CentralAuthorityContractData(CentralAuthorityContractAddress).getCentralAuthorityAddress();
    }

    // Get the required data for a bid
    function getBidData(uint _tenderNum) internal {
        (requiredTender[_tenderNum].owner, requiredTender[_tenderNum].publishTime, requiredTender[_tenderNum].duration, requiredTender[_tenderNum].fee) = GetRequiredTenderDetailes(CreateBidContractAddress).getTenderAnnouncement(_tenderNum);
        (requiredTender[_tenderNum].materialsDetaile, requiredTender[_tenderNum].materialsQuantity, requiredTender[_tenderNum].materialsunit, requiredTender[_tenderNum].materialsPrice)= GetRequiredTenderDetailes(CreateBidContractAddress).getTenderDetailes(_tenderNum);
        jobCount[_tenderNum] = requiredTender[_tenderNum].materialsDetaile.length;
        biddingEndTime[_tenderNum] = requiredTender[_tenderNum].publishTime + (requiredTender[_tenderNum].duration * 1 minutes);
    }

    function getOwner(uint _tenderNum) public returns (address){
         getBidData(_tenderNum);
         return (requiredTender[_tenderNum].owner);
    }


    function submitBid(uint _tenderNum, uint _bidValue, uint _bidDuration, string[] memory _materialNames, uint[] memory _materialQuantities, string[] memory _materialUnits, uint[] memory _materialPrices) public payable {
        getBidData(_tenderNum);
        CheckCompany(msg.sender);
        require(msg.value >= (requiredTender[_tenderNum].fee * (10 ** 15) * 1 wei), "Insufficient money sent");
        require(authorized, "You are not authorized Company");
        require(msg.sender != requiredTender[_tenderNum].owner, "Owner Can't bid");
        require(!bidSubmitted[_tenderNum][msg.sender], "You have already submit a bid");
        require(jobCount[_tenderNum] ==_materialNames.length && jobCount[_tenderNum] == _materialQuantities.length && jobCount[_tenderNum] == _materialUnits.length && jobCount[_tenderNum] == _materialPrices.length, "Invalid input data");
        require(block.timestamp < biddingEndTime[_tenderNum], "The time for submission of bids has ended");

        address payable owner = payable (requiredTender[_tenderNum].owner);
        owner.transfer(requiredTender[_tenderNum].fee * (10 ** 15) * 1 wei);

        uint sum = 0;

        bidders[_tenderNum].push(msg.sender);
        bidSubmitted[_tenderNum][msg.sender] = true;

        bids[_tenderNum][msg.sender] = Bid(_bidValue,_bidDuration);

        for (uint i = 0; i < _materialNames.length; i++) 
        {
            bidsDetailes[_tenderNum][msg.sender].push(BidDetailes({
                materialNames: _materialNames[i],
                materialQuantities: _materialQuantities[i],
                materialUnits: _materialUnits[i],
                materialPrices: _materialPrices[i]
            }));
            sum += (_materialQuantities[i] * _materialPrices[i]);
        }

        // Check if bid accepted add bidder address to accepted bidder
        if (sum == _bidValue) {
            acceptedBidders[_tenderNum].push(msg.sender);
        }
    }

    function getWinnerBid(uint _tenderNum) public returns(string memory, uint, address) {
        require(acceptedBidders[_tenderNum].length != 0, "No bids accepted, no winning bidder");
        if (newBiddingEndTime[_tenderNum] == 0) {
            require(block.timestamp > biddingEndTime[_tenderNum], "The time for submission of bids hasn't ended");
        } else {
            require(block.timestamp > newBiddingEndTime[_tenderNum], "The time for re-submission of bids hasn't ended");
        }
        require(winnerBidder[_tenderNum] == address(0), "The winning bid has been selected");
        delete equalBidders[_tenderNum];

        rebidAllowed[_tenderNum] = false;

        // Return all values and durations by bidders
        uint biddersCount = acceptedBidders[_tenderNum].length;
        uint[] memory values = new uint[](biddersCount);
        uint[] memory durations = new uint[](biddersCount);

        for (uint i = 0; i < biddersCount; i++) 
        {
            address bidder = acceptedBidders[_tenderNum][i];
            values[i] = bids[_tenderNum][bidder].value;
            durations[i] = bids[_tenderNum][bidder].duration;
        }

        uint smallestValue = values[0];
        uint[] memory smallestValueIndexes = new uint[](1);
        smallestValueIndexes[0] = 0;

        for (uint j = 1; j < biddersCount; j++) 
        {
            if (values[j] < smallestValue) {
                smallestValue = values[j];
                delete smallestValueIndexes;
                smallestValueIndexes = new uint[](1);
                smallestValueIndexes[0] = j;
            } else if (values[j] == smallestValue) {
                uint newSmallestValueIndex = smallestValueIndexes.length;
                uint[] memory newSmallestValueIndexes = new uint[](newSmallestValueIndex + 1);
                for (uint k = 0; k < newSmallestValueIndex; k++) 
                {
                    newSmallestValueIndexes[k] = smallestValueIndexes[k];
                }
                newSmallestValueIndexes[newSmallestValueIndex] = j;
                smallestValueIndexes = newSmallestValueIndexes;
            }
        }

        if (smallestValueIndexes.length == 1) {
            winnerBid[_tenderNum] = values[smallestValueIndexes[0]];
            winnerBidder[_tenderNum] = acceptedBidders[_tenderNum][smallestValueIndexes[0]];
            return ("The winning bid has been selected by value", winnerBid[_tenderNum], winnerBidder[_tenderNum]);
        } else {
            uint smallestDuration = durations[smallestValueIndexes[0]];
            uint[] memory smallestDurationIndexes = new uint[](1);
            smallestDurationIndexes[0] = smallestValueIndexes[0];

            for (uint m = 0; m < smallestValueIndexes.length; m++) 
            {
                uint currentIndex = smallestValueIndexes[m];
                if (durations[currentIndex] < smallestDuration) {
                    smallestDuration = durations[currentIndex];
                    delete smallestDurationIndexes;
                    smallestDurationIndexes = new uint[](1);
                    smallestDurationIndexes[0] = currentIndex;
                } else if (durations[currentIndex] == smallestDuration) {
                    uint newSmallestDurationIndex = smallestDurationIndexes.length;
                    uint[] memory newSmallestDurationIndexes = new uint[](newSmallestDurationIndex + 1);
                    for (uint n = 0; n < newSmallestDurationIndex; n++) 
                    {
                        newSmallestDurationIndexes[n] = smallestDurationIndexes[n];
                    }
                    newSmallestDurationIndexes[newSmallestDurationIndex] = currentIndex;
                    smallestDurationIndexes = newSmallestDurationIndexes;
                }
            }

            if (smallestDurationIndexes.length == 1) {
                winnerBid[_tenderNum] = values[smallestDurationIndexes[0]];
                winnerBidder[_tenderNum] = acceptedBidders[_tenderNum][smallestDurationIndexes[0]];
                return ("The winning bid has been selected by duration", winnerBid[_tenderNum], winnerBidder[_tenderNum]);
            } else {
                for (uint p = 0; p < smallestDurationIndexes.length; p++) 
                {
                    uint index = smallestDurationIndexes[p];
                    equalBidders[_tenderNum].push(acceptedBidders[_tenderNum][index]);
                }
                delete acceptedBidders[_tenderNum];
                return ("There is no winning bid, equal bidders must be allowed to resubmit bids", 0, address(0));
            }
        }
    }

    function allowRebid(uint _tenderNum, uint _newbidDuration) public {     
        require(equalBidders[_tenderNum].length > 1,"There is a winning bid, bids cannot be resubmitted");
        require(msg.sender == requiredTender[_tenderNum].owner, "Only bid owner Can allow re-submit bid");

        rebidAllowed[_tenderNum] = true;
        newBiddingEndTime[_tenderNum] = block.timestamp + (_newbidDuration * 1 minutes);

        for (uint i = 0; i < equalBidders[_tenderNum].length; i++)
        {                       
            if (newBidSubmitted[_tenderNum][equalBidders[_tenderNum][i]] == true) {
                newBidSubmitted[_tenderNum][equalBidders[_tenderNum][i]] = false;
            }            
        }
    }

    function submitNewBid(uint _tenderNum, uint _newBidValue, uint _newWorkDuration, string[] memory _newMaterialNames, uint[] memory _newMaterialQuantities, string[] memory _newMaterialUnits, uint[] memory _newMaterialPrices) public {
        require(msg.sender != requiredTender[_tenderNum].owner, "Owner Can't bid");
        require(rebidAllowed[_tenderNum], "The Owner did not allow new bids to be submitted");
        require(block.timestamp < newBiddingEndTime[_tenderNum], "The time for submission of bids has ended");  
        getBidData(_tenderNum);
        require(jobCount[_tenderNum] ==_newMaterialNames.length && jobCount[_tenderNum] == _newMaterialQuantities.length && jobCount[_tenderNum] ==_newMaterialUnits.length && jobCount[_tenderNum] == _newMaterialPrices.length, "Invalid input data");
        
        

        for (uint i = 0; i < equalBidders[_tenderNum].length; i++) 
        {            
            if (msg.sender == equalBidders[_tenderNum][i]) {
                require(newBidSubmitted[_tenderNum][msg.sender] == false, "You have already re-submit a bid");
                newBidSubmitted[_tenderNum][msg.sender] = true;
                uint sum = 0;
                bids[_tenderNum][msg.sender] = Bid(_newBidValue,_newWorkDuration);
                for (uint j = 0; j < _newMaterialNames.length; j++) 
                {
                    
                    bidsDetailes[_tenderNum][msg.sender][j].materialNames = _newMaterialNames[j];
                    bidsDetailes[_tenderNum][msg.sender][j].materialQuantities = _newMaterialQuantities[j];
                    bidsDetailes[_tenderNum][msg.sender][j].materialUnits = _newMaterialUnits[j];
                    bidsDetailes[_tenderNum][msg.sender][j].materialPrices = _newMaterialPrices[j];
                    sum += (_newMaterialQuantities[j] * _newMaterialPrices[j]);
                }

                // Check if bid accepted add bidder address to accepted bidder
                if (sum == _newBidValue) {
                    acceptedBidders[_tenderNum].push(msg.sender);
                }
            }
        }
    }

    function getFeeToBeReturned(uint _tenderNum) public view returns (uint){
        uint totalCompensation;
        if (winnerBidder[_tenderNum] != address(0)) {
            totalCompensation = ((requiredTender[_tenderNum].fee * 1 ether) * (bidders[_tenderNum].length - 1));
        } else {
            totalCompensation = ((requiredTender[_tenderNum].fee * 1 ether) * (bidders[_tenderNum].length));
        }
        return (totalCompensation);
    }

    function returnFee(uint _tenderNum) public payable {
        uint totalCompensation = ((requiredTender[_tenderNum].fee * 1 ether) * (bidders[_tenderNum].length));
        
        require(msg.sender == requiredTender[_tenderNum].owner, "Owner only can return fee");
        require(msg.value >= totalCompensation, "Insufficient Ether sent");
        require(!feeReturned[_tenderNum], "Fees have already returned");
        if (newBiddingEndTime[_tenderNum] == 0) {
            require(block.timestamp > biddingEndTime[_tenderNum], "The time for submission of bids hasn't ended");
        } else {
            require(block.timestamp > newBiddingEndTime[_tenderNum], "The time for re-submission of bids hasn't ended");
        }
        
        uint eachCompensation = requiredTender[_tenderNum].fee * 1 ether;

        for (uint256 i = 0; i < bidders[_tenderNum].length; i++) 
        {
            if (bidders[_tenderNum][i] != winnerBidder[_tenderNum]) {
                address payable excluded = payable(bidders[_tenderNum][i]);
                excluded.transfer(eachCompensation);
            }
        }
    }


    function getWinnerBidDetailes(uint _tenderNum) external view returns (string[] memory, uint[] memory, uint[] memory){
        require(winnerBidder[_tenderNum] != address(0), "No winner was obtained");
        uint dataCount = bidsDetailes[_tenderNum][winnerBidder[_tenderNum]].length;
        string [] memory detailes = new string[](dataCount);
        uint[] memory quantities = new uint[](dataCount);
        uint[] memory prices = new uint[](dataCount);

        for (uint i = 0; i < dataCount; i++) 
        {
            detailes[i] = bidsDetailes[_tenderNum][winnerBidder[_tenderNum]][i].materialNames;
            quantities[i] = bidsDetailes[_tenderNum][winnerBidder[_tenderNum]][i].materialQuantities;
            prices[i] = bidsDetailes[_tenderNum][winnerBidder[_tenderNum]][i].materialPrices;
        }

        return (detailes, quantities, prices);
    }
}