# FastAPI Dokploy Test App

A simple FastAPI application for testing Dokploy deployment.

## Endpoints

- `GET /` - Welcome message with timestamp
- `GET /health` - Health check endpoint
- `GET /info` - Application information

## Local Development

1. Install dependencies:
```bash
pip install --index-url https://pypi.org/simple -r requirements.txt
```

2. Run the app:
```bash
uvicorn main:app --reload
```

3. Visit: http://localhost:8000

## Docker

Build and run with Docker:
```bash
docker build -t fastapi-dokploy-test .
docker run -p 8000:8000 fastapi-dokploy-test
```

## Dokploy Deployment

1. Create a new service in Dokploy
2. Connect your Git repository
3. Dokploy will automatically detect the Dockerfile and deploy
4. The app will be available on port 8000
