# Racing Run Backend API

This is the Vercel-hosted backend API for Racing Run, providing cloud storage, leaderboards, authentication, and content delivery.

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- Vercel account
- Vercel Postgres database
- Vercel Blob storage

### Local Development

1. Install dependencies:
```bash
cd backend
npm install
```

2. Set up environment variables (copy `.env.example` to `.env`):
```bash
cp .env.example .env
```

3. Configure your `.env` file with:
   - `POSTGRES_URL` - Your Vercel Postgres connection string
   - `BLOB_READ_WRITE_TOKEN` - Your Vercel Blob storage token
   - `JWT_SECRET` - A secure random string for JWT signing

4. Run the development server:
```bash
npm run dev
```

The API will be available at `http://localhost:3000`

### Deploying to Vercel

1. Install Vercel CLI:
```bash
npm install -g vercel
```

2. Deploy:
```bash
vercel
```

3. Set up environment variables in Vercel dashboard:
   - Go to your project settings
   - Add all environment variables from `.env.example`

4. Initialize the database (one-time setup):
```bash
curl -X POST "https://your-deployment.vercel.app/api/init-db?secret=YOUR_SECRET"
```

## 📚 API Endpoints

### Authentication

#### `POST /api/auth/register`
Register a new user.

**Request:**
```json
{
  "email": "user@example.com",
  "username": "player1",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "username": "player1"
  },
  "token": "jwt-token"
}
```

#### `POST /api/auth/login`
Login an existing user.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "user": { ... },
  "token": "jwt-token"
}
```

#### `GET /api/auth/me`
Get current user details (requires authentication).

**Headers:**
```
Authorization: Bearer {token}
```

### Characters

#### `GET /api/characters`
Get all characters for authenticated user.

**Headers:**
```
Authorization: Bearer {token}
```

#### `POST /api/characters`
Create a new character.

**Headers:**
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Form Data:**
- `name`: Character name
- `image`: Image file (PNG/JPEG)

#### `DELETE /api/characters/:id`
Delete a character.

**Headers:**
```
Authorization: Bearer {token}
```

### Scores & Leaderboard

#### `POST /api/scores`
Submit a new score.

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{
  "characterId": "uuid",
  "score": 5000,
  "distance": 1250,
  "gameMode": "endless"
}
```

#### `GET /api/scores`
Get user's scores.

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `limit` (optional): Number of scores to return (default: 20)

#### `GET /api/leaderboard`
Get global leaderboard.

**Query Parameters:**
- `limit` (optional): Number of entries (default: 10, max: 100)
- `offset` (optional): Pagination offset (default: 0)
- `gameMode` (optional): Filter by game mode (default: "endless")

### Content

#### `GET /api/content`
Get available content (costumes, tracks, challenges).

**Query Parameters:**
- `type` (optional): Filter by type ("costume", "track", "challenge")

#### `GET /api/content/daily-challenge`
Get today's daily challenge.

### Face Processing

#### `POST /api/face/process`
Process and optimize a face image.

**Form Data:**
- `image`: Image file

**Returns:** Processed image (512x512 PNG)

#### `POST /api/face/moderate`
Check if an image passes content moderation.

**Form Data:**
- `image`: Image file

**Response:**
```json
{
  "approved": true,
  "message": "Image passed validation"
}
```

## 🗄️ Database Schema

### Users
- `id` (UUID, primary key)
- `email` (string, unique)
- `username` (string, unique)
- `password_hash` (string)
- `created_at` (timestamp)

### Characters
- `id` (UUID, primary key)
- `user_id` (UUID, foreign key)
- `name` (string)
- `image_url` (string)
- `created_at` (timestamp)
- `updated_at` (timestamp)

### Scores
- `id` (UUID, primary key)
- `user_id` (UUID, foreign key)
- `character_id` (UUID, foreign key, nullable)
- `score` (integer)
- `distance` (integer)
- `game_mode` (string)
- `created_at` (timestamp)

### Content
- `id` (UUID, primary key)
- `type` (string: "costume", "track", "challenge")
- `name` (string)
- `description` (text)
- `data_url` (string)
- `is_premium` (boolean)
- `created_at` (timestamp)

## 🔐 Security

- All sensitive endpoints require JWT authentication
- Passwords are hashed using bcrypt
- Image uploads are validated for type and size
- Content moderation available for user-generated images

## 📝 Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `POSTGRES_URL` | Vercel Postgres connection string | Yes |
| `BLOB_READ_WRITE_TOKEN` | Vercel Blob storage token | Yes |
| `JWT_SECRET` | Secret key for JWT signing | Yes |
| `INIT_DB_SECRET` | Secret for database initialization | Yes |
| `GOOGLE_CLOUD_VISION_API_KEY` | For advanced face processing | No |
| `MODERATECONTENT_API_KEY` | For content moderation | No |

## 🧪 Testing

To test the API locally:

```bash
# Register a user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","username":"testuser","password":"password123"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password123"}'

# Get leaderboard (no auth required)
curl http://localhost:3000/api/leaderboard?limit=10
```

## 📄 License

See parent project LICENSE
