// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

struct Partner {
    uint share;
    address iCId;
}

contract MLM {
    uint8 public deep;
    uint public fee;
    address payable owner;
    
    address payable[] wallets;
    mapping(address => Partner) partners;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "You aren't contract owner.");
        _;
    }
    
    constructor(uint _fee, uint8 _deep) {
        deep = _deep;
        fee = _fee;
        owner = msg.sender;
        createPartner(owner);
    }
    
    function createPartner(address _iCId) internal {
        partners[msg.sender] = Partner({
            share: 0,
            iCId: _iCId
        });
        wallets.push(msg.sender);
    }
    
    function register(address _iCId) external payable {
        require(msg.value >= fee, "Not enough!");
        createPartner(_iCId);
        
        uint _value = msg.value;
        uint _shared = 0;
        
        for (uint8 i = 0; i < deep; i++) {
            _value /= 2;
            partners[_iCId].share += _value;
            _iCId = partners[_iCId].iCId;
            _shared += _value;
        }
        
        partners[owner].share += msg.value - _shared;
    }
    
    function getPartner() internal view returns (Partner storage) {
        return partners[msg.sender];
    }
    
    function withdraw() public {
        uint amount = getPartner().share;
        getPartner().share = 0;
        msg.sender.transfer(amount);
    }
    
    function getShare() external view returns (uint) {
        return getPartner().share;
    }
    
    function getCurrentBalance() external view returns (uint) {
        return address(this).balance;
    }
    
    function close() public onlyOwner {
        for (uint i=0; i<wallets.length; i++) {
            address payable _wallet = wallets[i];
            Partner storage _partner = partners[_wallet];
            
            if (_partner.share > 0) {
                _wallet.transfer(_partner.share);
            }
        }
        selfdestruct(owner);
    }
}
