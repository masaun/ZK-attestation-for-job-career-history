mod test_inputs; // test_inputs.nr

mod tests {
    use crate::main;                   // src/main.nr
    use crate::data_types::{ IPNftData, RevealedData };  // src/data_types.nr
    use crate::converters;             // src/converters.nr -> converters/convert_cid_to_poseidon_hash.nr -> convert_nft_metadata_cid_to_poseidon_hash()
    use std::hash::poseidon2;
    use std::hash::pedersen_hash;
    use std::merkle::compute_merkle_root;

    #[test]
    fn test_nft_metadata_verifier() {
        let expected_merkle_root_of_job_title_commitment_merkle_tree: Field = 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629;   // @dev - Merkle Root of the job title commitment tree.
        let expected_merkle_root_of_skill_commitments_merkle_tree: [Field; 5] = [ // @dev - Merkle Root of the skill commitment tree.
            0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629,
            0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629,
            0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629,
            0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629,
            0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        ];
        //let root: Field = 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629;   // @dev - Merkle Root

        let hash_path: [Field; 2] = [0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8, 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77];

        let index_of_job_title_commitment_merkle_tree: Field = 0;           // @dev - Position in the tree.
        let index_of_skill_commitments_merkle_tree: [Field; 5] = [0, 1, 2, 3, 4];           // @dev - Position in the tree.
        //let index: Field = 0;

        let secret: Field = 1;

        let ip_nft_data: IPNftData = IPNftData {
            nft_owner: 0xC6093Fd9cc143F9f058938868b2df2daF9A91d28,
            nft_token_id: 1,
            nft_metadata_cid: "QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F"
        };

        // Convert a IPFS CID (sha256) -> bytes -> Field -> Poseidon2 Hash
        let nft_metadata_cid: str<46> = "QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F";
        let expected_nft_metadata_cid_hash: Field = converters::converter_module::convert_nft_metadata_cid_to_poseidon_hash(nft_metadata_cid);
        println(expected_nft_metadata_cid_hash); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0

        //let expected_nullifier: Field = 0x168758332d5b3e2d13be8048c8011b454590e06c44bce7f702f09103eef5a373;          // @dev - Successful (NOTE: This is equal to Field(10190015755989328289879378487807721086446093622177241109507523918927702106995) in Noir)
        //let expected_nullifier: Field = 10190015755989328289879378487807721086446093622177241109507523918927702106995; // @dev - Same with the "hash" in the output.json
        let expected_nullifier = poseidon2::Poseidon2::hash([expected_merkle_root_of_job_title_commitment_merkle_tree, secret, ip_nft_data.nft_owner, ip_nft_data.nft_token_id, expected_nft_metadata_cid_hash], 5);
        //let expected_nullifier = poseidon2::Poseidon2::hash([root, secret, ip_nft_data.nft_owner, ip_nft_data.nft_token_id, expected_nft_metadata_cid_hash], 5);
        println(expected_nullifier); // [Log]: 0x168758332d5b3e2d13be8048c8011b454590e06c44bce7f702f09103eef5a373

        // @dev - Career historical data and Skills data
        let job_title_hash: Field = 0x00000000000000000000000070997970c51812dc3a010c7d01b50e0d17dc79c8;     // @dev - Hash of the job title (e.g. Hashed "Software Engineer").
        let skill_hashes: [Field; 5] = [   // @dev - List of skill hashes (e.g. Hashed ["Rust", "ZK", "React"]).
            0x00000000000000000000000070997970c51812dc3a010c7d01b50e0d17dc79c8,
            0x0d76959f68406fde33752accbb712a425e9dc101b1ea4db5e3f9f9d0fb8bcd6e,
            0x20476c92bde69215bc26b1c58e4871eeb662e03c426767e4c603d9df7ecf630f,
            0x1306d71bfd84cac61cdfc548510f1877a9b00270355ba593aa85b24696efcb1e,
            0x1306d71bfd84cac61cdfc548510f1877a9b00270355ba593aa85b24696efcb1e
        ];

        let expected_job_title_commitment: Field = pedersen_hash([job_title_hash]);   // @dev - Commitment Hash of the job title to reveal (can be nullified if redacting).
        let expected_skill_commitments: [Field; 5] = [   // @dev - Commitment Hashes of the revealed skills.
            pedersen_hash([skill_hashes[0]]),
            pedersen_hash([skill_hashes[1]]),
            pedersen_hash([skill_hashes[2]]),
            pedersen_hash([skill_hashes[3]]),
            pedersen_hash([skill_hashes[4]])
        ];


        //let nullifier = main(
        let revealed_data: RevealedData = main(
            expected_merkle_root_of_job_title_commitment_merkle_tree,
            expected_merkle_root_of_skill_commitments_merkle_tree,
            //root,
            hash_path,
            index_of_job_title_commitment_merkle_tree,
            index_of_skill_commitments_merkle_tree,
            //index,
            secret,
            expected_nullifier,
            expected_nft_metadata_cid_hash, 
            ip_nft_data,
            job_title_hash,
            skill_hashes,
            expected_job_title_commitment,
            expected_skill_commitments
        );
        println(revealed_data.nullifier); // [Log]: 
        println(revealed_data.nft_metadata_cid_hash); // [Log]: 
        //println(nullifier); // [Log]: 0x168758332d5b3e2d13be8048c8011b454590e06c44bce7f702f09103eef5a373
        //println(nft_metadata_cid_hash); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0

        let inputs_for_note_commitment: [Field; 1] = [secret];
        let note_commitment = poseidon2::Poseidon2::hash(inputs_for_note_commitment, inputs_for_note_commitment.len());

        //let inputs_for_nullifier: [Field; 1] = [ip_nft_data.nft_token_id];
        let inputs_for_nullifier: [Field; 5] = [expected_merkle_root_of_job_title_commitment_merkle_tree, secret, ip_nft_data.nft_owner, ip_nft_data.nft_token_id, revealed_data.nft_metadata_cid_hash];
        //let inputs_for_nullifier: [Field; 5] = [root, secret, ip_nft_data.nft_owner, ip_nft_data.nft_token_id, revealed_data.nft_metadata_cid_hash];
        let _nullifier = poseidon2::Poseidon2::hash(inputs_for_nullifier, inputs_for_nullifier.len());
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
