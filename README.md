```bash
# Install dependencies
npm install

# Compile Noir circuit
nargo build

# Run JS proof generator or test
node merkle_test.js

# Run Noir tests
nargo test
```

# How To Integrate with Solidity Contract

```bash

# verifying the proof
nargo execute
bb prove -b ./target/project_circuit.json -w ./target/project_circuit.gz -o ./target
bb write_vk -b ./target/project_circuit.json -o ./target
bb verify -k ./target/vk -p ./target/proof -i ./target/public_inputs


# creating solidity verifier
bb write_vk -b ./target/project_circuit.json -o ./target --oracle_hash keccak
bb write_solidity_verifier -k ./target/vk -o ./realVerifier.sol

# save proof as file (proofForNullifier)
nargo execute
bb prove -b ./target/project_circuit.json -w ./target/project_circuit.gz -o ./target --oracle_hash keccak --output_format bytes_and_fields
echo -n "0x"; cat ./target/proof | od -An -v -t x1 | tr -d $' \n' >> proofForNullifier
```
