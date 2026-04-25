// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract ComplianceToken is ERC20, AccessControl {

    bytes32 public constant AGENT_ROLE = keccak256("AGENT_ROLE");
    bytes32 public constant COMPLIANCE_OFFICER = keccak256("COMPLIANCE_OFFICER");
    uint256 public immutable maxSupply;
    bool private _paused;



    mapping(address => bool) private _frozen;

    event Minted(address indexed operator, address indexed to, uint256 amount);
    event AddressFrozen(address indexed account, bool isFrozen, address indexed operator);
    event Paused(address indexed operator);
    event Unpaused(address indexed operator);

    constructor(uint256 initialSupply, uint256 maxSupply_) ERC20("SmartToken", "SMRT"){
        require(initialSupply <= maxSupply_, "Initial supply cannot exceed max supply");

        maxSupply = maxSupply_;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(AGENT_ROLE, msg.sender);
        _grantRole(COMPLIANCE_OFFICER, msg.sender);
        _mint(msg.sender, initialSupply);


    }

    function decimals() public view virtual override returns (uint8) {
        return 2;
    }
    
    function mint(address to, uint256 amount) external onlyRole(AGENT_ROLE) {
        require(totalSupply() + amount <= maxSupply, "Max supply exceeded");
        _mint(to, amount);
        emit Minted(msg.sender, to, amount);
    }

    
    function isFrozen(address account) public view returns (bool) {
        return _frozen[account];
    }

    function setAddressFrozen(address account, bool frozen)
        external
        onlyRole(AGENT_ROLE)
    {
        _frozen[account] = frozen;

        emit AddressFrozen(account, frozen, msg.sender);
    }

    function _update(address from, address to, uint256 value) internal override {
        require(!_paused, "Token is paused");

        if (from != address(0)) {
            require(!_frozen[from], "Sender is frozen");
        }

        if (to != address(0)) {
            require(!_frozen[to], "Receiver is frozen");
        }

        super._update(from, to, value);
    }

    function paused() public view returns (bool) {
        return _paused;
    }


    function pause() external onlyRole(AGENT_ROLE) {
        require(!_paused, "Token is already paused");

        _paused = true;

        emit Paused(msg.sender);
    }

    function unpause() external onlyRole(AGENT_ROLE) {
        require(_paused, "Token is not paused");

        _paused = false;

        emit Unpaused(msg.sender);
    }





}

