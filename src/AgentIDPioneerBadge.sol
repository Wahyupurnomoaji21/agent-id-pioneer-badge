// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/// @title Agent ID Pioneer Badge
/// @notice A FREE, soulbound (non-transferable) ERC-721 badge for Agent ID holders.
/// @dev Minting is gated on holding an Agent ID (SPACE ID Agent ID, ERC-721) on BNB Chain.
///      The badge is soulbound: all transfers (and approvals) revert; only minting is allowed.
///      Metadata is generated fully on-chain as an SVG badge (no external hosting, no fees).
interface IAgentID {
    function balanceOf(address owner) external view returns (uint256);
}

contract AgentIDPioneerBadge is ERC721, Ownable {
    using Strings for uint256;

    /// @notice The Agent ID contract (SPACE ID Agent ID on BNB Chain).
    IAgentID public agentId;

    /// @notice Next token id to mint (starts at 1).
    uint256 public nextTokenId = 1;

    /// @notice True if an address has already minted its badge (1 per wallet).
    mapping(address => bool) public hasMinted;

    /// @notice Caller does not hold an Agent ID.
    error NotAgentIDHolder();
    /// @notice Caller already minted a badge (1 per wallet).
    error AlreadyMinted();
    /// @notice The badge is soulbound: transfers and approvals are blocked.
    error Soulbound();
    /// @notice The new Agent ID address is the zero address.
    error ZeroAddress();

    /// @notice Emitted when a badge is minted.
    event BadgeMinted(address indexed minter, uint256 indexed tokenId);
    /// @notice Emitted when the owner updates the Agent ID contract address.
    event AgentIdUpdated(address indexed oldAgentId, address indexed newAgentId);

    constructor(address _agentId) ERC721("Agent ID Pioneer Badge", "AIPB") Ownable(msg.sender) {
        if (_agentId == address(0)) revert ZeroAddress();
        agentId = IAgentID(_agentId);
    }

    /// @notice Mint one free Pioneer Badge. Caller must hold an Agent ID. Free (no payment).
    /// @dev Non-payable: sending BNB with the call reverts. 1 badge per wallet.
    function mint() external {
        if (agentId.balanceOf(msg.sender) == 0) revert NotAgentIDHolder();
        if (hasMinted[msg.sender]) revert AlreadyMinted();
        hasMinted[msg.sender] = true;
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        _safeMint(msg.sender, tokenId);
        emit BadgeMinted(msg.sender, tokenId);
    }

    /// @notice Owner-only: update the Agent ID contract address (e.g. if Agent ID migrates).
    /// @dev Disclosed admin power. The owner may also renounce ownership to lock the contract.
    function setAgentId(address _newAgentId) external onlyOwner {
        if (_newAgentId == address(0)) revert ZeroAddress();
        address oldAgentId = address(agentId);
        agentId = IAgentID(_newAgentId);
        emit AgentIdUpdated(oldAgentId, _newAgentId);
    }

    /// @dev Soulbound: only minting (from == address(0)) is allowed. All transfers/burns revert.
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address from = _ownerOf(tokenId);
        if (from != address(0)) revert Soulbound();
        return super._update(to, tokenId, auth);
    }

    /// @dev Soulbound: approvals are meaningless (transfers are blocked), so block them.
    function approve(address, uint256) public pure override {
        revert Soulbound();
    }

    /// @dev Soulbound: approvals are meaningless (transfers are blocked), so block them.
    function setApprovalForAll(address, bool) public pure override {
        revert Soulbound();
    }

    /// @notice On-chain SVG metadata (data URI). No external hosting.
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        string memory svg = _svg(tokenId);
        string memory json = string.concat(
            '{"name":"Agent ID Pioneer Badge #',
            tokenId.toString(),
            '","description":"A free, soulbound badge for Agent ID holders on BNB Chain. Minted only by wallets that hold an Agent ID (name.ai). Non-transferable, one per wallet.","image":"data:image/svg+xml;base64,',
            Base64.encode(bytes(svg)),
            '","attributes":[{"trait_type":"Soulbound","value":"Yes"},{"trait_type":"Agent ID Required","value":"Yes"},{"trait_type":"Chain","value":"BNB Chain"},{"trait_type":"Mint Price","value":"Free"}]}'
        );
        return string.concat("data:application/json;base64,", Base64.encode(bytes(json)));
    }

    /// @notice The badge artwork, generated on-chain.
    function _svg(uint256 tokenId) internal pure returns (string memory) {
        return string.concat(
            "<svg xmlns='http://www.w3.org/2000/svg' width='512' height='512' viewBox='0 0 512 512'>",
            "<defs><linearGradient id='g' x1='0' y1='0' x2='1' y2='1'>",
            "<stop offset='0' stop-color='#F0B90B'/><stop offset='1' stop-color='#1E1E2E'/>",
            "</linearGradient></defs>",
            "<rect width='512' height='512' rx='48' fill='url(#g)'/>",
            "<circle cx='256' cy='188' r='86' fill='none' stroke='#ffffff' stroke-width='10'/>",
            "<text x='256' y='212' font-family='sans-serif' font-size='72' font-weight='bold' fill='#ffffff' text-anchor='middle'>A</text>",
            "<text x='256' y='318' font-family='sans-serif' font-size='42' font-weight='bold' fill='#ffffff' text-anchor='middle'>PIONEER</text>",
            "<text x='256' y='362' font-family='sans-serif' font-size='22' fill='#F0B90B' text-anchor='middle'>AGENT ID BADGE</text>",
            "<text x='256' y='404' font-family='sans-serif' font-size='20' fill='#ffffff' text-anchor='middle'>BNB CHAIN</text>",
            "<text x='256' y='448' font-family='sans-serif' font-size='20' fill='#ffffff' text-anchor='middle'>#",
            tokenId.toString(),
            "</text></svg>"
        );
    }
}
