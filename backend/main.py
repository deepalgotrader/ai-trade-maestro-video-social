from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import json
import os
from pathlib import Path

app = FastAPI(title="AI TradeMaestro API", version="1.0.0")

config_path = Path(__file__).parent / "config.json"
with open(config_path, 'r') as f:
    config = json.load(f)

origins = [
    config["urls"]["frontend"]["dev"],
    config["urls"]["frontend"]["production"],
    "http://localhost:3000",
    "https://aitrademaestro.com"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class MessageRequest(BaseModel):
    message: str

class MessageResponse(BaseModel):
    response: str
    status: str = "success"

@app.get("/")
async def root():
    return {"message": "AI TradeMaestro API", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "AI TradeMaestro API"}

@app.post("/api/chat", response_model=MessageResponse)
async def chat(request: MessageRequest):
    if not request.message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    response_text = f"You sent: {request.message}. This is a simple echo response from the API."

    return MessageResponse(response=response_text)

@app.get("/api/config")
async def get_config():
    return {
        "app_name": config["app"]["name"],
        "version": config["app"]["version"],
        "description": config["app"]["description"]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)