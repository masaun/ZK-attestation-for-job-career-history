mod tests;      // tests/mod.nr
mod data_types; // data_types.nr
mod utils;      // utils.nr -> utils/convert_cid_to_poseidon_hash.nr -> convert_nft_metadata_cid_to_poseidon_hash()

use std::hash::poseidon2;
use std::hash::pedersen_hash;
use std::merkle::compute_merkle_root;

use utils::merkle_tree_generator::generate_merkle_tree_with_depth_1; // @dev - generate_merkle_tree_with_depth_1() function
use data_types::{ JobCareerAndSkillData, RevealedData };             // @dev - JobCareerAndSkillData, RevealedData struct


fn main(
    merkle_root: pub Field,                                         // @dev - Merkle Root, which is consist of both a job_title_commitment and a _skills_combined_commitment
    //merkle_root_of_job_title_commitment_merkle_tree: pub Field,   // @dev - Merkle Root of the job title commitment tree.
    //merkle_root_of_skills_combined_commitment_merkle_tree: pub Field, // @dev - Merkle Root of the skill commitment tree.
    hash_path: [Field; 2],                                        // @dev - Merkle Path: The Merkle path proving the credential is in the attestation tree.
    //merkle_path: [Field; 32],
    //leaf: Field,                                                // @dev - Merkle Leaf: The hash of the candidate's attested credential. -> This may not be needed because each commitment will be used as each "Leaf"
    //index_of_job_title_commitment_merkle_tree: Field,             // @dev - Position in the tree.
    //index_of_skills_combined_commitments_merkle_tree: Field,      // @dev - Position in the tree.
    //index: Field,
    secret: Field,                                                // [TODO]: To be removed
    nullifier: Field,
    job_career_and_skill_data: JobCareerAndSkillData
) -> pub RevealedData {

    // Ensure leaf encodes job title and skills
    //let leaf_reconstructed = poseidon2::Poseidon2::hash([job_title_hash, skill_hashes[0], skill_hashes[1]], 3); // NOTE: This hashing method is "Pedersen Hash"
    //assert(leaf == leaf_reconstructed);

    // @dev - Job Title commitment, which each "commitment" will be a "Leaf" of the Job Title commitment "Markle Tree"
    let inputs_for_job_title_commitment: [Field; 1] = [job_career_and_skill_data.job_title_hash];
    let job_title_commitment: Field = pedersen_hash([job_career_and_skill_data.job_title_hash, secret]);
    assert(job_title_commitment == job_career_and_skill_data.job_title_commitment);

    // @dev - Skills combined commitment, which each "commitment" will be a "Leaf" of the Skills combined commitment "Markle Tree"
    let inputs_for_skill_hashes: [Field; 4] = job_career_and_skill_data.skill_hashes;
    let skills_combined_hash: Field = pedersen_hash(inputs_for_skill_hashes);
    let skills_combined_commitment: Field = pedersen_hash([skills_combined_hash, secret]);
    assert(skills_combined_commitment == job_career_and_skill_data.skills_combined_commitment);

    // @dev - Generate a Merkle tree with a depth of 1
    let expected_merkle_root = generate_merkle_tree_with_depth_1(job_title_commitment, skills_combined_commitment);
    println(f"expected_merkle_root: {expected_merkle_root}");
    assert(merkle_root == expected_merkle_root);

    // // Compute a Merkle Root of job_title_commitment tree /w "commitnent hash"
    // let expected_merkle_root_of_job_title_commitment_merkle_tree = std::merkle::compute_merkle_root(job_title_commitment, index_of_job_title_commitment_merkle_tree, hash_path); // [NOTE]: Each "job_title_commitment" will be a "Leaf" of the "Markle Tree" of "job_title_commitment" hashes.
    // assert(merkle_root_of_job_title_commitment_merkle_tree == expected_merkle_root_of_job_title_commitment_merkle_tree);

    // // Compute a Merkle Root of skills_combined_commitment tree  /w "commitnent hash"
    // let expected_merkle_root_of_skills_combined_commitment_merkle_tree = std::merkle::compute_merkle_root(skills_combined_commitment, index_of_skills_combined_commitments_merkle_tree, hash_path); // [NOTE]: Each "job_title_commitment" will be a "Leaf" of the "Markle Tree" of "job_title_commitment" hashes.
    // assert(merkle_root_of_skills_combined_commitment_merkle_tree == expected_merkle_root_of_skills_combined_commitment_merkle_tree);

    // Constraint: nullifier (hash) == expected_nullifier (hash)
    let inputs_for_nullifier: [Field; 4] = [
        merkle_root,
        //merkle_root_of_job_title_commitment_merkle_tree, 
        //merkle_root_of_skills_combined_commitment_merkle_tree,
        secret, 
        job_title_commitment, 
        skills_combined_commitment
    ];

    let expected_nullifier = poseidon2::Poseidon2::hash(inputs_for_nullifier, inputs_for_nullifier.len());
    println(f"expected_nullifier: {expected_nullifier}");
    assert(nullifier == expected_nullifier);

    // @dev - Return the revealed data
    RevealedData {
        nullifier,
        job_title_commitment,
        skills_combined_commitment
    }
}
