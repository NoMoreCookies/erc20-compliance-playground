// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ComplianceToken} from "../../src/compliance/ComplianceService.sol";

contract ComplianceTokenTest is Test {

    ComplianceToken token;

    address deployer = address(this);

    address groundControl = address(0x1);
    address majorTom = address(0x2);


    uint256 constant INITIAL_SUPPLY = 10_000;
    uint256 constant MAX_SUPPLY = 100_000;

    function setUp() public {
        token = new ComplianceToken(INITIAL_SUPPLY, MAX_SUPPLY);
    }

    function testNameIntegration() public view {
        assertEq(token.name(), "SmartToken");
    }

    function testSymbolIntegration() public view {
        assertEq(token.symbol(), "SMRT");
    }

    function testDecimalsIntegration() public view {
        assertEq(token.decimals(), 2);
    }

    function testTotalSupplyIntegration() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY);
    }

    function testCanTransferTokens() public {
        uint256 amount = 1_500; // 15 SMRT

        bool success = token.transfer(groundControl, amount);

        assertTrue(success);

        assertEq(token.balanceOf(groundControl), amount);
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY - amount);
    }

    function testGroundControlCanTransferTokensToMajorTom() public {
        uint256 amountToGroundControl = 5_000; // 50.00 SMRT
        uint256 amountToMajorTom = 1_250;   // 12.50 SMRT

        bool success1 = token.transfer(groundControl, amountToGroundControl);

        assertTrue(success1);

        vm.prank(groundControl);

        bool success2 = token.transfer(majorTom, amountToMajorTom);
        
        assertTrue(success2);

        assertEq(token.balanceOf(groundControl), amountToGroundControl - amountToMajorTom);
        assertEq(token.balanceOf(majorTom), amountToMajorTom);
    }

    function testCannotTransferMoreThanBalance() public {
        uint256 tooMuch = INITIAL_SUPPLY + 1;

        vm.expectRevert();
        bool success = token.transfer(groundControl, tooMuch);
        assertFalse(success);
    }

    function testNonAgentCannotMint() public {
        vm.prank(majorTom);

        vm.expectRevert();
        token.mint(majorTom, 1_000);

    }

    function testAgentCanFreezeAddress() public {
        token.setAddressFrozen(groundControl, true);

        assertTrue(token.isFrozen(groundControl));
    }


    function testNonAgentCannotFreezeAddress() public {
        vm.prank(majorTom);

        vm.expectRevert();
        token.setAddressFrozen(groundControl, true);
    }

    function testCannotTransferToFrozenAccount() public {
        token.setAddressFrozen(groundControl, true);

        vm.expectRevert("Receiver is frozen");
        token.transfer(groundControl, 1_000);
    }

    function testFrozenAccountCannotTransferOut() public {
        token.transfer(groundControl, 2_000);

        token.setAddressFrozen(groundControl, true);

        vm.prank(groundControl);
        vm.expectRevert("Sender is frozen");
        token.transfer(majorTom, 1_000);
    }

    function testConstructorRevertsWhenInitialSupplyExceedsMaxSupply() public {
        vm.expectRevert("Initial supply cannot exceed max supply");

        new ComplianceToken(100_001, 100_000);
    }

    function testNonAgentCannotPause() public {
        vm.prank(majorTom);

        vm.expectRevert();
        token.pause();
    }

    function testCanTransferAfterUnpause() public {
        token.pause();
        token.unpause();

        bool success = token.transfer(groundControl, 1_000);

        assertTrue(success);
        assertEq(token.balanceOf(groundControl), 1_000);
    }


    function testHappyPathTransfer() public {
        uint256 amount = 1_000;

        bool success = token.transfer(groundControl, amount);

        assertTrue(success);
        assertEq(token.balanceOf(groundControl), amount);
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY - amount);
    }
}
