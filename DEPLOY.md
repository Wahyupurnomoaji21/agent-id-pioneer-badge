# Deploy — Agent ID Pioneer Badge (BSC mainnet)

> **Status: NOT DEPLOYED.** The deployer wallet `0x6bf297a8f7eb457C01c750a60507C366A2892A2c`
> holds ~0.00000243 BNB — far below deployment gas. **Top up the wallet first** (0.02–0.05 BNB is
> plenty for deploy + verification + a test mint), then run the single command below.
> Do **not** deploy until the wallet is funded and you have explicitly confirmed.

## 1. Fund the deployer wallet

Send **0.02–0.05 BNB** to `0x6bf297a8f7eb457C01c750a60507C366A2892A2c` (the Agent ID #17256 wallet).
Verify the balance first:

```bash
cast balance 0x6bf297a8f7eb457C01c750a60507C366A2892A2c --rpc-url https://bsc-dataseed.bnbchain.org
```

## 2. Set up credentials (never commit these)

Create a `.env` file in the repo root (it is git-ignored):

```bash
PRIVATE_KEY=<deployer private key, 0x-prefixed — never share it, never paste it in chat>
BSCSCAN_API_KEY=<BscScan API key for source verification>
```

Then load it: `set -a; source .env; set +a`

> Prefer Foundry's encrypted keystore instead of a raw key where possible:
> `cast wallet import deployer --interactive`, then use `--account deployer` in place of `--private-key $PRIVATE_KEY`.

## 3. Dry run (simulation — no BNB spent)

```bash
forge script script/Deploy.s.sol --rpc-url https://bsc-dataseed.bnbchain.org
```

Confirm the simulation succeeds and note the estimated gas.

## 4. Deploy + verify (single command)

```bash
forge script script/Deploy.s.sol \
  --rpc-url https://bsc-dataseed.bnbchain.org \
  --broadcast --private-key $PRIVATE_KEY \
  --verify --etherscan-api-key $BSCSCAN_API_KEY
```

The script prints the deployed address, e.g. `AgentIDPioneerBadge deployed at: 0x...`.
If `--verify` fails, verify manually afterwards:

```bash
forge verify-contract <DEPLOYED_ADDRESS> src/AgentIDPioneerBadge.sol:AgentIDPioneerBadge \
  --chain 56 --etherscan-api-key $BSCSCAN_API_KEY \
  --constructor-args $(cast abi-encode "constructor(address)" 0x60b9262456de011f7d15a54cdd8c48baaa8b022f)
```

## 5. After deployment (do these before submitting to Binance)

1. Fill the deployed address into `README.md` (the “Contract address: TBD” line), `SUBMISSION.md`,
   and `docs/app.js` (`CONTRACT_ADDRESS`).
2. Commit + push, and confirm GitHub Pages serves the updated frontend.
3. Test-mint once from the deployer wallet (it holds Agent ID #17256) on the live site and
   confirm the badge appears on BscScan (`https://bscscan.com/token/<ADDRESS>`).
4. Optionally `renounceOwnership()` from the deployer wallet to lock the contract permanently
   (the owner can only `setAgentId` otherwise; renouncing removes even that).
5. Promote the mint page to Agent ID holders — the Innovation Award requires the product live
   with **at least 30 Agent ID addresses** having interacted with the contract during the
   Submission Period (ends 9 Dec 2026 15:00 WIB).

## Estimated gas (measured 19 Nov 2026, dry run on BSC mainnet)

- **Deployment: 3,806,562 gas.** At the simulated 0.05 gwei that is 0.0001903281 BNB;
  at realistic BSC gas prices (1–5 gwei) it is **~0.004–0.02 BNB**. A 0.02–0.05 BNB top-up
  covers deploy + verification + a test mint comfortably.
- **`mint()` call: ~148k gas** (measured in Foundry tests; ~150k on mainnet with the real
  Agent ID `balanceOf` call). At 3 gwei that is ~0.00045 BNB per mint.
- Contract size: 14,386 bytes deployed (under the 24,576-byte limit).
