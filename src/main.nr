use dep::std::hash::poseidon2::Poseidon2::hash;

global DEPTH: u32 = 20;

fn compute_merkle_root(leaf: Field, index: Field, hash_path: [Field]) -> Field {
    let n = hash_path.len();
    let index_bits = index.to_le_bits();
    let mut current = leaf;
    for i in 0..n {
        let path_bit = index_bits[i] as bool;
        let (hash_left, hash_right) = if path_bit {
            (hash_path[i], current)
        } else {
            (current, hash_path[i])
        };

        current = hash([hash_left, hash_right], 2);
    }
    current
}

fn main(id: Field, pw: Field, hash_path: [Field; DEPTH], index: Field, root: pub Field) {
    // leaf = Poseidon2(ID || PW)
    let leaf = hash([id, pw], 2);

    let computedRoot = compute_merkle_root(leaf, index, hash_path);

    assert(computedRoot == root);
}

#[test]
fn test_merkle_tree() {
    // Define 20 id, pw pairs
    let ids: [Field; 20] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];

    let pws: [Field; 20] = [
        1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015,
        1016, 1017, 1018, 1019, 1020,
    ];

    // Compute leaves as Poseidon hashes of [id, pw]
    let mut leaves: [Field; 20] = [0; 20];
    for i in 0..20 {
        leaves[i] = hash([ids[i], pws[i]], 2);
    }
}
