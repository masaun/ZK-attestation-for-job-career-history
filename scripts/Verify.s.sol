pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
import "forge-std/console.sol";

import { UltraVerifier } from "../contracts/circuit/ultra-verifier/plonk_vk.sol";
//import "../circuits/target/contract.sol";
import { JobTitlesAndSkillsProofVerifier } from "../contracts/circuit/JobTitlesAndSkillsProofVerifier.sol";
import { ProofConverter } from "./utils/ProofConverter.sol";
import { GetTestPublicInputsData } from "./test-data/GetTestPublicInputsData.sol";

import { DataTypeConverter } from "../../contracts/libraries/DataTypeConverter.sol";


contract VerifyScript is Script, GetTestPublicInputsData {
    JobTitlesAndSkillsProofVerifier public jobTitlesAndSkillsProofVerifier;
    UltraVerifier public verifier;

    // struct PublicInputs {
    //     bytes32 merkleRoot;
    //     bytes32 nullifier;
    //     bytes32 jobTitleCommitment;
    //     bytes32 skillsCombinedCommitment;
    // }

    function setUp() public {
        verifier = new UltraVerifier();
        jobTitlesAndSkillsProofVerifier = new JobTitlesAndSkillsProofVerifier(verifier);
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

    /**
     * @dev - Compute Poseidon2 hash
     */
    // function computePoseidon2Hash() public returns (Poseidon2HashAndPublicInputs memory _poseidon2HashAndPublicInputs) {
    //     /// @dev - Run the Poseidon2 hash generator script
    //     string[] memory ffi_commands_for_generating_poseidon2_hash = new string[](2);
    //     ffi_commands_for_generating_poseidon2_hash[0] = "sh";
    //     ffi_commands_for_generating_poseidon2_hash[1] = "scripts/utils/poseidon2-hash-generator/usages/async/runningScript_poseidon2HashGeneratorWithAsync.sh";
    //     bytes memory commandResponse = vm.ffi(ffi_commands_for_generating_poseidon2_hash);
    //     console.log(string(commandResponse));

    //     /// @dev - Write the output.json of the Poseidon2 hash-generated and Read the 'hash' field from the output.json
    //     string[] memory ffi_commands_for_generating_output_json = new string[](3);
    //     ffi_commands_for_generating_output_json[0] = "sh";
    //     ffi_commands_for_generating_output_json[1] = "-c";
    //     ffi_commands_for_generating_output_json[2] = "cat scripts/utils/poseidon2-hash-generator/usages/async/output/output.json | grep 'hash' | awk -F '\"' '{print $4}'"; // Extracts the 'hash' field

    //     bytes memory poseidon2HashBytes = vm.ffi(ffi_commands_for_generating_output_json);
    //     //console.logBytes(poseidon2HashBytes);

    //     /// @dev - Read the output.json file and parse the JSON data
    //     string memory json = vm.readFile("scripts/utils/poseidon2-hash-generator/usages/async/output/output.json");
    //     console.log(json);
    //     bytes memory data = vm.parseJson(json);
    //     //console.logBytes(data);

    //     string memory _hash = vm.parseJsonString(json, ".hash");
    //     bytes32 _merkleRoot = vm.parseJsonBytes32(json, ".merkleRoot");
    //     bytes32 _nullifier = vm.parseJsonBytes32(json, ".nullifier");
    //     bytes32 _nftMetadataCidHash = vm.parseJsonBytes32(json, ".nftMetadataCidHash");
    //     console.logString(_hash);
    //     console.logBytes32(_merkleRoot);
    //     console.logBytes32(_nullifier);
    //     console.logBytes32(_nftMetadataCidHash);

    //     Poseidon2HashAndPublicInputs memory poseidon2HashAndPublicInputs = Poseidon2HashAndPublicInputs({
    //         hash: _hash,
    //         merkleRoot: _merkleRoot,
    //         nullifier: _nullifier,
    //         nftMetadataCidHash: _nftMetadataCidHash
    //     });
    //     // console.logString(poseidon2HashAndPublicInputs.hash);
    //     // console.logBytes32(poseidon2HashAndPublicInputs.merkleRoot);
    //     // console.logBytes32(poseidon2HashAndPublicInputs.nullifier);
    //     // console.logBytes32(poseidon2HashAndPublicInputs.nftMetadataCidHash);

    //     return poseidon2HashAndPublicInputs;
    // }

}
