echo "Load the environment variables from the .env file..."
#source .env
. ./.env

echo "Verifying a proof via the InsuranceClaimProofVerifier (icl. UltraVerifier) contract on Pharos Testnet..."
forge script scripts/pharos-testnet/Verify_onPharosTestnet.s.sol --broadcast --private-key ${PHAROS_TESTNET_PRIVATE_KEY} --rpc-url ${PHAROS_TESTNET_RPC} --skip-simulation
