from dotenv import load_dotenv
import os

# Load the environment variables
load_dotenv('.env.local')

# Print the environment variables (but mask the sensitive data)
print("API_ASI_KEY:", "✓ Set" if os.getenv("API_ASI_KEY") else "✗ Not Set")
print("AGENTVERSE_KEY:", "✓ Set" if os.getenv("AGENTVERSE_KEY") else "✗ Not Set")
print("AGENT_SEED_PHRASE:", "✓ Set" if os.getenv("AGENT_SEED_PHRASE") else "✗ Not Set")