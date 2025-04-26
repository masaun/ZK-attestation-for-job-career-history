use std::hash::pedersen_hash;
//use std::merkle::compute_merkle_root;

/**
 * @dev - This function generates a Merkle tree with a depth of 1.
 * @param hash_0 - The first leaf hash.
 * @param hash_1 - The second leaf hash.
 * @return root - The root of the Merkle tree.
 */
pub fn generate_merkle_tree_with_depth_1(hash_0: Field, hash_1: Field) -> Field {
    let commitment_0 = std::hash::pedersen_hash([hash_0]);
    let commitment_1 = std::hash::pedersen_hash([hash_1]);

    let left_branch = std::hash::pedersen_hash([commitment_0]);
    let right_branch = std::hash::pedersen_hash([commitment_1]);

    let root = std::hash::pedersen_hash([left_branch, right_branch]);

    std::println("Merkle Tree:");
    std::println([root]);
    std::println([left_branch, right_branch]);
    std::println([commitment_0, commitment_1]);

    // @dev - Return the root of the Merkle tree
    root
}

/*
 * @dev - This function generates a Merkle tree with a depth of 2.
 * @param hash_0 - The first leaf hash.
 * @param hash_1 - The second leaf hash.
 * @param hash_2 - The third leaf hash.
 * @param hash_3 - The fourth leaf hash.
 * @return root - The root of the Merkle tree.
 */
pub fn generate_merkle_tree_with_depth_2(hash_0: Field, hash_1: Field, hash_2: Field, hash_3: Field) -> Field {
    let commitment_0 = std::hash::pedersen_hash([hash_0]);
    let commitment_1 = std::hash::pedersen_hash([hash_1]);
    let commitment_2 = std::hash::pedersen_hash([hash_2]);
    let commitment_3 = std::hash::pedersen_hash([hash_3]);

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