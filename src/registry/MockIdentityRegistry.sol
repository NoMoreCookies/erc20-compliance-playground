// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IIdentityRegistry} from "../interfaces/IIdentityRegistry.sol";

contract MockIdentityRegistry is IIdentityRegistry, AccessControl {
    bytes32 public constant AGENT_ROLE = keccak256("AGENT_ROLE");

    struct Identity {
        bool registered;
        bool verified;
        uint16 countryCode;
    }

    mapping(address => Identity) private _identities;

    event IdentityRegistered(address indexed wallet, uint16 countryCode);
    event IdentityRemoved(address indexed wallet);
    event IdentityVerificationUpdated(address indexed wallet, bool verified);

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(AGENT_ROLE, msg.sender);
    }

    function registerIdentity(address wallet, uint16 countryCode)
        external
        onlyRole(AGENT_ROLE)
    {
        require(wallet != address(0), "Invalid wallet");
        require(countryCode != 0, "Invalid country code");
        require(!_identities[wallet].registered, "Identity already registered");

        _identities[wallet] = Identity({
            registered: true,
            verified: false,
            countryCode: countryCode
        });

        emit IdentityRegistered(wallet, countryCode);
    }

    function removeIdentity(address wallet)
        external
        onlyRole(AGENT_ROLE)
    {
        require(_identities[wallet].registered, "Identity not registered");

        delete _identities[wallet];

        emit IdentityRemoved(wallet);
    }

    function setVerified(address wallet, bool status)
        external
        onlyRole(AGENT_ROLE)
    {
        require(_identities[wallet].registered, "Identity not registered");

        _identities[wallet].verified = status;

        emit IdentityVerificationUpdated(wallet, status);
    }

    function isVerified(address wallet)
        external
        view
        returns (bool)
    {
        return _identities[wallet].registered && _identities[wallet].verified;
    }

    function getCountryCode(address wallet)
        external
        view
        returns (uint16)
    {
        require(_identities[wallet].registered, "Identity not registered");

        return _identities[wallet].countryCode;
    }
}