import os
import certifi
import hashlib
from datetime import datetime
from uuid import uuid4
import numpy as np
from sentence_transformers import SentenceTransformer
from dotenv import load_dotenv
from uagents import Agent, Context, Model, Protocol
from uagents_core.contrib.protocols.chat import (
    ChatAcknowledgement,
    ChatMessage,
    EndSessionContent,
    StartSessionContent,
    TextContent,
    chat_protocol_spec,
)

# ----------------------------
# Environment setup
# ----------------------------
load_dotenv(".env.local")
os.environ["SSL_CERT_FILE"] = certifi.where()
os.environ["REQUESTS_CA_BUNDLE"] = certifi.where()

# ----------------------------
# Fingerprint logic
# ----------------------------
print("🔹 Loading MiniLM model...")
model = SentenceTransformer("all-MiniLM-L6-v2")
print("✅ Model loaded successfully!\n")

def generate_vector_hash(text: str) -> str:
    embedding = model.encode([text])[0]
    embedding = embedding / np.linalg.norm(embedding)
    return hashlib.sha256(embedding.tobytes()).hexdigest()

# ----------------------------
# Chat helpers
# ----------------------------
def create_text_chat(text: str, end_session: bool = False) -> ChatMessage:
    """Helper to construct a ChatMessage reply"""
    content = [TextContent(type="text", text=text)]
    if end_session:
        content.append(EndSessionContent(type="end-session"))
    return ChatMessage(timestamp=datetime.utcnow(), msg_id=uuid4(), content=content)

# ----------------------------
# Agent setup
# ----------------------------
SEED_PHRASE = "velvet-ocean-forest-sparkle-honey-wave-dawn-sunset"

agent = Agent(
    name="AI_Fingerprint_Agent",
    seed=SEED_PHRASE,
    port=8000,
    endpoint=["https://genitivally-fretful-adelynn.ngrok-free.dev"],
    readme_path="README_Agent.md",
)

# ----------------------------
# Chat protocol
# ----------------------------
chat_proto = Protocol(spec=chat_protocol_spec)

@chat_proto.on_message(ChatMessage)
async def handle_chat(ctx: Context, sender: str, msg: ChatMessage):
    # 1️⃣ Acknowledge the incoming message
    await ctx.send(
        sender,
        ChatAcknowledgement(
            timestamp=datetime.utcnow(),
            acknowledged_msg_id=msg.msg_id,
        ),
    )

    # 2️⃣ Greet on session start
    if any(isinstance(item, StartSessionContent) for item in msg.content):
        await ctx.send(sender, create_text_chat("👋 Hi! Send me a text to fingerprint."))

    # 3️⃣ Get the text and process
    text = msg.text()
    if not text:
        return

    try:
        vector_hash = generate_vector_hash(text)
        reply = f"🧠 Vector fingerprint hash:\n{vector_hash}"
    except Exception as e:
        ctx.logger.exception("Error generating fingerprint")
        reply = f"❌ Something went wrong: {e}"

    # 4️⃣ Send the reply
    await ctx.send(sender, create_text_chat(reply, end_session=True))
    ctx.logger.info(f"✅ Fingerprint sent for: {text[:50]}")

@chat_proto.on_message(ChatAcknowledgement)
async def handle_ack(ctx: Context, sender: str, msg: ChatAcknowledgement):
    # Optional: could be used for delivery confirmations
    pass

class ManifestResponse(Model):
    protocols: list[str]
    endpoints: list[str]
    description: str

@agent.on_rest_get("/.well-known/manifest.json", response=ManifestResponse)
async def manifest(ctx: Context):
    return ManifestResponse(
        protocols=["AgentChatProtocol:0.3.0"],
        endpoints=["https://genitivally-fretful-adelynn.ngrok-free.dev"],
        description="AI_Fingerprint_Agent — Computes unique vector hashes for input text using MiniLM embeddings."
    )

class StatusResponse(Model):
    status: str

@agent.on_rest_get("/status", response=StatusResponse)
async def status(ctx: Context):
    return StatusResponse(status="ok")


# ----------------------------
# Health check (for testing)
# ----------------------------
class HealthResponse(Model):
    status: str

@agent.on_rest_get("/health", response=HealthResponse)
async def health_check(ctx: Context):
    return HealthResponse(status="Agent is alive and chat-ready ✅")


# ----------------------------
# Include protocol
# ----------------------------
agent.include(chat_proto, publish_manifest=True)


# ----------------------------
# Run agent
# ----------------------------
if __name__ == "__main__":
    print(f"🚀 Agent running at: https://genitivally-fretful-adelynn.ngrok-free.dev")
    agent.run()