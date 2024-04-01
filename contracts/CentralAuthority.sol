// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract CentralAuthority {
    address centralAuthority;

    struct Company{
        string name;
        uint phone;
        string email;
        string city;
        string workType;
        bool authorized;
        bool existed;
    }

    // List of copmanies addresses
    address [] public companiesAddresses;

    // Store Companies by company address
    mapping (address => Company) public companies;

    constructor() {
        centralAuthority = msg.sender;
    }

    // Allow to central authority only to execute function
    modifier onlyCA(){
        require(msg.sender == centralAuthority, "Only the Central Authority can modify companies");
        _;
    }

    function addCompany(address _address, string memory _name, uint _phone, string memory _email, string memory _city, string memory _workType) public onlyCA{
        require(!companies[_address].existed, "This company has already existed");

        companies[_address] = Company(_name, _phone, _email, _city, _workType, true, true);
        companiesAddresses.push(_address);
    }

    function deleteCompany(address _address) public onlyCA {
        delete companies[_address];
    }

    function unAuthorizeCompany(address _address) public onlyCA{
        require(companies[_address].authorized,"Company hasn't authorized");
        companies[_address].authorized = false;
    }

    function authorizeCompany(address _address) public onlyCA{
        require(companies[_address].existed, "This company does not exist");
        require(!companies[_address].authorized,"Company has already authorized");
        companies[_address].authorized = true;
    }    

    function getCompanyDetails(address _address) external view returns (string memory, uint, string memory, string memory, string memory, bool){
        return (companies[_address].name,
        companies[_address].phone,
        companies[_address].email,
        companies[_address].city,
        companies[_address].workType,
        companies[_address].authorized);
    }  

    function CheckCompanyAuth(address _address) external view returns (bool){
        return companies[_address].authorized;
    }

    function getCompanyWorkType(address _address) external view returns (string memory){
        return companies[_address].workType;
    }

    function getCentralAuthorityAddress() external view returns (address) {
        return centralAuthority;
    }
}