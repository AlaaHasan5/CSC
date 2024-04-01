// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface GetCompanyData {
    function CheckCompanyAuth(address _address) external returns (bool);
    function getCompanyWorkType(address _address) external view returns (string memory);
}

interface GetWinnerBidData {
    function getWinner(uint _bidNum) external view returns (address);
    function getWinnerBidDetailes(uint _bidNum) external view returns (string[] memory, uint[] memory, uint[] memory);
}

interface GetBidDetailes {
    function receiveBidMaterialData(uint _bidNum) external view returns (address, string[] memory, uint[] memory);
}

contract Materials{
    uint public materialInvoiceNum = 0;

    // The required data
    bool authorized;
    string workType;

    struct InvoiceMaterial{
        address sendFrom;
        address sendTo;
        string detailes;
        uint quantity;
        uint price;
    }

    struct Material{
        address producer;
        string materialName;
        string materialDetailes;
        uint materialQuantity;
        string materialUnit;
        uint materialPrice;
        string priceUnit;
    }

    // Store Materialss detailes by owner
    mapping (address => Material[]) materials;
    mapping (uint => InvoiceMaterial) invoiceMaterials;

    // Address of contract we need to import
    address CentralAuthorityAddress;
    address CreateBidAddress;
    address BiddingAddress;

    struct WinnerBidDetailes{
        string[] detailes;
        uint[] quantities;
        uint[] prices;
    }

    struct ReceiveBidMaterialDetailes{
        address bidOwner;
        string[] receiveDetailes;
        uint[] receiveQuantities;
    }

    mapping (uint => WinnerBidDetailes) winnerBidDetailes;
    mapping (uint => address) winnerBidder;

    mapping (uint => ReceiveBidMaterialDetailes) receiveBidMaterialDetailes;

    constructor(address _CentralAuthorityAddress, address _CreateBidAddress, address _BiddingAddress) {
        CentralAuthorityAddress = _CentralAuthorityAddress;
        CreateBidAddress = _CreateBidAddress;
        BiddingAddress = _BiddingAddress;
    }

    // Get data from Central Authority contract
    function CheckCompany(address _address) internal {
        authorized = GetCompanyData(CentralAuthorityAddress).CheckCompanyAuth(_address);
    }

    function getWorkType(address _address) internal {
        workType = GetCompanyData(CentralAuthorityAddress).getCompanyWorkType(_address);
    }

    function receiveBidMaterialData(uint _bidNum) internal {
        (receiveBidMaterialDetailes[_bidNum].bidOwner, receiveBidMaterialDetailes[_bidNum].receiveDetailes, receiveBidMaterialDetailes[_bidNum].receiveQuantities) = GetBidDetailes(CreateBidAddress).receiveBidMaterialData(_bidNum);
    }
// -------------------------------------------------------
    function winnerBiddata(uint _bidNum) internal {
        (winnerBidDetailes[_bidNum].detailes, winnerBidDetailes[_bidNum].quantities, winnerBidDetailes[_bidNum].prices) = GetWinnerBidData(BiddingAddress).getWinnerBidDetailes(_bidNum);
    }

    function getWinnerBidder(uint _bidNum) internal {
        winnerBidder[_bidNum] = GetWinnerBidData(BiddingAddress).getWinner(_bidNum);
    }

    // Specify who can use the functions
    modifier onlyProducer(){
        getWorkType(msg.sender);
        require(keccak256(abi.encodePacked(workType)) == keccak256(abi.encodePacked("Producer")) || keccak256(abi.encodePacked(workType)) == keccak256(abi.encodePacked("Manufacturer")), "Only Producer and Manufacturer can add product");
        _;
    }    

    modifier onlyAuth(){
        CheckCompany(msg.sender);
        require(authorized == true, "Only authorized can add product");
        _;
    }

    function addMaterial(string memory _name, string memory _detailes, uint _quantity, string memory _materialUnit, uint _price, string memory _priceUnit) public {
        bool found;
        Material[] storage material = materials[msg.sender];        
        if (material.length == 0) {
            materials[msg.sender].push(Material(msg.sender, _name, _detailes, _quantity, _materialUnit, _price, _priceUnit));
        } else {
            for (uint i = 0; i< material.length; i++) 
            {
                if (keccak256(abi.encodePacked(material[i].materialName)) == keccak256(abi.encodePacked(_name))
                && keccak256(abi.encodePacked(material[i].materialDetailes)) == keccak256(abi.encodePacked(_detailes))
                && keccak256(abi.encodePacked(material[i].materialUnit)) == keccak256(abi.encodePacked(_materialUnit))
                && material[i].materialPrice == _price
                && keccak256(abi.encodePacked(material[i].priceUnit)) == keccak256(abi.encodePacked(_priceUnit))) {
                    material[i].materialQuantity += _quantity;
                    found = true;
                    break;
                } 
            }

            if (!found) {
                materials[msg.sender].push(Material(msg.sender, _name, _detailes, _quantity, _materialUnit, _price, _priceUnit));
            }
        }
    }

    function sendMaterial(string memory _detailes, uint _quantity, uint _price, address _sendTo) public {
        require(msg.sender != _sendTo, "You can not send material to yourself");

        Material[] storage senderMaterial = materials[msg.sender];
        bool sent;
        for (uint i = 0; i< senderMaterial.length; i++) 
        {
            if (keccak256(abi.encodePacked(senderMaterial[i].materialDetailes)) == keccak256(abi.encodePacked(_detailes)) && _quantity <= senderMaterial[i].materialQuantity && senderMaterial[i].materialPrice == _price) {
                materialInvoiceNum++;

                invoiceMaterials[materialInvoiceNum].sendFrom = msg.sender;
                invoiceMaterials[materialInvoiceNum].sendTo = _sendTo;
                invoiceMaterials[materialInvoiceNum].detailes = _detailes;
                invoiceMaterials[materialInvoiceNum].quantity = _quantity;
                invoiceMaterials[materialInvoiceNum].price = _price;

                senderMaterial[i].materialQuantity = senderMaterial[i].materialQuantity - _quantity;
                sent = true;
                break;
            }
        }
        if (!sent) {
            revert("You don't have this material or the quantity you sent is greater than the quantity you own");
        }
    }

    function receiveMaterial(uint _materialInvoiceNum,string memory _detailes, uint _quantity, address _sendFrom, uint _newPrice) public payable {
        require(msg.sender == invoiceMaterials[_materialInvoiceNum].sendTo, "Only the send to addresse can receive the material");
        require(_sendFrom == invoiceMaterials[_materialInvoiceNum].sendFrom, "The sender you entered is different from the sender of the materials");
        require(_quantity == invoiceMaterials[_materialInvoiceNum].quantity, "The quantity you entered is different from the quantity sent");
        require(_newPrice >= invoiceMaterials[_materialInvoiceNum].price, "You cannot enter a price lower than the purchase price");
        
        Material[] storage senderMaterial = materials[_sendFrom];
        for (uint i = 0; i< senderMaterial.length; i++) 
        {
            if (keccak256(abi.encodePacked(senderMaterial[i].materialDetailes)) == keccak256(abi.encodePacked(_detailes))) {
                uint invoicePrice = invoiceMaterials[materialInvoiceNum].quantity * invoiceMaterials[materialInvoiceNum].price;
                require(msg.value >= invoicePrice, "The sent amount is less than the invoice price");

                Material[] storage receiverMaterial = materials[msg.sender];
                if (receiverMaterial.length == 0) {
                    materials[msg.sender].push(Material(senderMaterial[i].producer, senderMaterial[i].materialName, _detailes, _quantity, senderMaterial[i].materialUnit, _newPrice, senderMaterial[i].priceUnit));
                } else {
                    for (uint j =0; j < receiverMaterial.length; j++) 
                    {
                        if (keccak256(abi.encodePacked(receiverMaterial[j].materialDetailes)) == keccak256(abi.encodePacked(_detailes)) && receiverMaterial[j].materialPrice == _newPrice) {
                            receiverMaterial[j].materialQuantity = receiverMaterial[j].materialQuantity + _quantity;
                        } else {
                            materials[msg.sender].push(Material(senderMaterial[i].producer, senderMaterial[i].materialName, _detailes, _quantity, senderMaterial[i].materialUnit, _newPrice, senderMaterial[i].priceUnit));
                        }
                    }
                }
                payable(invoiceMaterials[_materialInvoiceNum].sendFrom).transfer(invoicePrice);
            } else {
                senderMaterial[i].materialQuantity = senderMaterial[i].materialQuantity + _quantity;
            }
        }
    }

    function receiveBidMaterial(uint _bidNum, uint _materialInvoiceNum,string memory _detailes, uint _quantity, address _sendFrom, uint _newPrice) public payable {
        getWinnerBidder(_bidNum);
        require(_sendFrom == winnerBidder[_bidNum], "Only the winning bidder can send bid materials");
        require(msg.sender == receiveBidMaterialDetailes[_bidNum].bidOwner, "Only the owner of bid can receive bid materials");
        require(msg.sender == invoiceMaterials[_materialInvoiceNum].sendTo, "Only the send to addresse can receive the material");
        require(_sendFrom == invoiceMaterials[_materialInvoiceNum].sendFrom, "The sender you entered is different from the sender of the materials");
        require(_quantity == invoiceMaterials[_materialInvoiceNum].quantity, "The quantity you entered is different from the quantity sent");
        
        winnerBiddata(_bidNum);
        uint dataCount = winnerBidDetailes[_bidNum].detailes.length;
        Material[] storage senderMaterial = materials[_sendFrom];
        for (uint i = 0; i< senderMaterial.length; i++) 
        {
            if (keccak256(abi.encodePacked(senderMaterial[i].materialDetailes)) == keccak256(abi.encodePacked(_detailes))) {
                for (uint j = 0; j < dataCount; j++) 
                {
                    if (keccak256(abi.encodePacked(senderMaterial[i].materialDetailes)) == keccak256(abi.encodePacked(winnerBidDetailes[_bidNum].detailes[j]))) {
                        uint materialInvoicePrice = invoiceMaterials[_materialInvoiceNum].quantity * winnerBidDetailes[_bidNum].prices[j];
                        require(msg.value >= materialInvoicePrice, "The sent amount is less than the invoice price");
                        Material[] storage receiverMaterial = materials[msg.sender];
                        if (receiverMaterial.length == 0) {
                            materials[msg.sender].push(Material(senderMaterial[i].producer, senderMaterial[i].materialName, _detailes, _quantity, senderMaterial[i].materialUnit, _newPrice, senderMaterial[i].priceUnit));
                        } else {
                            for (uint k =0; k < receiverMaterial.length; k++) 
                            {
                                if (keccak256(abi.encodePacked(receiverMaterial[k].materialDetailes)) == keccak256(abi.encodePacked(_detailes)) && receiverMaterial[k].materialPrice == _newPrice) {
                                    receiverMaterial[k].materialQuantity = receiverMaterial[k].materialQuantity + _quantity;
                                } else {
                                    materials[msg.sender].push(Material(senderMaterial[i].producer, senderMaterial[i].materialName, _detailes, _quantity, senderMaterial[i].materialUnit, _newPrice, senderMaterial[i].priceUnit));
                                }
                            }
                        }
                        payable(invoiceMaterials[_materialInvoiceNum].sendFrom).transfer(materialInvoicePrice);
                    }
                }
            } else {
                senderMaterial[i].materialQuantity = senderMaterial[i].materialQuantity + _quantity;
            }
        }
    }
}