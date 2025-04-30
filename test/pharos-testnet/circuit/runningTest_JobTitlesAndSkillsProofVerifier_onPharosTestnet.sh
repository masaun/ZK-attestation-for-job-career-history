echo "Load the environment variables from the .env file..."
source .env
#. ./.env

echo "Running the test of the JobTitlesAndSkillsProofVerifier contract on Pharos Testnet..."
forge test --optimize --optimizer-runs 5000 --evm-version cancun --match-contract JobTitlesAndSkillsProofVerifierTest_OnPharosTestnet --rpc-url ${PHAROS_TESTNET_RPC} -vvv
