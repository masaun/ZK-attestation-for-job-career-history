echo "Load the environment variables from the .env file..."
. ./.env

echo "Deploying the smart contracts (icl. UltraVerifier, JobTitlesAndSkillsProofVerifier) on Pharos Testnet..."
forge script scripts/pharos-testnet/deployment/DeploymentAllContracts.s.sol \
    --broadcast \
    --rpc-url ${PHAROS_TESTNET_RPC} \
    --chain-id ${PHAROS_TESTNET_CHAIN_ID} \
    --private-key ${PHAROS_TESTNET_PRIVATE_KEY} \
    ./contracts/circuit/ultra-verifier/plonk_vk.sol:UltraVerifier \
    ./contracts/circuit/JobTitlesAndSkillsProofVerifier.sol:JobTitlesAndSkillsProofVerifier \
    --skip-simulation

echo "Verify the deployed-smart contracts (icl. UltraVerifier, JobTitlesAndSkillsProofVerifier) on Pharos Testnet Explorer..."
forge script scripts/pharos-testnet/deployment/DeploymentAllContracts.s.sol \
    --rpc-url ${PHAROS_TESTNET_RPC} \
    --chain-id ${PHAROS_TESTNET_CHAIN_ID} \
    --private-key ${PHAROS_TESTNET_PRIVATE_KEY} \
    --resume \
    --verify \
    --verifier blockscout \
    --verifier-url https://pharosscan.xyz/