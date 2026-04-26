// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MockIdentityRegistry} from "../../src/registry/MockIdentityRegistry.sol";

contract MockIdentityRegistryTest is Test {
    MockIdentityRegistry registry;

    address admin = address(this);
    address agent = address(0xA11CE);
    address unauthorized = address(0xBAD);

    address groundControl = address(0x1);
    address majorTom = address(0x2);

    uint16 constant POLAND = 616;
    uint16 constant GERMANY = 276;

    event IdentityRegistered(address indexed wallet, uint16 countryCode);
    event IdentityRemoved(address indexed wallet);
    event IdentityVerificationUpdated(address indexed wallet, bool verified);

    function setUp() public {
        registry = new MockIdentityRegistry();

        registry.grantRole(registry.AGENT_ROLE(), agent);
    }

    function testDeployerHasDefaultAdminRole() public view{
        bool hasAdminRole = registry.hasRole(
            registry.DEFAULT_ADMIN_ROLE(),
            admin
        );

        assertTrue(hasAdminRole);
    }

    function testDeployerHasAgentRole() public view{
        bool hasAgentRole = registry.hasRole(
            registry.AGENT_ROLE(),
            admin
        );

        assertTrue(hasAgentRole);
    }

    function testAgentCanRegisterIdentity() public {

        vm.prank(agent);

        vm.expectEmit(true, false, false, true);

        emit IdentityRegistered(groundControl, POLAND);

        registry.registerIdentity(groundControl, POLAND);

        uint16 countryCode = registry.getCountryCode(groundControl);

        assertEq(countryCode, POLAND);

        assertFalse(registry.isVerified(groundControl));
    }

    function testCannotRegisterZeroAddress() public {
        vm.prank(agent);
        vm.expectRevert(bytes("Invalid wallet"));

        registry.registerIdentity(address(0), POLAND);
    }

    function testCannotRegisterWithZeroCountryCode() public {
        vm.prank(agent);
        vm.expectRevert(bytes("Invalid country code"));

        registry.registerIdentity(groundControl, 0);
    }

    function testUnauthorizedAddressCannotRegisterIdentity() public {
        vm.prank(unauthorized);
        vm.expectRevert();

        registry.registerIdentity(groundControl, POLAND);
    }

    function testAgentCanSetVerifiedTrue() public {
        vm.prank(agent);
        registry.registerIdentity(groundControl, POLAND);

        vm.prank(agent);

        vm.expectEmit(true, false, false, true);
        emit IdentityVerificationUpdated(groundControl, true);

        registry.setVerified(groundControl, true);

        assertTrue(registry.isVerified(groundControl));
    }

    function testAgentCanSetVerifiedFalse() public {
        vm.prank(agent);
        registry.registerIdentity(groundControl, POLAND);

        vm.prank(agent);
        registry.setVerified(groundControl, true);

        assertTrue(registry.isVerified(groundControl));

        vm.prank(agent);

        vm.expectEmit(true, false, false, true);
        emit IdentityVerificationUpdated(groundControl, false);

        registry.setVerified(groundControl, false);

        assertFalse(registry.isVerified(groundControl));
    }

    function testCannotSetVerifiedForUnregisteredWallet() public {
        vm.prank(agent);
        vm.expectRevert(bytes("Identity not registered"));

        registry.setVerified(groundControl, true);
    }

    function testUnauthorizedAddressCannotSetVerified() public {
        vm.prank(agent);
        registry.registerIdentity(groundControl, POLAND);

        vm.prank(unauthorized);
        vm.expectRevert();

        registry.setVerified(groundControl, true);
    }

    function testGetCountryCodeReturnsCorrectCountry() public {
        vm.prank(agent);
        registry.registerIdentity(groundControl, POLAND);

        uint16 countryCode = registry.getCountryCode(groundControl);

        assertEq(countryCode, POLAND);
    }

    function testCannotGetCountryCodeForUnregisteredWallet() public {
        
        vm.expectRevert(bytes("Identity not registered"));

        registry.getCountryCode(groundControl);
    }

    function testIsVerifiedReturnsFalseForUnregisteredWallet() public {
        bool verified = registry.isVerified(groundControl);

        assertFalse(verified);
    }

    function testIsVerifiedReturnsFalseForRegisteredButNotVerifiedWallet() public {
        vm.prank(agent);
        registry.registerIdentity(groundControl, POLAND);

        bool verified = registry.isVerified(groundControl);

        assertFalse(verified);
    }

    function testAgentCanRemoveIdentity() public {
        vm.prank(agent);
        registry.registerIdentity(groundControl, POLAND);

        vm.prank(agent);
        registry.setVerified(groundControl, true);

        assertTrue(registry.isVerified(groundControl));

        vm.prank(agent);

        vm.expectEmit(true, false, false, true);

        emit IdentityRemoved(groundControl);

        registry.removeIdentity(groundControl);

        assertFalse(registry.isVerified(groundControl));

        vm.expectRevert(bytes("Identity not registered"));
        registry.getCountryCode(groundControl);
    }

    function testCannotRemoveUnregisteredIdentity() public {
        vm.prank(agent);
        vm.expectRevert(bytes("Identity not registered"));

        registry.removeIdentity(groundControl);
    }

    function testUnauthorizedAddressCannotRemoveIdentity() public {
        vm.prank(agent);
        registry.registerIdentity(groundControl, POLAND);

        vm.prank(unauthorized);
        vm.expectRevert();

        registry.removeIdentity(groundControl);
    }

    function testAgentCanRegisterMajorTomIdentity() public {
        vm.prank(agent);
        registry.registerIdentity(majorTom, GERMANY);

        uint16 countryCode = registry.getCountryCode(majorTom);

        assertEq(countryCode, GERMANY);
        assertFalse(registry.isVerified(majorTom));
    }


    function testCannotRegisterAlreadyRegisteredIdentity() public {
        vm.prank(agent);
        registry.registerIdentity(groundControl, POLAND);

        vm.prank(agent);
        vm.expectRevert(bytes("Identity already registered"));

        registry.registerIdentity(groundControl, GERMANY);
    }
}