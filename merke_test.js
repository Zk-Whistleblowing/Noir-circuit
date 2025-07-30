import { IndexedMerkleTree } from 'indexed-merkle-noir';
import * as circomlibjs from 'circomlibjs';

// 1. 트리 초기화
const tree = new IndexedMerkleTree();

// let poseidonOpt;
// let poseidonReference;
// let poseidonWasm;
// poseidonOpt = await circomlibjs.buildPoseidonOpt();
// poseidonReference = await circomlibjs.buildPoseidonReference();
// poseidonWasm = await circomlibjs.buildPoseidon();

// // Poseidon 해시 → 0x hex string 변환 함수
// function poseidonHashHex(inputs) {
//   const hashBytes = poseidonReference(inputs);
//   return BigInt('0x' + Buffer.from(hashBytes).toString('hex'));
// }

// 2. 데이터 준비
const ids = [
  1n,
  2n,
  3n,
  4n,
  5n,
  6n,
  7n,
  8n,
  9n,
  10n,
  11n,
  12n,
  13n,
  14n,
  15n,
  16n,
  17n,
  18n,
  19n,
  20n,
];
const pws = [
  1001n,
  1002n,
  1003n,
  1004n,
  1005n,
  1006n,
  1007n,
  1008n,
  1009n,
  1010n,
  1011n,
  1012n,
  1013n,
  1014n,
  1015n,
  1016n,
  1017n,
  1018n,
  1019n,
  1020n,
];

// 3. 트리에 Poseidon 해시(hex) 삽입
for (let i = 0; i < ids.length; i++) {
  tree.insertItem(ids[i], pws[i]);
}

// 5. 특정 id의 증명 생성 (예: id=6)
const proof = tree.generateProof(6n);

// BigInt → 0x hex 변환 함수
// function toHex(v) {
//   return '0x' + v.toString(16).padStart(64, '0');
// }

console.log(proof);

// proof.siblings → Noir 서킷에서 쓰는 hash_path와 동일
// proof.leafIdx → index
// proof.root → 머클 루트
