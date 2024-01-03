//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {OurToken} from "../src/OurToken.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployOurToken;

    uint256 public constant STARTING_BALANCE = 1000;
    uint256 public constant TRANSFER_AMOUNT = 50;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    function setUp() public {
        deployOurToken = new DeployOurToken();
        ourToken = deployOurToken.run();

        vm.prank(address(msg.sender));
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function test_BobBalance() public {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    // ================================================================
    // │                        TEST ALLOWANCES                       │
    // ================================================================
    function test_AllowancesWorks() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        // Bob approves Alice to spend tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        // Alice spends some tokens
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function test_CannotTransferFromWithoutApproval() public {
        vm.expectRevert();
        ourToken.transferFrom(bob, alice, TRANSFER_AMOUNT);
    }

    function test_ApproveSetsAllowance() public {
        vm.prank(bob);
        ourToken.approve(alice, TRANSFER_AMOUNT);

        assertEq(
            ourToken.allowance(bob, alice),
            TRANSFER_AMOUNT,
            "Allowance should be set correctly"
        );
    }

    // ================================================================
    // │                         TEST TRANSFER                        │
    // ================================================================
    function testTransfer() public {
        uint256 senderInitialBalance = ourToken.balanceOf(bob);
        uint256 receiverInitialBalance = ourToken.balanceOf(alice);

        vm.prank(bob);
        ourToken.transfer(alice, TRANSFER_AMOUNT);

        assertEq(
            ourToken.balanceOf(bob),
            senderInitialBalance - TRANSFER_AMOUNT,
            "Sender balance did not decrease by transfer amount"
        );
        assertEq(
            ourToken.balanceOf(alice),
            receiverInitialBalance + TRANSFER_AMOUNT,
            "Receiver balance did not increase by transfer amount"
        );
    }

    function test_CannotTransferMoreThanBalance() public {
        uint256 amount = ourToken.balanceOf(bob) + 1;

        vm.expectRevert();
        ourToken.transfer(alice, amount);
    }

    // ================================================================
    // │                          MISC TESTS                          │
    // ================================================================

    function testDecimals() public {
        assertEq(ourToken.decimals(), 18, "Decimals should be 18");
    }

    // function testBurn() public {
    //     uint256 initialSupply = ourToken.totalSupply();
    //     uint256 burnAmount = 1000;

    //     ourToken.burn(burnAmount);
    //     assertEq(
    //         ourToken.totalSupply(),
    //         initialSupply - burnAmount,
    //         "Supply should decrease after burn"
    //     );
    // }
}
