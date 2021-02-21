// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;



contract IlyaSociety {
    string public symbol;
    uint256 counter;
    mapping(uint256 => Ilya) society;
    address payable wallet;
    
    struct Ilya {
        uint256 id;
        address wallet;
        uint256 share;
        string contact;
        bool enabled;
        uint256 iCId;
    }
    
    constructor(string memory _symbol, string memory _contact) payable {
        symbol = _symbol;
        society[counter] = Ilya({
            id: ++counter, 
            wallet: msg.sender, 
            share: msg.value, 
            contact: _contact, 
            enabled: true,
            iCId: 0
        });
        wallet.transfer(msg.value);
    }
    
    function getIlyaObj(uint256 _id, bool onlyEnabled) internal view returns (Ilya storage) {
        Ilya storage _ilya = society[_id];
        require(_ilya.wallet == msg.sender, "You aren't in `Ilya Society` base.");
        if (onlyEnabled) {
            require(_ilya.enabled, "You aren't enabled.");
        }
        return _ilya;
    }
    
    function addIlya(uint256 _id, address _wallet, string memory _contact) external returns (uint256) {
        society[counter] = Ilya({
            id: ++counter,
            wallet: _wallet,
            share: 0,
            contact: _contact,
            enabled: false,
            iCId: getIlyaObj(_id, true).id
        });
        return counter;
    }
    
    function activate(uint256 _id) external payable {
        Ilya storage _ilya = getIlyaObj(_id, false);
        _ilya.share = msg.value;
        _ilya.enabled = true;
        wallet.transfer(msg.value);
    }
    
    function getIlya(uint256 _senderId, uint256 _ilyaId) external view returns (uint256, address, uint256, string memory, bool, uint256) {
        getIlyaObj(_senderId, true);
        require(_ilyaId <= counter);
        return (
            society[_ilyaId].id, 
            society[_ilyaId].wallet, 
            society[_ilyaId].share, 
            society[_ilyaId].contact, 
            society[_ilyaId].enabled, 
            society[_ilyaId].iCId
        );
    }
    
    function getSocietyBalance() external view returns (uint256) {
        return wallet.balance;
    }
}
