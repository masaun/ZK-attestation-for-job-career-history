use std::hash::pedersen_hash;
//use std::merkle::compute_merkle_root;

pub fn build_merkle_tree(hash_1: Field, hash_2: Field, hash_3: Field, hash_4: Field) -> Field {
    let commitment_0 = std::hash::pedersen_hash([hash_1]);
    let commitment_1 = std::hash::pedersen_hash([hash_2]);
    let commitment_2 = std::hash::pedersen_hash([hash_3]);
    let commitment_3 = std::hash::pedersen_hash([hash_4]);

    let left_branch = std::hash::pedersen_hash([commitment_0, commitment_1]);
    let right_branch = std::hash::pedersen_hash([commitment_2, commitment_3]);

    let root = std::hash::pedersen_hash([left_branch, right_branch]);

    std::println("Merkle Tree:");
    std::println([root]);
    std::println([left_branch, right_branch]);
    std::println([commitment_0, commitment_1, commitment_2, commitment_3]);

    // @dev - Return the root of the Merkle tree
    root
}