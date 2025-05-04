# ZK (Zero-Knowledge) attestation for `Job Career History`

## Tech Stack

- `ZK circuit`: Implemented in [`Noir`](https://noir-lang.org/docs/) powered by [Aztec](https://aztec.network/)
- Smart Contract: Implemented in Solidity (Framework: Foundry)
- Blockchain: [`Pharos`](https://docs.pharosnetwork.xyz/developer-guides/pharos-devnet-onboarding-guide#rpc-endpoint) (Devnet)

<br>

## Overview

- In the Job matching market, a CV/Resume has histrically been used.
  - However, due to lack of validation method for recruiters and staff of HR department in companies to validate the `Job Carreer History` (i.e. `Job Title` and `Skills`), which is written in CV/Resume, malicious candidates can write a **fake** `Job Carreer History` in their CV/Resume. This is the problem of the **fake** CV/Resume in Job matching market.
  - This cause recruiters and staff of HR department in companies to misunderstand these malicious candidates, who submit a CV/Resume that includes fake `Job Carreer History`. In the worst case, these staff of HR department (or management team) in companies wrongly decide to hire these malicious candidates and this cause to mismatch and waste the cost and time to hire these malicious candidates.

- This is where the **ZK (Zero-Knowledge) attestation for Job Career History** comes in. 
  - This protocol would enable to recruiters and HR staff of companies can send a job offer to a candidate without checking additional evidences (i.e. Employment offer letter, Diploma, Certificates, etc). This lead to being able to prevent malicious candidates from submitting their CV/Resume, which includes a **fake** Job Career History (i.e. `Job Title` and `Skills` etc).

  - This protocol would also enable a candidate to prove their Job Career History without submitting additional evidences, which may includes some sensitive informations.

  - As we mentioned above, at the moment, this protocol would particulary focus on `Job Title` and `Skills` in the `Job Career History`. And therefore, the ZK circuit of this protocol will generate a ZK Proof, which prove `Job Title` and `Skills` as a proof of `Job Career History`.

<br>

## Userflow

- 1/ A candidate would send the **input data**, which includes Job Career History data (icl. `Job Title` and `Skills`) to the **ZK circuit**-written in `Noir`.
- 2/ A new **ZK (Zero-Knowledge) Proof** would be generated via **ZK circuit** and then the candidate would receive it /w **public inputs** (by downloading them in the form of a plain text file).
   - NOTE: This *public inputs* would includes only data, which can be disclosed as a public data. (The sensitive data is **not** included)
- 3/ The candidate would call the `submitJobCareerHistoryProof()` in the `JobMatchingPlatform.sol` with a `ZK Proof` of Job Career History and `public inputs`.
- 4/ The `JobMatchingPlatform.sol` would call the `verify()` in the `UltraVerifier.sol` via the `verifyJobTitlesAndSkillsProofVerifier()` in the `JobTitlesAndSkillsProofVerifier.sol` in order to validate whether or not a given `ZK Proof` of Job Career History is a valid proof.
  - Then, the `verify()` in the `UltraVerifier.sol` would return the result of validation to the `JobMatchingPlatform.sol` via the `verifyJobTitlesAndSkillsProofVerifier()` in the `JobTitlesAndSkillsProofVerifier.sol`.

- 5/ If the result (return value) of ZK proof (icl. public inputs) validation from the step 4/ above would be `true`, the ZK Proof of Job Career History-submitted by the candidate will be saved in the `JobMatchingPlatform.sol`.

- 6/ A recruiter or HR staff of company would send a job offer to the candidate based on that the ZK Proof of Job Career History-submitted by the candidate has already been saved in the `JobMatchingPlatform.sol`.

<br>

## Diagram of Architecture (Userflow)

- Diagram of Architecture (Userflow): https://github.com/masaun/ZK-attestation-for-job-career-history/blob/main/doc/diagram/diagram_ZK-attestation-for-job-career-history.jpg

- NOTE: 
  - The `JobMatchingPlatform.sol` (icl. `submitJobCareerHistoryProof()`) in the diagram above is an example smart contract. (Not implemented yet)
  - Any project, which hope to integrate the `JobTitlesAndSkillsProofVerifier.sol`, can freely implement an **custom contract** like `JobMatchingPlatform.sol` in the diagram above that handle a insurance payout

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

4. Install foundry dependencies
```bash
forge install 0xnonso/foundry-noir-helper --no-commit
```

5. Install `bbup`, the tool for managing Barretenberg versions, by following the instructions
   [here](https://github.com/AztecProtocol/aztec-packages/blob/master/barretenberg/bbup/README.md#installation).

6. Then run `bbup`.

<br>

## Set the environment file (`env`)

- Create the `env` file:
  - Then, please add a `<Private Key>` of your wallet address to the `"PHAROS_TESTNET_PRIVATE_KEY"` in the `.env`.
```bash
cp .env.example .env
```

<br>

## ZK circuit - Test

- Run the test of the ZK circuit (`./circuits/src/tests/mod.nr`) via the `./circuits/circuit_test.sh`:
```bash
cd circuits
sh circuit_test.sh
```

<br>

## ZK circuit - Generate a ZKP (Zero-Knowledge Proof)

- Create the `Prover.toml` by copying the `Prover.example.toml`. Then, appropreate values should be stored into there.
```bash
cd circuits
cp Prover.example.toml Prover.toml
```

- Run the ZK circuit (`./circuits/src/main.nr`) via the `./circuits/build.sh` to generate a ZKP (Zero-Knowledge Proof), which is called a `job_titles_and_skills_proof` proof:
```bash
cd circuits
sh build.sh
```

<br>

## Smart Contract - Compile
- Compile the smart contracts:
```bash
sh buildContract.sh
```

<br>

## Smart Contract - Script

- Install `npm` modules - if it's first time to run this script. (From the second time, this installation step can be skipped):
```bash
cd script/utils/poseidon2-hash-generator
npm i
```

- Run the `Verify.s.sol` on the *Local Network*
```bash
sh ./scripts/runningScript_Verify.sh
```

- Run the `Verify_onPharosTestnet.s.sol` on `Pharos (Devnet)`
```bash
sh ./scripts/pharos-testnet/runningScript_Verify_onPharosTestnet.sh
```

- NOTE: The ProofConverter#`sliceAfter96Bytes()` would be used in the both script file above.
  - The reason is that the number of public inputs is `3` (`bytes32 * 3 = 96 bytes`), meaning that the proof file includes `96 bytes` of the public inputs **at the beginning**. 
     - Hence it should be removed by using the `sliceAfter96Bytes()` 


<br>

## Smart Contract - Test
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
- Run the `DeploymentAllContracts.s.sol` to deploy the `UltraVerifier` contract and the `JobTitlesAndSkillsProofVerifier` contract on Pharos (Devnet):
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

<br>

- Node.js:  
  - How to run a Typescript (Node.js) file in shell script: https://nodejs.org/en/learn/typescript/run#running-typescript-with-a-runner