# 【IN PROGRESS】ZK attestation for `Job Career History` and `Skills`

## Tech Stack

- `ZK circuit`: Implemented in [`Noir`](https://noir-lang.org/docs/) powered by [Aztec](https://aztec.network/)
- Smart Contract: Implemented in Solidity (Framework: Foundry)
- Blockchain: [`Pharos`](https://docs.pharosnetwork.xyz/developer-guides/pharos-devnet-onboarding-guide#rpc-endpoint) (Devnet)

<br>

## Overview

- This is the Zero-Knowledge (ZK) based job career history and skills attestation protocol, which enable a candidate to prove their job career history and skills without disclosing the sensitive informations.

- This protocol is also useful for a recruiter and a company-hiring to prevent a malicious candidate from submitting a CV / Resume, which includes a "fake" career history (i.e. Job Title, etc) & "fake" skills, by using a generative AI. 


<br>

## Userflow

<br>

## Diagram of Userflow


<br>

## Deployed-smart contracts on [`Pharos`](https://docs.pharosnetwork.xyz/developer-guides/pharos-devnet-onboarding-guide#rpc-endpoint) (Devnet)

| Contract Name | Descripttion | Deployed-contract addresses on `Pharos` (Testnet) | Contract Source Code Verified |
| ------------- |:------------:|:--------------------------------------------------:|:-----------------------------:|
| UltraVerifier | The UltraPlonk Verifer contract (`./contracts/circuit/ultra-verifier/plonk_vk.sol`), which is generated based on ZK circuit in Noir (`./circuits/src/main.nr`). FYI: To generated this contract, the way of the [Noir's Solidity Verifier generation](https://noir-lang.org/docs/how_to/how-to-solidity-verifier) was used. | [0x2317106a73E00fc66AB25aD50979CFf140075b2b](https://pharosscan.xyz/address/0x2317106a73E00fc66AB25aD50979CFf140075b2b) | Yet |
| JobTitlesAndSkillsProofVerifier | The JobTitlesAndSkillsProofVerifier contract, which the validation using the UltraVerifier contract is implemented | [0x7a2E68d1d1bB79dBc945801A02Bd6e17d0842457](https://pharosscan.xyz/address/0x7a2E68d1d1bB79dBc945801A02Bd6e17d0842457) | Yet |

<br>

## Installation - Noir and Foundry

Install [noirup](https://noir-lang.org/docs/getting_started/noir_installation) with

1. Install [noirup](https://noir-lang.org/docs/getting_started/noir_installation):

   ```bash
   curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
   ```

2. Install Nargo:

   ```bash
   noirup
   ```

3. Install foundryup and follow the instructions on screen. You should then have all the foundry
   tools like `forge`, `cast`, `anvil` and `chisel`.

```bash
curl -L https://foundry.paradigm.xyz | bash
```

4. Install foundry dependencies by running `forge install 0xnonso/foundry-noir-helper --no-commit`.

5. Install `bbup`, the tool for managing Barretenberg versions, by following the instructions
   [here](https://github.com/AztecProtocol/aztec-packages/blob/master/barretenberg/bbup/README.md#installation).

6. Then run `bbup`.

<br>

## ZK circuit - Test

```bash
cd circuits
sh circuit_test.sh
```

<br>

## SC - Script
- Install `npm` modules - if it's first time to run this script. (From the second time, this installation step can be skipped):
```bash
cd script/utils/poseidon2-hash-generator
npm i
```

- Run the `Verify.s.sol` on the Local Network
```bash
sh ./scripts/runningScript_Verify.sh
```

- Run the `Verify_onPharosTestnet.s.sol` on Pharos (Devnet)
```bash
sh ./scripts/pharos-testnet/runningScript_Verify_onPharosTestnet.sh
```

- NOTE: The ProofConverter#`sliceAfter96Bytes()` would be used in the both script file above.
  - The reason is that the number of public inputs is `3` (`bytes32 * 3 = 96 bytes`), meaning that the proof file includes `96 bytes` of the public inputs **at the beginning**. 
     - Hence it should be removed by using the `sliceAfter96Bytes()` 


<br>

## SC - Test
- Run the `JobTitlesAndSkillsProofVerifier.t.sol` on Local Network
```bash
sh ./test/circuit/runningTest_JobTitlesAndSkillsProofVerifier.sh
```

- Run the `JobTitlesAndSkillsProofVerifier_onPharosTestnet.t.sol` on Pharos (Devnet)
```bash
sh ./test/pharos-testnet/circuit/runningTest_JobTitlesAndSkillsProofVerifier_onPharosTestnet.sh
```


<br>

## Deployment
- Run the `DeploymentAllContracts.s.sol`
```bash
sh ./scripts/pharos-testnet/deployment/deploymentScript_AllContracts.sh
```

<br>

## References

- Noir:
  - Doc: https://noir-lang.org/docs/getting_started/quick_start

<br>

- Pharos: https://www.hackquest.io/hackathons/Pharos-Builder-Base-Camp
  - Pharos - Foundry ：https://docs.pharosnetwork.xyz/developer-guides/foundry
  - Pharos - SC in Rust /w Arbitrum's stylus_sdk & alloy：https://docs.pharosnetwork.xyz/developer-guides/rust/write-your-first-token
  - Network Info：https://docs.pharosnetwork.xyz/developer-guides/pharos-devnet-onboarding-guide#rpc-endpoint
  - Block Explorer (BlockScout) on Pharos Testnet: https://pharosscan.xyz/  
  - Fancet - To obtain Testnet ETH to pay for gas ⛽️ on Pharos Testnet (Devnet) 
    https://www.hackquest.io/faucets/50002