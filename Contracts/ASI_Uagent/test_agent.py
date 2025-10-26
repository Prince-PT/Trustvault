from uagents import Agent, Context, Model

class HealthResponse(Model):
    status: str

agent = Agent(
    name="HealthTestAgent",
    seed="banana-pixel-sunset",
    port=8000,
    endpoint=["http://localhost:8000"],
)

@agent.on_rest_get("/health", response=HealthResponse)
async def health(ctx: Context):
    return HealthResponse(status="Agent is alive ✅")

if __name__ == "__main__":
    agent.run()