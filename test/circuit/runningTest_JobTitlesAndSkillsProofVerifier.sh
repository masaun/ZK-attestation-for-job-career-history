echo "Cleaning up temporary directories..."
rm -rf ../../__tmp__test_verifyProof

echo "Ensure temporary directories exist..."
mkdir -p ../__tmp__test_verifyProof

######################################################################


echo "Load the environment variables from the .env file..."
source .env
#. ./.env

echo "Running the test of the JobTitlesAndSkillsProofVerifierTest..."
forge test --optimize --optimizer-runs 5000 --evm-version cancun --match-contract JobTitlesAndSkillsProofVerifierTest -vvv
