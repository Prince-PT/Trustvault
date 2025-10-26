# 🧠 TrustVault Vector Fingerprinting Agent

### Agent Name:
**TrustVaultVectorAgent**

### Description:
This agent generates **semantic AI fingerprints** for uploaded files or text using vector embeddings.  
It converts content into a **numerical vector** and a **unique cryptographic hash**, enabling originality tracking and AI-based content verification inside **TrustVault**.

### How It Works:
1. User (or another agent) sends a message containing text or extracted content from a file.  
2. The agent encodes it into a semantic vector (MiniLM or any supported model).  
3. It computes a vector hash using SHA-256.  
4. Returns both the vector and hash to the requester.

### Run Instructions:
```bash
pip install -r requirements.txt
python3 vector_fingerprint_agent.py
