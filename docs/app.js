// Agent ID Pioneer Badge — frontend (static, no backend, no session storage).
// Connects via the user's own wallet (Binance Wallet / MetaMask) and never
// bypasses transaction confirmation. The user confirms every transaction
// themselves in their wallet. No QR code / pairing-code login anywhere.

// ---- Config: update CONTRACT_ADDRESS after deployment (see DEPLOY.md). ----
const CONTRACT_ADDRESS = "0x0000000000000000000000000000000000000000"; // TODO: deployed badge address
const AGENT_ID_ADDRESS = "0x60b9262456de011f7d15a54cdd8c48baaa8b022f"; // SPACE ID Agent ID (BNB Chain)
const BSC_CHAIN_ID = 56n;
const BSC_CHAIN_HEX = "0x38";

const AGENT_ID_ABI = ["function balanceOf(address owner) view returns (uint256)"];
const BADGE_ABI = [
  "function mint()",
  "function balanceOf(address owner) view returns (uint256)",
  "function hasMinted(address owner) view returns (bool)",
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function tokenURI(uint256 tokenId) view returns (string)",
];

const $ = (id) => document.getElementById(id);
const logEl = $("log");
let provider = null;
let signer = null;
let userAddress = null;
let badge = null;

function log(msg) {
  logEl.textContent = msg;
  console.log(msg);
}

function short(addr) {
  return addr ? addr.slice(0, 6) + "…" + addr.slice(-4) : "—";
}

async function refreshStatus() {
  if (!provider || !userAddress) return;
  try {
    const net = await provider.getNetwork();
    $("network").textContent = net.chainId === BSC_CHAIN_ID
      ? "BNB Chain (56) ✓"
      : `Wrong network (${net.chainId}) — please switch to BNB Chain`;
    const agentId = new ethers.Contract(AGENT_ID_ADDRESS, AGENT_ID_ABI, provider);
    const bal = await agentId.balanceOf(userAddress);
    $("agentid").textContent = bal > 0n ? `Yes (${bal}) ✓` : "No — you need an Agent ID to mint";
    $("agentid").className = "v " + (bal > 0n ? "ok" : "bad");

    if (CONTRACT_ADDRESS === "0x0000000000000000000000000000000000000000") {
      $("contract").textContent = "Not deployed yet";
      $("contract2").textContent = "not deployed yet — address will appear here after deployment";
      $("badge").textContent = "—";
      $("mintBtn").disabled = true;
      $("mintBtn").textContent = "Mint your free Badge (contract not deployed yet)";
      return;
    }

    $("contract").textContent = short(CONTRACT_ADDRESS);
    $("contract2").textContent = CONTRACT_ADDRESS;
    badge = new ethers.Contract(CONTRACT_ADDRESS, BADGE_ABI, provider);
    const hasMinted = await badge.hasMinted(userAddress);
    const badgeBal = await badge.balanceOf(userAddress);
    $("badge").textContent = badgeBal > 0n ? `Yes (${badgeBal})` : "Not yet";
    $("badge").className = "v " + (badgeBal > 0n ? "ok" : "");

    const okChain = net.chainId === BSC_CHAIN_ID;
    if (hasMinted) {
      $("mintBtn").disabled = true;
      $("mintBtn").textContent = "You already minted your Badge ✓";
    } else if (bal === 0n) {
      $("mintBtn").disabled = true;
      $("mintBtn").textContent = "Mint your free Badge (requires an Agent ID)";
    } else if (!okChain) {
      $("mintBtn").disabled = true;
      $("mintBtn").textContent = "Mint your free Badge (switch to BNB Chain first)";
    } else {
      $("mintBtn").disabled = false;
      $("mintBtn").textContent = "Mint your free Badge";
    }
  } catch (e) {
    log("Could not read on-chain status: " + (e && e.message ? e.message : e));
  }
}

async function connect() {
  if (!window.ethereum) {
    log("No wallet found. Install Binance Wallet or MetaMask, then refresh this page.");
    return;
  }
  try {
    log("Requesting wallet connection…");
    provider = new ethers.BrowserProvider(window.ethereum);
    const accounts = await provider.send("eth_requestAccounts", []);
    signer = await provider.getSigner();
    userAddress = accounts[0] || (await signer.getAddress());
    $("wallet").textContent = short(userAddress);
    $("connectBtn").textContent = "Connected: " + short(userAddress);

    // Switch to BNB Chain if needed (user confirms the switch in their wallet).
    const net = await provider.getNetwork();
    if (net.chainId !== BSC_CHAIN_ID) {
      log("Switching to BNB Chain — please confirm the network switch in your wallet…");
      try {
        await window.ethereum.request({
          method: "wallet_switchEthereumChain",
          params: [{ chainId: BSC_CHAIN_HEX }],
        });
        provider = new ethers.BrowserProvider(window.ethereum);
        signer = await provider.getSigner();
      } catch (e) {
        log("Could not switch network: " + (e && e.message ? e.message : e)
          + ". Please switch to BNB Chain (chain ID 56) in your wallet and refresh.");
      }
    }
    log("Connected as " + userAddress + ". Reading your Agent ID status…");
    await refreshStatus();
    log("Ready. " + ($("agentid").textContent.startsWith("Yes")
      ? "You hold an Agent ID — you can mint your free Badge."
      : "You do not hold an Agent ID yet. Claim one in the Binance App (Wallet > Agent ID), then come back."));
  } catch (e) {
    log("Connection failed: " + (e && e.message ? e.message : e));
  }
}

async function mint() {
  if (!signer || !userAddress) { log("Connect your wallet first."); return; }
  if (CONTRACT_ADDRESS === "0x0000000000000000000000000000000000000000") {
    log("The badge contract is not deployed yet. Deployment is pending — check back soon.");
    return;
  }
  try {
    const badgeWithSigner = new ethers.Contract(CONTRACT_ADDRESS, BADGE_ABI, signer);
    log("Sending mint transaction — please confirm it in your wallet…");
    const tx = await badgeWithSigner.mint();
    log("Transaction sent: " + tx.hash + "\nWaiting for confirmation…\nhttps://bscscan.com/tx/" + tx.hash);
    const receipt = await tx.wait();
    if (receipt.status === 1) {
      log("✓ Badge minted! Transaction confirmed.\nhttps://bscscan.com/tx/" + tx.hash
        + "\nYour badge is soulbound (non-transferable) and will show in your wallet.");
      await refreshStatus();
    } else {
      log("Transaction failed on-chain. See https://bscscan.com/tx/" + tx.hash);
    }
  } catch (e) {
    const msg = (e && e.message) ? e.message : String(e);
    if (/user rejected|User denied/i.test(msg)) {
      log("You declined the transaction in your wallet. Nothing was minted.");
    } else if (/NotAgentIDHolder/i.test(msg)) {
      log("Mint reverted: this wallet does not hold an Agent ID.");
    } else if (/AlreadyMinted/i.test(msg)) {
      log("Mint reverted: this wallet already minted its one badge.");
    } else {
      log("Mint failed: " + msg);
    }
  }
}

$("connectBtn").addEventListener("click", connect);
$("mintBtn").addEventListener("click", mint);

// Refresh status if the user changes account/network in their wallet.
if (window.ethereum) {
  window.ethereum.on("accountsChanged", () => location.reload());
  window.ethereum.on("chainChanged", () => location.reload());
}
