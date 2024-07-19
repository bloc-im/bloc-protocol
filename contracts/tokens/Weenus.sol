pragma solidity 0.8.20;
// ----------------------------------------------------------------------------
// BokkyPooBah's Test ERC20
//
// https://github.com/bokkypoobah/Nix
//
// SPDX-License-Identifier: MIT
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2021. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// TestERC20 = ERC20 + symbol + name + decimal
// ----------------------------------------------------------------------------
contract Weenus {

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);


    bytes32 public immutable templateId = keccak256("Penis");

    string _symbol;
    string  _name;
    uint8 _decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    function initToken(string memory __symbol, string memory __name, uint fixedSupply, address user) public {
        require(_decimals == 0, "ALREADY INITIALIZED");
        _symbol = __symbol;
        _name = __name;
        _decimals = 18;
        _totalSupply = fixedSupply;
        balances[user] = _totalSupply;
        emit Transfer(address(0), user, _totalSupply);
    }
    function symbol() public view  returns (string memory) {
        return _symbol;
    }
    function name() public view  returns (string memory) {
        return _name;
    }
    function decimals() public view  returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view  returns (uint) {
        return _totalSupply - balances[address(0)];
    }
    function balanceOf(address tokenOwner) public view  returns (uint balance) {
        return balances[tokenOwner];
    }
    function transfer(address to, uint tokens) public  returns (bool success) {
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) public  returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    function allowance(address tokenOwner, address spender) public view  returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    function transferFrom(address from, address to, uint tokens) public  returns (bool success) {
        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }

    
    ///--------------------------------------------------------
    /// Factory
    ///--------------------------------------------------------

    function init(bytes calldata _data) external  payable {}

    function initTemplate(bytes calldata _data) external  payable {
        (
        string memory __name, 
        string memory __symbol, 
        uint256 _initialSupply,
        address _user
        ) = abi.decode(_data, (string, string,uint256, address));
        initToken(
            __name, 
            __symbol, 
            _initialSupply,
            _user
        );
    }

    function getInitData(
        string memory __name, 
        string memory __symbol, 
        uint256 _initialSupply,
        address _user
    )
        external
        pure
        returns (bytes memory _data)
    {
        return abi.encode(
                            __name, 
                            __symbol, 
                            _initialSupply,
                            _user
                        );
    }

}
