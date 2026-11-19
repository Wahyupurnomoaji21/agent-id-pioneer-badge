// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {AgentIDPioneerBadge} from "../src/AgentIDPioneerBadge.sol";

/// @notice Deploys AgentIDPioneerBadge to BSC mainnet.
/// @dev DO NOT run with --broadcast until the deployer wallet is funded (see DEPLOY.md).
///      Dry run (no broadcast, no BNB spent):
///        forge script script/Deploy.s.sol --rpc-url https://bsc-dataseed.bnbchain.org
///      Deploy (needs a funded deployer key in $PRIVATE_KEY):
///        forge script script/Deploy.s.sol --rpc-url https://bsc-dataseed.bnbchain.org --broadcast
///        --verify --etherscan-api-key $BSCSCAN_API_KEY
contract Deploy is Script {
    /// @notice SPACE ID Agent ID contract on BNB Chain (ERC-721, non-transferable).
    address internal constant AGENT_ID = 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;

    function run() external returns (AgentIDPioneerBadge badge) {
        vm.startBroadcast();
        badge = new AgentIDPioneerBadge(AGENT_ID);
        vm.stopBroadcast();

        console.log("AgentIDPioneerBadge deployed at:", address(badge));
        console.log("Agent ID contract:", AGENT_ID);
        console.log("Owner (deployer):", badge.owner());
    }
}
