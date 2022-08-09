// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


contract FootballCatToken is Ownable{
    mapping(address => uint256) _balances;
    mapping(address => bool) _isWhitelisted;
    mapping(address => mapping(address => uint256)) _allowances;

    uint256 _totalSupply;
    uint256 _maxSwap;
    string _name;
    string _symbol;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed _owner, address indexed spender, uint256 amount);

   
    constructor() {
        _name = "Football Cat Token";
        _symbol = "FCT";
        _maxSwap = 2000;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 9;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256 balance) {
        return _balances[account];
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _isWhitelisted[account];
    } 

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function maxSwap() public view returns (uint256) {
        return _maxSwap;
    }

    function changeMaxSwap(uint256 newMaxSwap) public onlyOwner {
        _maxSwap = newMaxSwap;
    }

    function addWhitelist(address account) public onlyOwner {
        _isWhitelisted[account] = true;
    }

    function unWhitelist(address account) public onlyOwner {
        _isWhitelisted[account] = false;
    }

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;

        unchecked {
            _balances[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }
    
    function mint(address to, uint256 amount) public onlyOwner{
        _mint(to,amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        
        uint256 currentBalance = _balances[account];
        
        require(currentBalance >= amount, "ERC20: burn amount exceeds balance");
        _totalSupply -= amount;

        unchecked {
            _balances[account] -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

    function transfer(address to, uint256 amount) public returns (bool success) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual  {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(
            owner() == _msgSender() || amount <= _maxSwap || isWhitelisted(sender)
            , "ERC20: transfer amount exceeds Whitelist allow"
        );
        
        unchecked {
            _balances[sender] -= amount;
        }

        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool success) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool success) {
        uint256 currentAllowance = _allowances[from][to];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        
        _transfer(from, to, amount);

        unchecked {
            _approve(from, to, currentAllowance - amount);
        }

        return true;
    }
}