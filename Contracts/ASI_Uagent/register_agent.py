import os
from uagents_core.utils.registration import (
    register_chat_agent,
    RegistrationRequestCredentials,
)
from dotenv import load_dotenv
load_dotenv('.env.local')

register_chat_agent(
    "AI_Fingerprint_Agent",
    "https://genitivally-fretful-adelynn.ngrok-free.dev",
    active=True,
    credentials=RegistrationRequestCredentials(
        agentverse_api_key=os.environ["AGENTVERSE_KEY"],
        agent_seed_phrase=os.environ["AGENT_SEED_PHRASE"],
    ),
)