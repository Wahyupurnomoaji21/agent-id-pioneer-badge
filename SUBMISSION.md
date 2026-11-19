# Binance Agent ID Hackathon — Submission Materials (prepared, NOT yet submitted)

> Nothing has been submitted to Binance yet. Submit only after the contract is deployed
> and the website is live (see DEPLOY.md steps 4–5). Submission period ends **9 Dec 2026 15:00 WIB**.

## Project name

**Agent ID Pioneer Badge**

## Website

https://Wahyupurnomoaji21.github.io/agent-id-pioneer-badge/

## Contract address(es)

**TBD — deployment pending.** Fill in after `forge script` deploy (BSC mainnet, chain ID 56).
Agent ID contract (used by the badge): `0x60b9262456de011f7d15a54cdd8c48baaa8b022f` (SPACE ID Agent ID, ERC-721).

## Agent ID usage description

Agent ID Pioneer Badge is a free, soulbound ERC-721 badge on BNB Chain that can only be
minted by wallets holding an Agent ID. The contract reads the caller's Agent ID balance
(`balanceOf`) on the SPACE ID Agent ID contract (0x60b9…22f) and only allows minting when
the balance is greater than zero, with one badge per wallet. The badge is non-transferable
(soulbound), mirroring Agent ID itself, and serves as an on-chain proof that the holder is
an Agent ID pioneer. Minting is free — the contract charges nothing and the user only pays
their own BSC gas. The frontend connects through the user's own wallet (Binance Wallet or
MetaMask), reads the Agent ID balance on-chain before showing the mint button, and every
mint is confirmed by the user in their own wallet; there is no QR-code login, no stored
session, and no bypass of transaction confirmation.

## Awards targeted

- **Innovation Award** (judging panel, top 10; 1st 10,000 USDC) — a genuinely new Agent ID
  use case: a soulbound proof-of-pioneer badge, the first badge that can only be minted by
  Agent ID holders. Eligibility: product live, ≥30 Agent ID addresses interacting with the
  contract during the Submission Period.
- **Ecosystem Growth Award** (on-chain metrics, top 10; 1st 10,000 USDC) — every mint is an
  Agent ID-gated on-chain interaction, so growth in minters directly grows Agent ID usage.

Each project may receive only one award. Winners additionally receive one eligibility spot
to claim a two-digit Agent ID.

## Submission checklist

- [ ] Contract deployed to BSC mainnet (see DEPLOY.md)
- [ ] Source verified + open-sourced on BscScan
- [ ] `CONTRACT_ADDRESS` filled into `docs/app.js`, README, and this file
- [ ] GitHub Pages live and the mint flow tested end-to-end from the deployer wallet
- [ ] ≥30 Agent ID holders have minted (Innovation Award eligibility) — promote the page
- [ ] Submit project name, website, contract address(es), and the Agent ID usage description
      above via the hackathon submission form during the Submission Period (ends 9 Dec 2026 15:00 WIB)
