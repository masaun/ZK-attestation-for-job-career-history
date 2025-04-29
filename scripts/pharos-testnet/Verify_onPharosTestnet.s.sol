pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
import "forge-std/console.sol";

import { JobTitlesAndSkillsProofVerifier } from "../../contracts/circuit/JobTitlesAndSkillsProofVerifier.sol";
import { UltraVerifier } from "../../contracts/circuit/ultra-verifier/plonk_vk.sol"; /// @dev - Deployed-Verifier SC, which was generated based on the main.nr
//import { UltraVerifier } from "../../circuits/target/contract.sol";
import { ProofConverter } from "../utils/ProofConverter.sol";
import { GetTestPublicInputsData } from "../test-data/GetTestPublicInputsData.sol";

import { DataTypeConverter } from "../../contracts/libraries/DataTypeConverter.sol";

/**
 * @notice - Verify the insurance claim proof on Pharos Testnet
 */
contract VerifyScript is Script, GetTestPublicInputsData {
    JobTitlesAndSkillsProofVerifier public jobTitlesAndSkillsProofVerifier;
    UltraVerifier public verifier;

    // struct PublicInputs {
    //     bytes32 merkle_root; // root
    //     bytes32 nullifier;    
    //     bytes32 nullifier_in_revealed_data_struct; // Same with the "nullifier"
    //     bytes32 is_bill_signed;                    // "0": False <-> "1": True
    //     bytes32 is_bill_amount_exceed_threshold;   // "0": False <-> "1": True
    //     bytes32 is_policy_valid;                   // "0": False <-> "1": True
    // }

    function setUp() public {
        uint256 deployerPrivateKey = vm.envUint("PHAROS_TESTNET_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        /// @dev - Read the each deployed address from the configuration file.
        address ULTRAVERIFER = vm.envAddress("ULTRAVERIFER_ON_PHAROS_TESTNET");
        address JOB_TITLES_AND_SKILLS_PROOF_VERIFIER = vm.envAddress("JOB_TITLES_AND_SKILLS_PROOF_VERIFIER_ON_PHAROS_TESTNET");

        /// @dev - Create the SC instances /w deployed SC addresses
        verifier = UltraVerifier(ULTRAVERIFER);
        jobTitlesAndSkillsProofVerifier = JobTitlesAndSkillsProofVerifier(JOB_TITLES_AND_SKILLS_PROOF_VERIFIER);
        //verifier = new UltraVerifier();
        //jobTitlesAndSkillsProofVerifier = new JobTitlesAndSkillsProofVerifier(verifier);
    }

    function run() public returns (bool) {
        // @dev - Retrieve the public inputs, which was read from the testPublicInputsData.json file
        GetTestPublicInputsData.PublicInputs memory publicInputs = getTestPublicInputsData();
        bytes32 merkleRoot = publicInputs.merkleRoot;
        bytes32 nullifier = publicInputs.nullifier;
        bytes32 jobTitleCommitment = publicInputs.jobTitleCommitment;
        bytes32 skillsCombinedCommitment = publicInputs.skillsCombinedCommitment;
        console.logBytes32(merkleRoot);
        console.logBytes32(nullifier);
        console.logBytes32(jobTitleCommitment);
        console.logBytes32(skillsCombinedCommitment);

        bytes memory proof_w_inputs = vm.readFileBinary("./circuits/target/job_titles_and_skills_proof.bin");
        bytes memory proofBytes = ProofConverter.sliceAfter128Bytes(proof_w_inputs);    /// @dev - In case of that there are 4s public inputs (bytes32 * 4 = 128 bytes), the proof file includes 128 bytes of the public inputs at the beginning. Hence it should be removed by using this function.
        //bytes memory proofBytes = ProofConverter.sliceAfter96Bytes(proof_w_inputs);    /// @dev - In case of that there are 3 public inputs (bytes32 * 3 = 96 bytes), the proof file includes 96 bytes of the public inputs at the beginning. Hence it should be removed by using this function.
        //bytes memory proofBytes = ProofConverter.sliceAfter64Bytes(proof_w_inputs);  /// @dev - In case of that there are 2 public inputs (bytes32 * 2 = 64 bytes), the proof file includes 64 bytes of the public inputs at the beginning. Hence it should be removed by using this function.

        // string memory proof = vm.readLine("./circuits/target/ip_nft_ownership_proof.bin");
        // bytes memory proofBytes = vm.parseBytes(proof);

        bytes32[] memory correctPublicInputs = new bytes32[](4);
        correctPublicInputs[0] = merkleRoot;
        correctPublicInputs[1] = nullifier;
        correctPublicInputs[2] = jobTitleCommitment;
        correctPublicInputs[3] = skillsCombinedCommitment;

        bool isValidProof = jobTitlesAndSkillsProofVerifier.verifyJobTitlesAndSkillsProofVerifier(proofBytes, correctPublicInputs);
        require(isValidProof == true, "isValidProof should be true");
        console.logBool(isValidProof); // [Log]: true
        return isValidProof;
    }
}