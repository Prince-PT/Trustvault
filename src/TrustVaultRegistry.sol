// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TrustVaultRegistry is Ownable {
    struct Proof {
        bytes32 contentHash;
        bytes32 vectorHash;
        address creator;
        uint256 timestamp;
        string metadataURI;
        // bool exists;
    }

    mapping (bytes32 => Proof) public proofs;

    mapping (uint256 => bytes32) public idToHash; // For easy Id Lookup
    uint256 public proofCount;

    event ProofRegistered(uint256 indexed id, bytes32 indexed contentHash, bytes32 vectorHash, address indexed creator, uint256 timestamp, string metadataURI);

    constructor() Ownable(msg.sender) {}

    function registerProof(bytes32 contentHash, bytes32 vectorHash, string calldata metadataURI) external {
        require(contentHash != bytes32(0), "Invalid content hash");
        require(vectorHash != bytes32(0), "Invalid vector hash");

        require(proofs[contentHash].creator == address(0), "Proof already registered");

        uint256 id = proofCount++;
        proofs[contentHash] = Proof({
            contentHash: contentHash,
            vectorHash: vectorHash,
            creator: msg.sender,
            timestamp: block.timestamp,
            metadataURI: metadataURI
        });
        idToHash[id] = contentHash;

        emit ProofRegistered(id, contentHash, vectorHash, msg.sender, block.timestamp, metadataURI);
    }

    function verifyHash(bytes32 contentHash) external view returns (bool exists, address creator, uint256 timestamp) {
        Proof memory proof = proofs[contentHash];
        exists = (proof.creator != address(0));
        creator = proof.creator;
        timestamp = proof.timestamp;
    }

    function getProofById(uint256 id) external view returns (Proof memory) {
        require(id < proofCount, "Invalid proof ID");
        bytes32 contentHash = idToHash[id];
        return proofs[contentHash];
    }
}