mod test_inputs; // test_inputs.nr

mod tests {
    use crate::main;                   // src/main.nr
    use crate::data_types::{ JobCareerAndSkillData, RevealedData };  // src/data_types.nr
    use crate::utils;                  // src/utils.nr -> utils/convert_cid_to_poseidon_hash.nr -> convert_nft_metadata_cid_to_poseidon_hash()
    use std::hash::poseidon2;
    use std::hash::pedersen_hash;
    use std::merkle::compute_merkle_root;

    #[test]
    fn test_job_titles_and_skills_verifier() {
        let merkle_root_of_job_title_commitment_merkle_tree: Field = 0x278cf9e26cf868e81bf990d0165f1aac2efa787813df392bd9379f56740cfb89;         // @dev - Merkle Root of the job_title commitment tree.
        let merkle_root_of_skills_combined_commitment_merkle_tree: Field = 0x2d838863657606f9b3514548d2b7fa90526cf42e1692aef4b5ce00aab23af622;   // @dev - Merkle Root of the skills_combined commitment tree.

        let hash_path: [Field; 2] = [0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8, 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77];

        let index_of_job_title_commitment_merkle_tree: Field = 0;           // @dev - Position in the job_title_commitment tree.
        let index_of_skills_combined_commitments_merkle_tree: Field = 0;    // @dev - Position in the skills_combined_commitment tree.

        let secret: Field = 1;

        // @dev - Career historical data and Skills data
        let _job_title_hash: Field = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8;     // @dev - Hash of the job title (e.g. Hashed "Software Engineer").
        let _skill_hashes: [Field; 4] = [   // @dev - List of skill hashes (e.g. Hashed ["Rust", "ZK", "React"]).
            0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8,
            0x0d76959f68406fde33752accbb712a425e9dc101b1ea4db5e3f9f9d0fb8bcd6e,
            0x20476c92bde69215bc26b1c58e4871eeb662e03c426767e4c603d9df7ecf630f,
            0x1306d71bfd84cac61cdfc548510f1877a9b00270355ba593aa85b24696efcb1e
        ];
        //println(f"skill_hashes: {skill_hashes}");
        println(f"_skill_hashes: {_skill_hashes}"); 

        let _job_title_commitment: Field = pedersen_hash([_job_title_hash, secret]);   // @dev - Commitment Hash of the job title to reveal (can be nullified if redacting).

        let _skills_combined_hash: Field = pedersen_hash(_skill_hashes);
        let _skills_combined_commitment: Field = pedersen_hash([_skills_combined_hash, secret]);

        let inputs_for_nullifier: [Field; 5] = [
            merkle_root_of_job_title_commitment_merkle_tree, 
            merkle_root_of_skills_combined_commitment_merkle_tree,
            secret, 
            _job_title_commitment, 
            _skills_combined_commitment
        ];

        let nullifier = poseidon2::Poseidon2::hash(inputs_for_nullifier, inputs_for_nullifier.len());
        println(f"nullifier: {nullifier}"); // [Log]: 0x168758332d5b3e2d13be8048c8011b454590e06c44bce7f702f09103eef5a373

        let job_career_and_skill_data: JobCareerAndSkillData = JobCareerAndSkillData {
            job_title_hash: _job_title_hash,
            skill_hashes: _skill_hashes,
            job_title_commitment: _job_title_commitment,
            skills_combined_commitment: _skills_combined_commitment
        };
        println(f"job_career_and_skill_data: {job_career_and_skill_data}");

        // Compute a Merkle Root of job_title & skills_combined commitment tree /w "commitnent hash"
        let _merkle_root_of_job_title_commitment_merkle_tree = std::merkle::compute_merkle_root(_job_title_commitment, index_of_job_title_commitment_merkle_tree, hash_path); // [NOTE]: Each "job_title_commitment" will be a "Leaf" of the "Markle Tree" of "job_title_commitment" hashes.
        let _merkle_root_of_skills_combined_commitment_merkle_tree = std::merkle::compute_merkle_root(_skills_combined_commitment, index_of_skills_combined_commitments_merkle_tree, hash_path); // [NOTE]: Each "job_title_commitment" will be a "Leaf" of the "Markle Tree" of "job_title_commitment" hashes.
        println(f"merkle_root_of_job_title_commitment_merkle_tree: {_merkle_root_of_job_title_commitment_merkle_tree}");
        println(f"merkle_root_of_skills_combined_commitment_merkle_tree: {_merkle_root_of_skills_combined_commitment_merkle_tree}");

        //let nullifier = main(
        let revealed_data: RevealedData = main(
            merkle_root_of_job_title_commitment_merkle_tree,
            merkle_root_of_skills_combined_commitment_merkle_tree,
            //root,
            hash_path,
            index_of_job_title_commitment_merkle_tree,
            index_of_skills_combined_commitments_merkle_tree,
            //index,
            secret,
            nullifier,
            job_career_and_skill_data
        );
        println(revealed_data.nullifier); // [Log]: 

        let inputs_for_note_commitment: [Field; 1] = [secret];
        let note_commitment = poseidon2::Poseidon2::hash(inputs_for_note_commitment, inputs_for_note_commitment.len());


        let _inputs_for_nullifier: [Field; 5] = [
            merkle_root_of_job_title_commitment_merkle_tree, 
            merkle_root_of_skills_combined_commitment_merkle_tree,
            secret, 
            _job_title_commitment, 
            _skills_combined_commitment
        ];

        let _nullifier = poseidon2::Poseidon2::hash(_inputs_for_nullifier, _inputs_for_nullifier.len());
        println(_nullifier); // [Log]: 0x168758332d5b3e2d13be8048c8011b454590e06c44bce7f702f09103eef5a373

        // Constraint check
        assert(revealed_data.nullifier == _nullifier, "Invalid nullifier");

        println("The test of the test_nft_metadata_verifier()) has been successful");

        // Test - Convert IPFS CID (sha256) -> bytes -> Field -> Poseidon2 Hash
        test_convert_nft_metadata_cid_to_poseidon_hash();
    }

    /** 
     * @notice - Test: Convert IPFS CID (sha256) -> bytes -> Field -> Poseidon2 Hash
     */
    fn test_convert_nft_metadata_cid_to_poseidon_hash() {
        let metadata_cid_1: str<46> = "QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F";
        let metadata_cid_2: str<46> = "QmT78zSuBmuS4z925W1XycoGEErPzHcYjzvAQLCNs5fLhn";
        let metadata_cid_1_bytes: [u8; 46] = metadata_cid_1.as_bytes();
        let metadata_cid_2_bytes: [u8; 46] = metadata_cid_2.as_bytes();
        println(metadata_cid_1); // [Log]: QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F
        println(metadata_cid_2); // [Log]: QmT78zSuBmuS4z925W1XycoGEErPzHcYjzvAQLCNs5fLhn

        let metadata_cid_1_field = Field::from_be_bytes::<46>(metadata_cid_1_bytes);
        let metadata_cid_2_field = Field::from_be_bytes::<46>(metadata_cid_2_bytes);
        println(metadata_cid_1_field); // [Log]: 0x2182f80240dbbfd8b3316c247d0ea667122dfc185af9cf934aeb9ec6dc2e9b28
        println(metadata_cid_2_field); // [Log]: 0x2cdf90be3235c6bf5def83da7f43b6ff87c0921a030d25bdba939747953d2978

        let inputs_for_metadata_cid_field_1: [Field; 1] = [metadata_cid_1_field];
        let inputs_for_metadata_cid_field_2: [Field; 1] = [metadata_cid_2_field];
        let metadata_cid_hash_1 = poseidon2::Poseidon2::hash(inputs_for_metadata_cid_field_1, inputs_for_metadata_cid_field_1.len());
        let metadata_cid_hash_2 = poseidon2::Poseidon2::hash(inputs_for_metadata_cid_field_2, inputs_for_metadata_cid_field_2.len());
        println(metadata_cid_hash_1); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0
        println(metadata_cid_hash_2); // [Log]: 0x214d21e2af69ee717d49475734429bce912b83c4da4d0e4e2f3dc0b044e2906b
    }
}
