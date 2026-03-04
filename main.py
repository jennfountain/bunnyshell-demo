from fastapi import FastAPI, HTTPException
from datetime import datetime
from typing import Optional
import redis.asyncio as redis
from contextlib import asynccontextmanager
import os

# Redis client will be initialized on startup
redis_client: Optional[redis.Redis] = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Initialize Redis connection
    global redis_client
    redis_url = os.getenv(
        "REDIS_URL", "redis://redis-thsbol.bunnyenv.com:6379")
    try:
        redis_client = await redis.from_url(
            redis_url,
            encoding="utf-8",
            decode_responses=True,
            max_connections=10
        )
        await redis_client.ping()
        print("✓ Redis connected successfully")
    except Exception as e:
        print(f"⚠ Redis connection failed: {e}")
        redis_client = None

    yield

    # Shutdown: Close Redis connection
    if redis_client:
        await redis_client.close()
        print("✓ Redis connection closed")


app = FastAPI(title="Bunnyshell Test API", lifespan=lifespan)


@app.get("/")
async def root():
    return {
        "message": "Hello from Dokploy! This is an update",
        "status": "running",
        "timestamp": datetime.now().isoformat()
    }


@app.get("/health")
async def health():
    redis_status = "disconnected"
    if redis_client:
        try:
            await redis_client.ping()
            redis_status = "connected"
        except Exception:
            redis_status = "error"

    return {
        "status": "healthy",
        "redis": redis_status
    }


@app.get("/info")
async def info():
    return {
        "app": "FastAPI Test App",
        "version": "1.0.0",
        "framework": "FastAPI"
    }


# Redis Cache Endpoints

@app.post("/cache/{key}")
async def set_cache(key: str, value: str, ttl: Optional[int] = None):
    """Set a value in Redis cache with optional TTL (time to live) in seconds"""
    if not redis_client:
        raise HTTPException(status_code=503, detail="Redis not available")

    try:
        if ttl:
            await redis_client.setex(key, ttl, value)
        else:
            await redis_client.set(key, value)

        return {
            "success": True,
            "key": key,
            "ttl": ttl
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Redis error: {str(e)}")


@app.get("/cache/{key}")
async def get_cache(key: str):
    """Get a value from Redis cache"""
    if not redis_client:
        raise HTTPException(status_code=503, detail="Redis not available")

    try:
        value = await redis_client.get(key)
        if value is None:
            raise HTTPException(status_code=404, detail="Key not found")

        return {
            "key": key,
            "value": value
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Redis error: {str(e)}")


@app.delete("/cache/{key}")
async def delete_cache(key: str):
    """Delete a key from Redis cache"""
    if not redis_client:
        raise HTTPException(status_code=503, detail="Redis not available")

    try:
        deleted = await redis_client.delete(key)
        if deleted == 0:
            raise HTTPException(status_code=404, detail="Key not found")

        return {
            "success": True,
            "key": key,
            "deleted": deleted
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Redis error: {str(e)}")


@app.get("/cache")
async def list_keys(pattern: str = "*"):
    """List all keys matching the pattern"""
    if not redis_client:
        raise HTTPException(status_code=503, detail="Redis not available")

    try:
        keys = await redis_client.keys(pattern)
        return {
            "pattern": pattern,
            "keys": keys,
            "count": len(keys)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Redis error: {str(e)}")


# Redis Counter Endpoints

@app.post("/counter/{key}/increment")
async def increment_counter(key: str, amount: int = 1):
    """Increment a counter by the specified amount"""
    if not redis_client:
        raise HTTPException(status_code=503, detail="Redis not available")

    try:
        new_value = await redis_client.incrby(key, amount)
        return {
            "key": key,
            "value": new_value,
            "incremented_by": amount
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Redis error: {str(e)}")


@app.post("/counter/{key}/decrement")
async def decrement_counter(key: str, amount: int = 1):
    """Decrement a counter by the specified amount"""
    if not redis_client:
        raise HTTPException(status_code=503, detail="Redis not available")

    try:
        new_value = await redis_client.decrby(key, amount)
        return {
            "key": key,
            "value": new_value,
            "decremented_by": amount
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Redis error: {str(e)}")


@app.get("/counter/{key}")
async def get_counter(key: str):
    """Get the current value of a counter"""
    if not redis_client:
        raise HTTPException(status_code=503, detail="Redis not available")

    try:
        value = await redis_client.get(key)
        if value is None:
            raise HTTPException(status_code=404, detail="Counter not found")

        return {
            "key": key,
            "value": int(value)
        }
    except HTTPException:
        raise
    except ValueError:
        raise HTTPException(
            status_code=400, detail="Value is not a valid integer")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Redis error: {str(e)}")
