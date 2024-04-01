// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface CentralAuthorityContractData {
    function getCentralAuthorityAddress() external view returns (address);
    function CheckCompanyAuth(address _address) external returns (bool);
    function getCompanyWorkType(address _address) external view returns (string memory);
}

contract CreateTender {
    // Variables to store necessary data from central authority contract
    address centralAuthority;
    bool authorized;
    string workType;

    // Variables to store create bid contract data
    uint public tenderNum;

    // Variables to store Central Authority Contract Address
    address CentralAuthorityContractAddress;

    // Tender announcement detailes
    struct TenderAnnouncement{
        address tenderOwner;
        string tenderTitle;
        uint tenderPublishTime;
        uint tenderDuration;
        uint tenderFee;
        uint workDuration;
    }

    // Tender requirements detailes
    struct RequiredTenderDetailes {
        string materialDetailes;
        uint materialQuantities;
        string materialUnits;
        uint materialPrices;
    }

    // Store Tender detailes by Tender number
    mapping (uint => TenderAnnouncement) tenderAnnouncement;
    mapping (uint => RequiredTenderDetailes[]) requiredTenderDetailes;

    constructor(address _CentralAuthorityContractAddress) {
        CentralAuthorityContractAddress = _CentralAuthorityContractAddress;
        getCentralAuthority();
        require(msg.sender == centralAuthority, "Only central authority can deploy this contract");
    }

    // Functios to get necessary data from central authority contract
    function getCentralAuthority() internal {
        centralAuthority = CentralAuthorityContractData(CentralAuthorityContractAddress).getCentralAuthorityAddress();
    }

    function CheckCompany(address _address) internal {
        authorized = CentralAuthorityContractData(CentralAuthorityContractAddress).CheckCompanyAuth(_address);
    }

    function getWorkType(address _address) internal {
        workType = CentralAuthorityContractData(CentralAuthorityContractAddress).getCompanyWorkType(_address);
    }

    // Create Tender Function
    function createBid(string memory _tenderTitle,uint _tenderDuration, uint _tenderFee, uint _workDuration, string[] memory _materialDetailes, uint[] memory _materialQuantities, string[] memory _materialUnits, uint[] memory _materialPrices) public {
        CheckCompany(msg.sender);

        require(authorized, "You are not authorized, You can't create tender");
        require(_materialDetailes.length == _materialQuantities.length && _materialDetailes.length == _materialUnits.length && _materialDetailes.length == _materialPrices.length, "Invalid input data");

        tenderNum ++;

        // Store Tender announcement detailes
        tenderAnnouncement[tenderNum] = TenderAnnouncement(msg.sender, _tenderTitle, block.timestamp, _tenderDuration, _tenderFee, _workDuration);

        // Add bid requirements detailes
        for (uint i = 0; i < _materialDetailes.length; i++) 
        {
            requiredTenderDetailes[tenderNum].push(RequiredTenderDetailes({
                materialDetailes: _materialDetailes[i],
                materialQuantities: _materialQuantities[i],
                materialUnits: _materialUnits[i],
                materialPrices: _materialPrices[i]
            }));
        }
    }

    // Get tender tnnouncement data to use in tender contract
    function getTenderAnnouncement(uint _tenderNum) external view returns (address, uint, uint, uint){
        address owner = tenderAnnouncement[_tenderNum].tenderOwner;
        uint publishTime = tenderAnnouncement[_tenderNum].tenderPublishTime;
        uint duration = tenderAnnouncement[_tenderNum].tenderDuration;
        uint fee = tenderAnnouncement[_tenderNum].tenderFee;

        return (owner, publishTime, duration, fee);
    }

    // Get Tender materials detailes
    function getTenderDetailes(uint _tenderNum) external view returns (string[] memory, uint[] memory, string[] memory, uint[] memory){

        uint dataCount = requiredTenderDetailes[_tenderNum].length;
        
        string [] memory materialsDetaile = new string[](dataCount);
        uint[] memory materialsQuantity = new uint[](dataCount);
        string[] memory materialsUnit = new string[](dataCount);
        uint[] memory materialsPrice = new uint[](dataCount);

        for (uint i = 0; i < dataCount; i++) 
        {
            materialsDetaile[i] = requiredTenderDetailes[_tenderNum][i].materialDetailes;
            materialsQuantity[i] = requiredTenderDetailes[_tenderNum][i].materialQuantities;
            materialsUnit[i] = requiredTenderDetailes[_tenderNum][i].materialUnits;
            materialsPrice[i] = requiredTenderDetailes[_tenderNum][i].materialPrices;
        }
        return (materialsDetaile, materialsQuantity, materialsUnit, materialsPrice);
    }
}