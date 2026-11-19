// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {AgentIDPioneerBadge, IAgentID} from "../src/AgentIDPioneerBadge.sol";

/// @notice Fork test against BSC mainnet (real Agent ID contract 0x60b9262456de011f7d15a54cdd8c48baaa8b022f).
/// @dev Run with plain `forge test` — setUp forks BSC via vm.createSelectFork.
///      Verifies the gating works against REAL mainnet state, not just the mock.
contract AgentIDPioneerBadgeForkTest is Test {
    address internal constant AGENT_ID = 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;
    // ajx.ai — Agent ID #17256 (the hackathon entrant's wallet).
    address internal constant AJX_WALLET = 0x6bf297a8f7eb457C01c750a60507C366A2892A2c;

    AgentIDPioneerBadge internal badge;

    function setUp() public {
        vm.createSelectFork("https://bsc-dataseed.bnbchain.org");
        badge = new AgentIDPioneerBadge(AGENT_ID);
    }

    function test_RealAgentIDHolderCanMint() public {
        uint256 bal = IAgentID(AGENT_ID).balanceOf(AJX_WALLET);
        assertGt(bal, 0, "ajx wallet should hold an Agent ID on mainnet");
        vm.prank(AJX_WALLET);
        badge.mint();
        assertEq(badge.balanceOf(AJX_WALLET), 1);
        assertEq(badge.ownerOf(1), AJX_WALLET);
    }

    function test_RealNonHolderCannotMint() public {
        address random = makeAddr("random");
        assertEq(IAgentID(AGENT_ID).balanceOf(random), 0);
        vm.prank(random);
        vm.expectRevert(AgentIDPioneerBadge.NotAgentIDHolder.selector);
        badge.mint();
    }
}
