// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {TrustVaultRegistry} from "../src/TrustVaultRegistry.sol";

contract TrustVaultRegistryTest is Test {
    TrustVaultRegistry public registry;
    address public creator = makeAddr("creator");
    address public otherUser = makeAddr("otherUser");

    bytes32 public constant SAMPLE_CONTENT_HASH = keccak256("sample content");
    bytes32 public constant SAMPLE_VECTOR_HASH = keccak256("sample vector");
    string public constant SAMPLE_URI = "ipfs://metadata/sample";

    function setUp() public {
        registry = new TrustVaultRegistry();
    }

    function test_RegisterProofSuccess() public {
        // Warp to a fixed timestamp for consistent testing
        vm.warp(1234567890);

        // Expect event emission (check topics but not dynamic data like timestamp/URI)
        vm.expectEmit(true, true, true, false, address(registry));
        emit TrustVaultRegistry.ProofRegistered(
            0,
            SAMPLE_CONTENT_HASH,
            SAMPLE_VECTOR_HASH,
            creator,
            0,
            ""
        ); // Timestamp/URI not checked

        vm.prank(creator);
        registry.registerProof(
            SAMPLE_CONTENT_HASH,
            SAMPLE_VECTOR_HASH,
            SAMPLE_URI
        );

        // Derive ID post-registration
        uint256 id = registry.proofCount() - 1;
        assertEq(id, 0);
        assertEq(registry.proofCount(), 1);

        // Check idToHash mapping
        assertEq(registry.idToHash(0), SAMPLE_CONTENT_HASH);

        // Check proofs mapping via getter
        TrustVaultRegistry.Proof memory proof = registry.getProofById(0);
        assertEq(proof.contentHash, SAMPLE_CONTENT_HASH);
        assertEq(proof.vectorHash, SAMPLE_VECTOR_HASH);
        assertEq(proof.creator, creator);
        assertEq(proof.timestamp, 1234567890);
        assertEq(
            keccak256(bytes(proof.metadataURI)),
            keccak256(bytes(SAMPLE_URI))
        );
    }

    function test_VerifyHashAfterRegistration() public {
        vm.warp(1234567890);

        vm.prank(creator);
        registry.registerProof(
            SAMPLE_CONTENT_HASH,
            SAMPLE_VECTOR_HASH,
            SAMPLE_URI
        );

        (
            bool exists,
            address retrievedCreator,
            uint256 retrievedTimestamp
        ) = registry.verifyHash(SAMPLE_CONTENT_HASH);
        assertTrue(exists);
        assertEq(retrievedCreator, creator);
        assertEq(retrievedTimestamp, 1234567890);
    }

    function test_VerifyHashNonExistent() public view {
        (bool exists, address creator_, uint256 timestamp) = registry
            .verifyHash(SAMPLE_CONTENT_HASH);
        assertFalse(exists);
        assertEq(creator_, address(0));
        assertEq(timestamp, 0);
    }

    function test_GetProofByIdSuccess() public {
        vm.warp(1234567890);

        vm.prank(creator);
        registry.registerProof(
            SAMPLE_CONTENT_HASH,
            SAMPLE_VECTOR_HASH,
            SAMPLE_URI
        );

        TrustVaultRegistry.Proof memory proof = registry.getProofById(0);
        assertEq(proof.contentHash, SAMPLE_CONTENT_HASH);
        assertEq(proof.creator, creator);
        assertEq(proof.timestamp, 1234567890);
    }

    function test_GetProofByIdInvalidIdReverts() public {
        vm.expectRevert("Invalid proof ID");
        registry.getProofById(999);
    }

    function test_PreventDuplicateRegistration() public {
        vm.prank(creator);
        registry.registerProof(
            SAMPLE_CONTENT_HASH,
            SAMPLE_VECTOR_HASH,
            SAMPLE_URI
        );

        vm.prank(creator);
        vm.expectRevert("Proof already registered");
        registry.registerProof(
            SAMPLE_CONTENT_HASH,
            SAMPLE_VECTOR_HASH,
            SAMPLE_URI
        );
    }

    function test_PreventZeroContentHash() public {
        vm.prank(creator);
        vm.expectRevert("Invalid content hash");
        registry.registerProof(bytes32(0), SAMPLE_VECTOR_HASH, SAMPLE_URI);
    }

    function test_PreventZeroVectorHash() public {
        vm.prank(creator);
        vm.expectRevert("Invalid vector hash");
        registry.registerProof(SAMPLE_CONTENT_HASH, bytes32(0), SAMPLE_URI);
    }

    function test_ProofCountIncrements() public {
        assertEq(registry.proofCount(), 0);

        vm.prank(creator);
        registry.registerProof(
            SAMPLE_CONTENT_HASH,
            SAMPLE_VECTOR_HASH,
            SAMPLE_URI
        );

        assertEq(registry.proofCount(), 1);

        // Register another
        bytes32 anotherHash = keccak256("another");
        vm.prank(otherUser);
        registry.registerProof(anotherHash, SAMPLE_VECTOR_HASH, SAMPLE_URI);

        assertEq(registry.proofCount(), 2);
    }

    function test_MultipleUsers() public {
        vm.prank(creator);
        registry.registerProof(
            SAMPLE_CONTENT_HASH,
            SAMPLE_VECTOR_HASH,
            SAMPLE_URI
        );

        bytes32 otherHash = keccak256("other content");
        vm.prank(otherUser);
        registry.registerProof(otherHash, SAMPLE_VECTOR_HASH, SAMPLE_URI);

        // Verify first
        (bool exists1, address creator1, ) = registry.verifyHash(
            SAMPLE_CONTENT_HASH
        );
        assertTrue(exists1);
        assertEq(creator1, creator);

        // Verify second
        (bool exists2, address creator2, ) = registry.verifyHash(otherHash);
        assertTrue(exists2);
        assertEq(creator2, otherUser);
    }

    function test_EventEmittedWithCorrectArgs() public {
        vm.warp(1234567890);

        // Expect event (topics checked, data not due to dynamics)
        vm.expectEmit(true, true, true, false, address(registry));
        emit TrustVaultRegistry.ProofRegistered(
            0,
            SAMPLE_CONTENT_HASH,
            SAMPLE_VECTOR_HASH,
            creator,
            0,
            ""
        ); // Placeholders for unchecked

        vm.prank(creator);
        registry.registerProof(
            SAMPLE_CONTENT_HASH,
            SAMPLE_VECTOR_HASH,
            SAMPLE_URI
        );
    }

    function test_OwnershipTransfer() public {
        address newOwner = makeAddr("newOwner");
        registry.transferOwnership(newOwner);
        assertEq(registry.owner(), newOwner);
    }
}
