# API Documentation

## Overview

The AI TradeMaestro API is built with FastAPI and provides RESTful endpoints for frontend communication. All endpoints return JSON responses and follow REST conventions.

## Base URLs

- **Development:** `http://localhost:8000`
- **Production:** `https://aitrademaestro.com/api`

## Authentication

Currently, the API does not require authentication. Future versions will implement JWT-based authentication.

## Content Types

- **Request:** `application/json`
- **Response:** `application/json`

## Error Handling

All endpoints follow consistent error response format:

```json
{
  "detail": "Error message describing what went wrong",
  "status_code": 400
}
```

### HTTP Status Codes

- `200` - Success
- `400` - Bad Request (invalid input)
- `404` - Not Found
- `422` - Validation Error
- `500` - Internal Server Error

## Endpoints

### Health Check

#### GET /health

Returns the health status of the API service.

**Response:**
```json
{
  "status": "healthy",
  "service": "AI TradeMaestro API"
}
```

**Example:**
```bash
curl http://localhost:8000/health
```

---

### API Root

#### GET /

Returns basic API information and version.

**Response:**
```json
{
  "message": "AI TradeMaestro API",
  "version": "1.0.0"
}
```

**Example:**
```bash
curl http://localhost:8000/
```

---

### Configuration

#### GET /api/config

Returns public application configuration data.

**Response:**
```json
{
  "app_name": "AI TradeMaestro",
  "version": "1.0.0",
  "description": "Modern AI Trading Platform"
}
```

**Example:**
```bash
curl http://localhost:8000/api/config
```

---

### Chat Interaction

#### POST /api/chat

Processes a chat message and returns a response.

**Request Body:**
```json
{
  "message": "string"
}
```

**Request Schema:**
- `message` (string, required): The user's input message. Cannot be empty or whitespace only.

**Response:**
```json
{
  "response": "string",
  "status": "success"
}
```

**Response Schema:**
- `response` (string): The API's response to the user's message
- `status` (string): Always "success" for successful requests

**Example Request:**
```bash
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, how are you?"}'
```

**Example Response:**
```json
{
  "response": "You sent: Hello, how are you?. This is a simple echo response from the API.",
  "status": "success"
}
```

**Error Responses:**

*Empty Message (400):*
```json
{
  "detail": "Message cannot be empty",
  "status_code": 400
}
```

*Invalid JSON (422):*
```json
{
  "detail": [
    {
      "loc": ["body", "message"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

## Request/Response Examples

### JavaScript/TypeScript Frontend

```typescript
// Chat API call
const sendMessage = async (message: string) => {
  try {
    const response = await fetch('/api/chat', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ message }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return data.response;
  } catch (error) {
    console.error('API call failed:', error);
    throw error;
  }
};

// Usage
sendMessage("Hello AI!")
  .then(response => console.log(response))
  .catch(error => console.error(error));
```

### Python Client Example

```python
import requests
import json

class AITradeMaestroClient:
    def __init__(self, base_url="http://localhost:8000"):
        self.base_url = base_url

    def health_check(self):
        response = requests.get(f"{self.base_url}/health")
        return response.json()

    def send_message(self, message: str):
        url = f"{self.base_url}/api/chat"
        payload = {"message": message}

        response = requests.post(url, json=payload)
        response.raise_for_status()

        return response.json()

# Usage
client = AITradeMaestroClient()
result = client.send_message("Hello API!")
print(result["response"])
```

### cURL Examples

```bash
# Health check
curl -X GET http://localhost:8000/health

# Get configuration
curl -X GET http://localhost:8000/api/config

# Send chat message
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Test message"}'

# Send message with special characters
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What about prices with $100 and €50?"}'
```

## Data Models

### MessageRequest

```typescript
interface MessageRequest {
  message: string;  // Required, non-empty string
}
```

**Validation Rules:**
- Must be a string
- Cannot be empty or whitespace only
- Maximum length: 10,000 characters (configurable)

### MessageResponse

```typescript
interface MessageResponse {
  response: string;  // The API's response text
  status: string;    // Always "success" for successful requests
}
```

### HealthResponse

```typescript
interface HealthResponse {
  status: string;   // "healthy" when service is operational
  service: string;  // Service identifier
}
```

### ConfigResponse

```typescript
interface ConfigResponse {
  app_name: string;     // Application name from config
  version: string;      // Application version
  description: string;  // Application description
}
```

## Rate Limiting

Currently, no rate limiting is implemented. Future versions will include:
- Rate limiting per IP address
- Different limits for authenticated vs anonymous users
- Configurable limits based on endpoint

## CORS Configuration

The API is configured to accept requests from:
- `http://localhost:3000` (development frontend)
- `https://aitrademaestro.com` (production frontend)
- Additional origins can be configured in `config.json`

## Future Endpoints

### Planned Authentication Endpoints

```
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/refresh
GET /api/auth/me
```

### Planned Chat History Endpoints

```
GET /api/chat/history
DELETE /api/chat/history
GET /api/chat/sessions
```

### Planned User Management Endpoints

```
POST /api/users/register
GET /api/users/profile
PUT /api/users/profile
DELETE /api/users/profile
```

## API Versioning

Currently using URL path versioning:
- `/api/v1/chat` (future)
- `/api/chat` (current, implicit v1)

Future versions will maintain backward compatibility for at least one major version.

## OpenAPI Documentation

Interactive API documentation is available at:
- **Development:** http://localhost:8000/docs
- **Production:** https://aitrademaestro.com/api/docs

The documentation includes:
- Interactive API testing
- Request/response schemas
- Example requests and responses
- Authentication requirements (when implemented)

## Testing the API

### Unit Tests

```python
# Run backend tests
cd backend
pytest tests/ -v
```

### Integration Tests

```bash
# Test health endpoint
curl -f http://localhost:8000/health

# Test chat endpoint
curl -f -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "test"}'
```

### Load Testing

```bash
# Install Apache Bench
sudo apt install apache2-utils

# Simple load test
ab -n 1000 -c 10 http://localhost:8000/health

# POST endpoint load test
ab -n 100 -c 5 -p chat_payload.json -T application/json \
   http://localhost:8000/api/chat
```

Where `chat_payload.json` contains:
```json
{"message": "Load test message"}
```

## Error Codes Reference

| Code | Description | Common Causes |
|------|-------------|---------------|
| 400 | Bad Request | Empty message, invalid input format |
| 404 | Not Found | Invalid endpoint URL |
| 405 | Method Not Allowed | Wrong HTTP method for endpoint |
| 422 | Unprocessable Entity | JSON validation errors |
| 500 | Internal Server Error | Server-side application errors |

## Best Practices

### For Frontend Developers

1. **Always handle errors:** Check response status codes
2. **Validate input:** Validate data before sending to API
3. **Use TypeScript:** Leverage type definitions for better development experience
4. **Handle loading states:** Show loading indicators during API calls
5. **Implement retry logic:** For network-related failures

### For API Consumers

1. **Check API version:** Ensure compatibility with current API version
2. **Monitor rate limits:** Be prepared for future rate limiting
3. **Handle timeouts:** Set appropriate timeout values
4. **Cache responses:** Cache static data like configuration
5. **Use HTTPS:** Always use HTTPS in production