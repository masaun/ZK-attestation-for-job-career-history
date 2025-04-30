pragma solidity ^0.8.17;

import { UltraVerifier } from "../../../contracts/circuit/ultra-verifier/plonk_vk.sol";
import { JobTitlesAndSkillsProofVerifier } from "../../../contracts/circuit/JobTitlesAndSkillsProofVerifier.sol";
import { DataTypeConverter } from "../../../contracts/libraries/DataTypeConverter.sol";

import "forge-std/console.sol";
import { Test } from "forge-std/Test.sol";
import { NoirHelper } from "foundry-noir-helper/NoirHelper.sol";


/**
 * @title - The test of the JobTitlesAndSkillsProofVerifier contract on Pharos Testnet (Devnet)
 */
contract JobTitlesAndSkillsProofVerifierTest_OnPharosTestnet is Test {
    JobTitlesAndSkillsProofVerifier public jobTitlesAndSkillsProofVerifier;
    UltraVerifier public verifier;
    NoirHelper public noirHelper;

    function setUp() public {
        noirHelper = new NoirHelper();

        /// @dev - Read the each deployed address from the configuration file.
        address ULTRAVERIFER = vm.envAddress("ULTRAVERIFER_ON_PHAROS_TESTNET");
        address JOB_TITLES_AND_SKILLS_PROOF_VERIFIER = vm.envAddress("JOB_TITLES_AND_SKILLS_PROOF_VERIFIER_ON_PHAROS_TESTNET");

        /// @dev - Create the SC instances /w deployed SC addresses
        verifier = UltraVerifier(ULTRAVERIFER);
        jobTitlesAndSkillsProofVerifier = JobTitlesAndSkillsProofVerifier(JOB_TITLES_AND_SKILLS_PROOF_VERIFIER);
        //verifier = new UltraVerifier();
        //jobTitlesAndSkillsProofVerifier = new JobTitlesAndSkillsProofVerifier(verifier);
    }

    function test_verifyProof() public {
        // @dev - Store a hash_path into a bytes32 array.
        uint256[] memory hash_path = new uint256[](2);
        hash_path[0] = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8;
        hash_path[1] = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77;
        bytes32[] memory hash_path_bytes32 = new bytes32[](2);
        hash_path_bytes32[0] = bytes32(hash_path[0]);
        hash_path_bytes32[1] = bytes32(hash_path[1]);

        // @dev - Store a skill_hashes into a bytes32 array.
        uint256[] memory skill_hashes = new uint256[](4);
        skill_hashes[0] = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8;
        skill_hashes[1] = 0x0d76959f68406fde33752accbb712a425e9dc101b1ea4db5e3f9f9d0fb8bcd6e;
        skill_hashes[2] = 0x20476c92bde69215bc26b1c58e4871eeb662e03c426767e4c603d9df7ecf630f;
        skill_hashes[3] = 0x1306d71bfd84cac61cdfc548510f1877a9b00270355ba593aa85b24696efcb1e;
        bytes32[] memory skill_hashes_bytes32 = new bytes32[](4);
        skill_hashes_bytes32[0] = bytes32(skill_hashes[0]);
        skill_hashes_bytes32[1] = bytes32(skill_hashes[1]);
        skill_hashes_bytes32[2] = bytes32(skill_hashes[2]);
        skill_hashes_bytes32[3] = bytes32(skill_hashes[3]);

        /// @dev - Set the input data for generating a proof
        noirHelper.withInput("merkle_root", bytes32(uint256(0x28425d6e6583b1df3078b88954e9aadedfff45bde8a7b94bdf8fd0018f099550)))
                  .withInput("hash_path", hash_path_bytes32)
                  //.withInput("index", bytes32(uint256(0)))
                  .withInput("secret", bytes32(uint256(1)))                   
                  .withInput("nullifier", bytes32(uint256(0x2257a91089fa22f5b5ccc3ac9b2478926b4114b62a7642c74c535d2a5f204c76)))
                  .withStruct("job_career_and_skill_data")
                  .withStructInput("job_title_hash", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
                  .withStructInput("skill_hashes", skill_hashes_bytes32)
                  .withStructInput("job_title_commitment", bytes32(uint256(0x231cf0e55d8edded09899ecb8c17971efa152d0298aac59cb4383acdebcee12a)))
                  .withStructInput("skills_combined_commitment", bytes32(uint256(0x0cad87d2449640357fe35c04a31030834f023e777651ae1c82b01ab9afebdd1d)));

        /// @dev - Generate the proof
        (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_verifyProof", 4); // [NOTE]: The number of public inputs is '4'.
        console.logBytes32(publicInputs[0]); // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        console.logBytes32(publicInputs[1]); // [Log]: 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862
        console.logBytes32(publicInputs[2]); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0
        console.logBytes32(publicInputs[3]); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0

        /// @dev - Verify the proof
        jobTitlesAndSkillsProofVerifier.verifyJobTitlesAndSkillsProofVerifier(proof, publicInputs);
    }

    function test_wrongProof() public {
        noirHelper.clean();

        // @dev - Store a hash_path into a bytes32 array.
        uint256[] memory hash_path = new uint256[](2);
        hash_path[0] = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8;
        hash_path[1] = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77;
        bytes32[] memory hash_path_bytes32 = new bytes32[](2);
        hash_path_bytes32[0] = bytes32(hash_path[0]);
        hash_path_bytes32[1] = bytes32(hash_path[1]);

        // @dev - Store a skill_hashes into a bytes32 array.
        uint256[] memory skill_hashes = new uint256[](4);
        skill_hashes[0] = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8;
        skill_hashes[1] = 0x0d76959f68406fde33752accbb712a425e9dc101b1ea4db5e3f9f9d0fb8bcd6e;
        skill_hashes[2] = 0x20476c92bde69215bc26b1c58e4871eeb662e03c426767e4c603d9df7ecf630f;
        skill_hashes[3] = 0x1306d71bfd84cac61cdfc548510f1877a9b00270355ba593aa85b24696efcb1e;
        bytes32[] memory skill_hashes_bytes32 = new bytes32[](4);
        skill_hashes_bytes32[0] = bytes32(skill_hashes[0]);
        skill_hashes_bytes32[1] = bytes32(skill_hashes[1]);
        skill_hashes_bytes32[2] = bytes32(skill_hashes[2]);
        skill_hashes_bytes32[3] = bytes32(skill_hashes[3]);

        /// @dev - Set the input data for generating a proof
        noirHelper.withInput("merkle_root", bytes32(uint256(0x28425d6e6583b1df3078b88954e9aadedfff45bde8a7b94bdf8fd0018f099550)))
                  .withInput("hash_path", hash_path_bytes32)
                  //.withInput("index", bytes32(uint256(0)))
                  .withInput("secret", bytes32(uint256(1)))                   
                  .withInput("nullifier", bytes32(uint256(0x2257a91089fa22f5b5ccc3ac9b2478926b4114b62a7642c74c535d2a5f204c76)))
                  .withStruct("job_career_and_skill_data")
                  .withStructInput("job_title_hash", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
                  .withStructInput("skill_hashes", skill_hashes_bytes32)
                  .withStructInput("job_title_commitment", bytes32(uint256(0x231cf0e55d8edded09899ecb8c17971efa152d0298aac59cb4383acdebcee12a)))
                  .withStructInput("skills_combined_commitment", bytes32(uint256(0x0cad87d2449640357fe35c04a31030834f023e777651ae1c82b01ab9afebdd1d)));

        /// @dev - Generate the proof
        (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_verifyProof", 4); // [NOTE]: The number of public inputs is '4'.
        console.logBytes32(publicInputs[0]); // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        console.logBytes32(publicInputs[1]); // [Log]: 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862
        console.logBytes32(publicInputs[2]); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0
        console.logBytes32(publicInputs[3]); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0

        /// @dev - Create a fake public input, which should fail because the public input is wrong
        bytes32[] memory fakePublicInputs = new bytes32[](4);
        fakePublicInputs[0] = publicInputs[0];
        fakePublicInputs[1] = bytes32(uint256(0xddddd));  // @dev - This is wrong publicInput ("nulifieir")
        fakePublicInputs[2] = publicInputs[2];
        fakePublicInputs[3] = publicInputs[3];

        /// @dev - Verify the proof, which should be reverted
        vm.expectRevert();
        jobTitlesAndSkillsProofVerifier.verifyJobTitlesAndSkillsProofVerifier(proof, fakePublicInputs);
    }

    // function test_all() public {
    //     // forge runs tests in parallel which messes with the read/writes to the proof file
    //     // Run tests in wrapper to force them run sequentially
    //     verifyProof();
    //     wrongProof();
    // }

}