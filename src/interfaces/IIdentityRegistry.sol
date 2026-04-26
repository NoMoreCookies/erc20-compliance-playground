// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIdentityRegistry {
    function registerIdentity(address wallet, uint16 countryCode) external;
    function removeIdentity(address wallet) external;
    function setVerified(address wallet, bool status) external;

    function isVerified(address wallet) external view returns (bool);
    function getCountryCode(address wallet) external view returns (uint16);
}