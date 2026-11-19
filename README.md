# Agent ID Pioneer Badge

A **free, soulbound (non-transferable) ERC-721 badge** on BNB Chain, mintable **only by wallets that hold an Agent ID** (`name.ai`).

Built for the **Binance Agent ID Hackathon** (submission period 18 Nov – 9 Dec 2026, 60,000 USDC in rewards).
Announcement: https://www.binance.com/en/support/announcement/detail/95f5dbe0ea674a48a739b59e046648bf

## What it is

Every Agent ID holder gets exactly **one** Pioneer Badge, free. The badge is an on-chain proof that you were an Agent ID pioneer — and because it is soulbound (non-transferable), it can never be sold or moved to another wallet, just like Agent ID itself.

- **Free mint** — the contract charges nothing. You only pay your own BSC gas.
- **Agent ID-gated** — `mint()` reads your Agent ID balance on-chain (`balanceOf` on the SPACE ID Agent ID contract) and reverts unless it is greater than zero.
- **1 per wallet** — each wallet holds at most one Agent ID, so one badge per wallet.
- **Soulbound** — all transfers and approvals revert. Only minting is allowed.
- **On-chain metadata** — the badge artwork is a clean SVG generated fully on-chain (no IPFS pinning, no external hosting, no fees).
- **Open source** — MIT licensed, source verified on BscScan after deployment.

## How Agent ID is used

The contract (`src/AgentIDPioneerBadge.sol`) stores the Agent ID contract address
(`0x60b9262456de011f7d15a54cdd8c48baaa8b022f`, SPACE ID Agent ID, ERC-721 on BNB Chain)
and, on every `mint()`, calls `balanceOf(msg.sender)` on it. Minting succeeds only when
the caller holds at least one Agent ID. The frontend does the same read before showing
the mint button, so non-holders are told up front that they need an Agent ID first.

Agent ID is used **only** as a holder check for the caller's own wallet. It is never used
to look up other people's wallets by name, and no Agent ID data is stored or shared.

## Try it

Website: https://Wahyupurnomoaji21.github.io/agent-id-pioneer-badge/ *(live after GitHub Pages is enabled; the contract address appears there once deployed)*

1. Connect your wallet (Binance Wallet or MetaMask) on BNB Chain (chain ID 56).
2. The page reads your Agent ID balance on-chain — no sign-in, no QR code, no session stored.
3. If you hold an Agent ID, press **“Mint your free Badge”** and confirm the transaction in your wallet.
4. One badge per wallet. Soulbound — it can never be transferred or sold.

> **Contract address: _TBD — deployment pending (deployer wallet needs a BNB top-up first)._**
> The address will be filled in here and in `docs/app.js` (`CONTRACT_ADDRESS`) right after deployment.

## Contract

- `src/AgentIDPioneerBadge.sol` — ERC-721 (`Agent ID Pioneer Badge`, symbol `AIPB`), OpenZeppelin.
- `mint()` — free (non-payable), requires Agent ID (`balanceOf > 0`), 1 per wallet.
- Soulbound — `_update` reverts for anything except minting; `approve` / `setApprovalForAll` also revert.
- `tokenURI()` — fully on-chain SVG metadata (data URI, base64 JSON + SVG).
- **Owner (deployer wallet) permissions — disclosed:** the owner can only call `setAgentId(address)` to point the contract at a new Agent ID contract address if Agent ID ever migrates. There is no mint tax, no pausing, no freezing, no withdrawal of user funds, and no other privileged function. The owner may `renounceOwnership()` to lock the contract permanently.

### Tests

```bash
forge test            # unit tests (mock Agent ID) + BSC fork test (real Agent ID contract)
```

The fork test deploys the badge against a BSC mainnet fork and verifies that the real
Agent ID holder wallet `0x6bf2…2A2c` (Agent ID #17256) can mint, while a random wallet cannot.

### Deploy (BSC mainnet)

Deployment is **not** done yet — the deployer wallet needs a BNB top-up first (it holds ~0.00000243 BNB, far below deployment gas). See [DEPLOY.md](DEPLOY.md) for the single-command deploy + BscScan verification steps.

```bash
# Dry run (simulation only, no BNB spent):
forge script script/Deploy.s.sol --rpc-url https://bsc-dataseed.bnbchain.org
```

## Hackathon submission

See [SUBMISSION.md](SUBMISSION.md) for the prepared submission materials (project name, website, contract address placeholder, Agent ID usage description). Nothing has been submitted to Binance yet — submission happens after deployment.

## Safety (hackathon red lines — all respected)

- No QR-code / pairing-code login, no storing user sessions.
- No bypassing user transaction confirmation — every mint is confirmed by the user in their own wallet.
- No unauthorized transfers, no unlimited approvals (the contract takes no approvals at all).
- Contracts open-source, owner permissions disclosed above.
- No Binance brand impersonation (the name is “Agent ID Pioneer Badge”, no Binance/BNB branding in the name).
- No collection of seed phrases, private keys, API secrets, or pairing codes.
- No promised returns — the badge is a free collectible, not an investment.
- No trading on this page, so no trading risk warning applies; the page states plainly that the mint is free except the user's own gas.

## License

MIT — see [LICENSE](LICENSE).
