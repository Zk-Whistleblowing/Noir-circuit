import * as circomlibjs from 'circomlibjs';
import { MerkleTree } from 'merkletreejs';

// BigInt -> Buffer 변환 함수 (32 bytes, big endian)
function bigIntToBuffer(num) {
  let hex = num.toString(16);
  if (hex.length % 2) hex = '0' + hex;
  const buf = Buffer.from(hex, 'hex');
  if (buf.length < 32) {
    const pad = Buffer.alloc(32 - buf.length);
    return Buffer.concat([pad, buf]);
  }
  return buf;
}

// Buffer -> BigInt 배열 변환 (각 32bit씩)
function bufferToBigIntArray(buffer) {
  const res = [];
  for (let i = 0; i < buffer.length; i += 32) {
    const slice = buffer.slice(i, i + 32);
    res.push(BigInt('0x' + slice.toString('hex')));
  }
  return res;
}

async function main() {
  const poseidon = await circomlibjs.buildPoseidon();

  // poseidon 해시 함수, Buffer(바이트 배열) 입력 처리
  function poseidonHash(data) {
    // data는 Buffer, 이를 BigInt 배열로 변환
    const inputBigInts = bufferToBigIntArray(data);
    const hashBigInt = poseidon(inputBigInts);
    return bigIntToBuffer(hashBigInt);
  }

  // 사원 id, pw를 Buffer로 합치기
  function encodeLeaf(id, pw) {
    // id와 pw를 각각 32바이트 버퍼로 변환하고 연결
    const bufId = Buffer.alloc(32);
    bufId.writeBigUInt64BE(BigInt(id), 24); // 뒤쪽에 숫자 기록 (64bit)
    const bufPw = Buffer.alloc(32);
    bufPw.writeBigUInt64BE(BigInt(pw), 24);
    return Buffer.concat([bufId, bufPw]); // 64 bytes total
  }

  const employees = [
    { id: 1, pw: 1234 },
    { id: 2, pw: 5678 },
    { id: 3, pw: 9999 },
  ];

  // leaf: id+pw buffer → 해시된 buffer
  const leaves = employees.map((e) => poseidonHash(encodeLeaf(e.id, e.pw)));

  // merkletreejs에 맞게 해시함수 재정의: 단일 Buffer 입력, Buffer 출력
  const tree = new MerkleTree(leaves, poseidonHash, { sortPairs: true });

  const root = tree.getRoot().toString('hex');
  console.log('Merkle Root:', root);

  const leaf = leaves[1];
  const proof = tree.getProof(leaf).map((x) => '0x' + x.data.toString('hex'));
  const proofIndices = proof.map((x) => (x.position === 'right' ? 1 : 0));

  console.log('Proof:', proof);
  console.log('Proof indices:', proofIndices);
}

main();
