global MAX_DEPTH: u32 = 32;
use dep::poseidon::poseidon::bn254::hash_2;
use dep::poseidon::poseidon::bn254::hash_4;

fn verifyProof(
    leafIdx: u32,
    leafKey: u64,
    leafNextIdx: u32,
    leafNextKey: u64,
    leafValue: Field,
    root: Field,
    siblings: [Field; MAX_DEPTH],
) {
    let mut current_hash = hash_4([
        leafKey as Field,
        leafNextIdx as Field,
        leafNextKey as Field,
        leafValue,
    ]);
    let mut idx = leafIdx;
    for i in 0..MAX_DEPTH {
        if siblings[i] != 0 {
            let is_right = ((idx & 1) == 0) as bool;
            let (hash_left, hash_right) = if is_right {
                (current_hash, siblings[i])
            } else {
                (siblings[i], current_hash)
            };
            current_hash = hash_2([hash_left, hash_right]);
            idx >>= 1;
        }
    }
    assert(current_hash == root);
}

fn verifyExclusionProof(
    leafIdx: u32,
    leafKey: u64,
    leafNextIdx: u32,
    leafNextKey: u64,
    leafValue: Field,
    root: Field,
    siblings: [Field; MAX_DEPTH],
    excludedKey: u64,
) {
    verifyProof(
        leafIdx,
        leafKey,
        leafNextIdx,
        leafNextKey,
        leafValue,
        root,
        siblings,
    );
    assert(excludedKey > leafKey);
    if leafNextIdx > 0 {
        assert(excludedKey < leafNextKey);
    }
}

fn verifyInsertionProof(
    ogLeafIdx: u32,
    ogLeafKey: u64,
    ogLeafNextIdx: u32,
    ogLeafNextKey: u64,
    ogLeafValue: Field,
    newLeafIdx: u32,
    newLeafKey: u64,
    newLeafValue: Field,
    rootBefore: Field,
    rootAfter: Field,
    siblingsBefore: [Field; MAX_DEPTH],
    siblingsAfterOg: [Field; MAX_DEPTH],
    siblingsAfterNew: [Field; MAX_DEPTH],
) {
    // 1) All three proofs must be individually valid
    verifyProof(
        ogLeafIdx,
        ogLeafKey,
        ogLeafNextIdx,
        ogLeafNextKey,
        ogLeafValue,
        rootBefore,
        siblingsBefore,
    );
    verifyProof(
        ogLeafIdx,
        ogLeafKey,
        newLeafIdx,
        newLeafKey,
        ogLeafValue,
        rootAfter,
        siblingsAfterOg,
    );
    verifyProof(
        newLeafIdx,
        newLeafKey,
        ogLeafNextIdx,
        ogLeafNextKey,
        newLeafValue,
        rootAfter,
        siblingsAfterNew,
    );

    // 2) The "after" proofs must have equal length
    let mut siblingsBeforeLen: u32 = MAX_DEPTH + 1;
    let mut siblingsAfterOgLen: u32 = MAX_DEPTH + 1;
    let mut siblingsAfterNewLen: u32 = MAX_DEPTH + 1;
    for i in 0..MAX_DEPTH {
        if (siblingsBeforeLen == MAX_DEPTH + 1) & (siblingsBefore[i] == 0) {
            siblingsBeforeLen = i;
        }
        if (siblingsAfterOgLen == MAX_DEPTH + 1) & (siblingsAfterOg[i] == 0) {
            siblingsAfterOgLen = i;
        }
        if (siblingsAfterNewLen == MAX_DEPTH + 1) & (siblingsAfterNew[i] == 0) {
            siblingsAfterNewLen = i;
        }
    }
    assert(siblingsAfterOgLen == siblingsAfterNewLen);
    //    And the "before" proof's length must be either the same (no height change)
    //    or exactly one less (height grew by 1, e.g. first insertion or crossing a power-of-two).
    assert(
        (siblingsBeforeLen == siblingsAfterNewLen) | (siblingsBeforeLen + 1 == siblingsAfterNewLen),
    );

    // 3) Find the first level at which the predecessor's proof changed
    let mut diffIdx = MAX_DEPTH + 1;
    for i in 0..MAX_DEPTH {
        if i < siblingsAfterNewLen {
            if (diffIdx == MAX_DEPTH + 1) & (siblingsBefore[i] != siblingsAfterOg[i]) {
                diffIdx = i;
            }
        }
    }
    // We must see exactly one "first" change
    assert(diffIdx != MAX_DEPTH + 1);
    // And ensure nothing *before* that level changed
    for i in 0..MAX_DEPTH {
        if i < diffIdx {
            assert(siblingsBefore[i] == siblingsAfterOg[i]);
        }
    }
    // 4) Now recompute the "sub-root" of the new leaf up to diffIdx, and
    //    check it matches the sibling that was injected into the prev-proof.
    let mut current_hash = hash_4([
        newLeafKey as Field,
        ogLeafNextIdx as Field,
        ogLeafNextKey as Field,
        newLeafValue,
    ]);
    let mut idx = newLeafIdx;
    for i in 0..MAX_DEPTH {
        if i < diffIdx {
            let is_right = ((idx & 1) == 0) as bool;
            let (hash_left, hash_right) = if is_right {
                (current_hash, siblingsAfterNew[i])
            } else {
                (siblingsAfterNew[i], current_hash)
            };
            current_hash = hash_2([hash_left, hash_right]);
            idx >>= 1;
        }
    }
    assert(current_hash == siblingsAfterOg[diffIdx]);
}

fn main(
    leafIdx: u32,
    leafKey: u64,
    leafNextIdx: u32,
    leafNextKey: u64,
    leafValue: Field,
    root: Field,
    siblings: [Field; 32],
) {
    verifyProof(
        leafIdx,
        leafKey,
        leafNextIdx,
        leafNextKey,
        leafValue,
        root,
        siblings,
    );
}

#[test]
fn test_merkle_tree() {
    verifyProof(
        6,
        6,
        7,
        7,
        1006,
        7420758245723695741339772407036591119149422708827218559831868837005030424306,
        [
            8638038457832739729317554780486517737459039859720241678260540771268785073583,
            20875710769420856321727411154335934173213302435189610873979602997742842441139,
            11845123360003649186639962078866747269612952657358573444480422812138068524710,
            19163174245840510895057604832614480483787367169673967374753351720918722300633,
            6756030518013958544030089287539615560996240983885311295876707107886417217200,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
            0,
        ],
    );
}
