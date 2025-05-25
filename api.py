from fastapi import FastAPI
from datetime import datetime

app = FastAPI()

@app.get("/health")
async def health():
    """
    Health check endpoint.
    Returns the current server time.
    """
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}