import { poseidon2 } from "poseidon-lite";

// secret = 12345678901234567890123456789012345678901234567890123456789012345
// leafKey = 6
// nullifier = hash_2([secret, leafKey])

const secret = BigInt(
  "123456789012345678901234567890123456789012345678901234567890123451111"
);
const leafKey = BigInt(6);

// Poseidon hash with 2 inputs
const nullifier = poseidon2([secret, leafKey]);

console.log("Secret:", secret.toString());
console.log("LeafKey:", leafKey.toString());
console.log("Calculated nullifier:", nullifier.toString());
console.log("\nUpdate your Prover.toml with:");
console.log(`nullifier = "${nullifier.toString()}"`);
