mod tests;      // tests/mod.nr
mod data_types; // data_types.nr
mod utils; // converters.nr -> converters/convert_cid_to_poseidon_hash.nr -> convert_nft_metadata_cid_to_poseidon_hash()

use std::hash::poseidon2;
use std::hash::pedersen_hash;
use std::merkle::compute_merkle_root;

use data_types::{ JobCareerAndSkillData, RevealedData }; // @dev - IPNftData struct


fn main(
    merkle_root_of_job_title_commitment_merkle_tree: pub Field,   // @dev - Merkle Root of the job title commitment tree.
    merkle_root_of_skill_commitments_merkle_tree: pub [Field; 4], // @dev - Merkle Root of the skill commitment tree.
    hash_path: [Field; 2],                                        // @dev - Merkle Path: The Merkle path proving the credential is in the attestation tree.
    //merkle_path: [Field; 32],
    //leaf: Field,                                                // @dev - Merkle Leaf: The hash of the candidate's attested credential. -> This may not be needed because each commitment will be used as each "Leaf"
    index_of_job_title_commitment_merkle_tree: Field,             // @dev - Position in the tree.
    index_of_skill_commitments_merkle_tree: [Field; 4],           // @dev - Position in the tree.
    secret: Field,                                                // @dev - A hidden metadata hash (private)
    nullifier: Field,
    job_career_and_skill_data: JobCareerAndSkillData
) -> pub RevealedData {

    // Ensure leaf encodes job title and skills
    //let leaf_reconstructed = poseidon2::Poseidon2::hash([job_title_hash, skill_hashes[0], skill_hashes[1]], 3); // NOTE: This hashing method is "Pedersen Hash"
    //assert(leaf == leaf_reconstructed);

    // Ensure disclosed commitments match inputs
    let inputs_for_note_commitment: [Field; 1] = [secret];
    let note_commitment = pedersen_hash(inputs_for_note_commitment);

    let inputs_for_job_title_commitment: [Field; 1] = [job_career_and_skill_data.job_title_hash];
    let job_title_commitment: Field = pedersen_hash(inputs_for_job_title_commitment);
    assert(job_title_commitment == job_career_and_skill_data.job_title_commitment);

    let skill_commitments: [Field; 4] = [
        pedersen_hash([job_career_and_skill_data.skill_hashes[0]]),
        pedersen_hash([job_career_and_skill_data.skill_hashes[1]]),
        pedersen_hash([job_career_and_skill_data.skill_hashes[2]]),
        pedersen_hash([job_career_and_skill_data.skill_hashes[3]])
    ];
    
    for i in 0..4 { // @dev - In case of "0..5", index "5" is not included in the range
        let inputs_for_skill_commitment: [Field; 1] = [job_career_and_skill_data.skill_hashes[i]];
        let expected_skill_commitment: Field = pedersen_hash(inputs_for_skill_commitment);
        //assert(skill_commitment == expected_skill_commitments[i]);

        let expected_merkle_root_of_skill_commitment_merkle_tree = std::merkle::compute_merkle_root(expected_skill_commitment, index_of_skill_commitments_merkle_tree[i], hash_path); // [NOTE]: Each "job_title_commitment" will be a "Leaf" of the "Markle Tree" of "job_title_commitment" hashes.
        //assert(merkle_root_of_skill_commitment_merkle_tree == expected_merkle_root_of_skill_commitments_merkle_tree[i]);
    }

    // Compute a Merkle Root /w "commitnent hash" + Constraint: nullifier (hash) == expected_nullifier (hash)
    let expected_merkle_root_of_job_title_commitment_merkle_tree = std::merkle::compute_merkle_root(job_title_commitment, index_of_job_title_commitment_merkle_tree, hash_path); // [NOTE]: Each "job_title_commitment" will be a "Leaf" of the "Markle Tree" of "job_title_commitment" hashes.
    //assert(merkle_root_of_job_title_commitment_merkle_tree == expected_merkle_root_of_job_title_commitment_merkle_tree);

    // let computed_root = compute_merkle_root(leaf, index, hash_path);
    // assert(computed_root == root);

    // Constraint: nullifier (hash) == expected_nullifier (hash)
    let inputs_for_nullifier: [Field; 5] = [
        merkle_root_of_job_title_commitment_merkle_tree, 
        secret, 
        job_title_commitment, 
        job_career_and_skill_data.skill_hashes[0], 
        job_career_and_skill_data.skill_hashes[1]
    ];

    let expected_nullifier = poseidon2::Poseidon2::hash(inputs_for_nullifier, inputs_for_nullifier.len());
    println(f"expected_nullifier: {expected_nullifier}");

    assert(nullifier == expected_nullifier);

    //nullifier
    //(nullifier, nft_metadata_cid_hash)
    RevealedData {
        nullifier,
        job_title_commitment,
        skill_commitments
    }
}
