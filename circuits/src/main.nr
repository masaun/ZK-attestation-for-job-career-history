mod tests;      // tests/mod.nr
mod data_types; // data_types.nr
mod converters; // converters.nr -> converters/convert_cid_to_poseidon_hash.nr -> convert_nft_metadata_cid_to_poseidon_hash()

use std::hash::poseidon2;
//use std::hash::pedersen_commitment;
use std::merkle::compute_merkle_root;

use data_types::{ IPNftData, RevealedData }; // @dev - IPNftData struct


fn main(
    root: pub Field,        // @dev - Merkle Root: 
    hash_path: [Field; 2],  // @dev - Merkle Path: The Merkle path proving the credential is in the attestation tree.
    //merkle_path: [Field; 32],
    leaf: Field,            // @dev - Merkle Leaf: The hash of the candidate's attested credential.
    index: Field,           // @dev - Position in the tree.
    secret: Field,          // @dev - A hidden metadata hash (private)
    expected_nullifier: Field,
    expected_nft_metadata_cid_hash: Field,
    ip_nft_data: IPNftData,

    // @dev - Career historical data and Skills data
    job_title_hash: Field,     // @dev - Hash of the job title (e.g. Hashed "Software Engineer").
    skill_hashes: [Field; 5],  // @dev - List of skill hashes (e.g. Hashed ["Rust", "ZK", "React"]).
    expected_job_title_commitment: pub Field,   // @dev - Commitment Hash of the job title to reveal (can be nullified if redacting).
    expected_skill_commitments: pub [Field; 5], // @dev - Commitment Hashes of the revealed skills.
) -> pub RevealedData {

    // Merkle proof
    let computed_root = compute_merkle_root(leaf, index, hash_path);
    assert(computed_root == root);

    // Ensure leaf encodes job title and skills
    let leaf_reconstructed = poseidon2::Poseidon2::hash([job_title_hash, skill_hashes[0], skill_hashes[1]], 3); // NOTE: This hashing method is "Pedersen Hash"
    assert(leaf == leaf_reconstructed);

    // Ensure disclosed commitments match inputs
    let inputs_for_note_commitment: [Field; 1] = [secret];
    let note_commitment = poseidon2::Poseidon2::hash(inputs_for_note_commitment, inputs_for_note_commitment.len());

    let inputs_for_job_title_commitment: [Field; 1] = [job_title_hash];
    let job_title_commitment: Field = poseidon2::Poseidon2::hash(inputs_for_job_title_commitment, inputs_for_job_title_commitment.len());
    assert(job_title_commitment == expected_job_title_commitment);

    for i in 0..5 {
        let inputs_for_skill_commitment: [Field; 1] = [skill_hashes[i]];
        let skill_commitment: Field = poseidon2::Poseidon2::hash(inputs_for_skill_commitment, inputs_for_skill_commitment.len());
        assert(skill_commitment == expected_skill_commitments[i]);
    }



    // let nullifier = std::hash::pedersen_hash([root, secret, proposalId]);

    // let check_root = std::merkle::compute_merkle_root(note_commitment, index, hash_path);
    // assert(root == check_root);
    


    // Convert a IPFS CID (sha256) -> bytes -> Field -> Poseidon2 Hash
    //let nft_metadata_cid: str<46> = "QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F";
    let nft_metadata_cid_hash: Field = converters::converter_module::convert_nft_metadata_cid_to_poseidon_hash(ip_nft_data.nft_metadata_cid);
    println(nft_metadata_cid_hash); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0

    // Constraint: nft_metadata_cid_hash == expected_nft_metadata_hash
    assert(nft_metadata_cid_hash == expected_nft_metadata_cid_hash);

    println(expected_nullifier); // [Log]: 0x1265c921cb8e0dc6c91f70ae08b14352b8f10451aee7582b9ed44abea8d4123c

    let inputs_for_note_commitment: [Field; 1] = [secret];
    let note_commitment = poseidon2::Poseidon2::hash(inputs_for_note_commitment, inputs_for_note_commitment.len());

    //let inputs_for_nullifier: [Field; 1] = [ip_nft_data.nft_token_id];
    let inputs_for_nullifier: [Field; 5] = [root, secret, ip_nft_data.nft_owner, ip_nft_data.nft_token_id, expected_nft_metadata_cid_hash];
    let nullifier = poseidon2::Poseidon2::hash(inputs_for_nullifier, inputs_for_nullifier.len());
    println(nullifier);

    // Constraint: nullifier (hash) == expected_nullifier (hash)
    assert(nullifier == expected_nullifier);

    //nullifier
    //(nullifier, nft_metadata_cid_hash)
    RevealedData {
        nullifier,
        nft_metadata_cid_hash,
        job_title_commitment,
        skill_commitments
    }
}
