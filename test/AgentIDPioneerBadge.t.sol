// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AgentIDPioneerBadge} from "../src/AgentIDPioneerBadge.sol";

/// @notice Minimal mock of the SPACE ID Agent ID ERC-721 (mainnet 0x60b9262456de011f7d15a54cdd8c48baaa8b022f).
/// @dev Same interface (ERC-721). Test-only mint lets us grant Agent IDs to chosen addresses.
contract MockAgentID is ERC721 {
    uint256 private _nextId = 1;

    constructor() ERC721("SPACE ID Agent ID", "AI") {}

    function mint(address to) external returns (uint256) {
        uint256 id = _nextId++;
        _mint(to, id);
        return id;
    }
}

contract AgentIDPioneerBadgeTest is Test {
    MockAgentID internal agentId;
    AgentIDPioneerBadge internal badge;

    address internal alice = makeAddr("alice"); // Agent ID holder
    address internal bob = makeAddr("bob"); // non-holder

    function setUp() public {
        agentId = new MockAgentID();
        badge = new AgentIDPioneerBadge(address(agentId));
        agentId.mint(alice); // alice holds an Agent ID
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    function test_MintSucceedsForAgentIDHolder() public {
        vm.prank(alice);
        badge.mint();
        assertEq(badge.balanceOf(alice), 1);
        assertEq(badge.ownerOf(1), alice);
        assertTrue(badge.hasMinted(alice));
        assertEq(badge.nextTokenId(), 2);
    }

    function test_MintRevertsForNonHolder() public {
        vm.prank(bob);
        vm.expectRevert(AgentIDPioneerBadge.NotAgentIDHolder.selector);
        badge.mint();
    }

    function test_SecondMintReverts() public {
        vm.prank(alice);
        badge.mint();
        vm.prank(alice);
        vm.expectRevert(AgentIDPioneerBadge.AlreadyMinted.selector);
        badge.mint();
    }

    function test_TransferReverts() public {
        vm.prank(alice);
        badge.mint();
        vm.prank(alice);
        vm.expectRevert(AgentIDPioneerBadge.Soulbound.selector);
        badge.transferFrom(alice, bob, 1);
    }

    function test_SafeTransferReverts() public {
        vm.prank(alice);
        badge.mint();
        vm.prank(alice);
        vm.expectRevert(AgentIDPioneerBadge.Soulbound.selector);
        badge.safeTransferFrom(alice, bob, 1);
    }

    function test_ApproveReverts() public {
        vm.prank(alice);
        badge.mint();
        vm.prank(alice);
        vm.expectRevert(AgentIDPioneerBadge.Soulbound.selector);
        badge.approve(bob, 1);
    }

    function test_SetApprovalForAllReverts() public {
        vm.prank(alice);
        badge.mint();
        vm.prank(alice);
        vm.expectRevert(AgentIDPioneerBadge.Soulbound.selector);
        badge.setApprovalForAll(bob, true);
    }

    function test_MintIsFree_NoValueAccepted() public {
        // mint() is non-payable: attaching BNB reverts. The compiler forbids
        // {value:} on a statically-typed non-payable function, so use a low-level call.
        vm.prank(alice);
        (bool ok, ) = address(badge).call{value: 0.01 ether}(abi.encodeWithSignature("mint()"));
        assertFalse(ok, "mint with attached BNB should revert");
    }

    function test_TokenURIIsDataURI() public {
        vm.prank(alice);
        badge.mint();
        string memory uri = badge.tokenURI(1);
        assertGt(bytes(uri).length, 0);
        bytes memory prefix = bytes("data:application/json;base64,");
        for (uint256 i = 0; i < prefix.length; i++) {
            assertEq(bytes(uri)[i], prefix[i]);
        }
    }

    function test_TokenURINonexistentReverts() public {
        vm.expectRevert();
        badge.tokenURI(999);
    }

    function test_OnlyOwnerCanSetAgentId() public {
        MockAgentID newAgent = new MockAgentID();
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, bob));
        badge.setAgentId(address(newAgent));
    }

    function test_OwnerCanSetAgentId() public {
        MockAgentID newAgent = new MockAgentID();
        badge.setAgentId(address(newAgent));
        assertEq(address(badge.agentId()), address(newAgent));
    }

    function test_ConstructorRevertsOnZeroAgentId() public {
        vm.expectRevert(AgentIDPioneerBadge.ZeroAddress.selector);
        new AgentIDPioneerBadge(address(0));
    }
}
