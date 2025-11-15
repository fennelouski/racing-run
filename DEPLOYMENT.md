# Deployment Guide

This guide walks you through deploying Racing Run's backend to Vercel and configuring the iOS app to connect to it.

## 📦 Backend Deployment to Vercel

### Step 1: Prerequisites

1. Create a [Vercel account](https://vercel.com/signup) (free tier works fine)
2. Install Vercel CLI:
```bash
npm install -g vercel
```

### Step 2: Set Up Vercel Project

1. Navigate to the backend directory:
```bash
cd backend
```

2. Link to Vercel (creates a new project):
```bash
vercel link
```

3. Follow the prompts to create a new project

### Step 3: Add Vercel Postgres

1. Go to your [Vercel Dashboard](https://vercel.com/dashboard)
2. Select your project
3. Go to **Storage** tab
4. Click **Create Database**
5. Select **Postgres**
6. Choose a name and region
7. Click **Create**

The environment variables (`POSTGRES_URL`, `POSTGRES_PRISMA_URL`, etc.) will be automatically added to your project.

### Step 4: Add Vercel Blob Storage

1. In your Vercel project dashboard
2. Go to **Storage** tab
3. Click **Create Database**
4. Select **Blob**
5. Choose a name
6. Click **Create**

The `BLOB_READ_WRITE_TOKEN` environment variable will be automatically added.

### Step 5: Add Custom Environment Variables

1. Go to **Settings** → **Environment Variables**
2. Add the following:

| Name | Value | Notes |
|------|-------|-------|
| `JWT_SECRET` | Generate with: `openssl rand -base64 32` | Required for auth |
| `INIT_DB_SECRET` | Any secure random string | For database initialization |

### Step 6: Deploy

```bash
vercel --prod
```

Your API will be deployed! Note the deployment URL (e.g., `https://racing-run-backend.vercel.app`).

### Step 7: Initialize Database

Run this once to create database tables:

```bash
curl -X POST "https://your-deployment.vercel.app/api/init-db?secret=YOUR_INIT_DB_SECRET"
```

Replace `YOUR_INIT_DB_SECRET` with the value you set in environment variables.

## 📱 iOS App Configuration

### Step 1: Update API Base URL

The iOS app needs to know your backend URL. You have two options:

#### Option A: Environment Variable (Recommended for Development)

1. In Xcode, select your target
2. Go to **Edit Scheme** → **Run** → **Arguments**
3. Add environment variable:
   - Name: `API_BASE_URL`
   - Value: `https://your-deployment.vercel.app`

#### Option B: Hard-code (For Production)

Edit `Racing Run/API/APIClient.swift`:

```swift
private let baseURL = "https://your-deployment.vercel.app"
```

### Step 2: Update Info.plist for Network Security

If using HTTP for local development, add to `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>your-deployment.vercel.app</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

For production (HTTPS), no changes needed!

### Step 3: Test the Connection

1. Run the app in simulator or device
2. Try to register a new account
3. Create a character
4. Check the leaderboard

## 🔍 Verifying Deployment

### Check API Health

```bash
# Test registration
curl -X POST https://your-deployment.vercel.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"password123"}'

# Check leaderboard (should return empty array initially)
curl https://your-deployment.vercel.app/api/leaderboard
```

### Monitor Logs

```bash
vercel logs --follow
```

Or view in the Vercel dashboard under **Deployments** → **Functions** → **Logs**.

## 🔧 Troubleshooting

### Database Connection Issues

- Verify `POSTGRES_URL` is set correctly
- Check Vercel Postgres is in the same region as your deployment
- Look for connection errors in function logs

### Blob Storage Upload Failures

- Verify `BLOB_READ_WRITE_TOKEN` is set
- Check file size limits (Vercel Blob has generous limits)
- Ensure correct permissions on the token

### CORS Issues

If testing from a web browser or different origin:

Add to `backend/next.config.js`:
```javascript
async headers() {
  return [
    {
      source: '/api/:path*',
      headers: [
        { key: 'Access-Control-Allow-Origin', value: '*' },
        { key: 'Access-Control-Allow-Methods', value: 'GET,POST,DELETE,OPTIONS' },
        { key: 'Access-Control-Allow-Headers', value: 'Content-Type, Authorization' },
      ],
    },
  ];
}
```

### iOS App Can't Connect

1. Check `API_BASE_URL` is correct
2. Verify network permissions in Info.plist
3. Check device/simulator has internet connection
4. Look for error messages in Xcode console

## 📊 Monitoring & Analytics

### Built-in Vercel Analytics

1. Go to your project in Vercel Dashboard
2. Click **Analytics** tab
3. View API request metrics, errors, and performance

### Custom Logging

The API logs errors to console. View with:

```bash
vercel logs
```

## 🚀 Updates & CI/CD

### Automatic Deployments

Connect your GitHub repository to Vercel for automatic deployments:

1. Go to Vercel Dashboard → **Settings** → **Git**
2. Connect your repository
3. Every push to `main` will automatically deploy

### Manual Deployments

```bash
# Deploy to production
vercel --prod

# Deploy to preview
vercel
```

## 💰 Cost Considerations

### Vercel Free Tier Includes:

- **Postgres**: 256MB storage, 60 hours compute/month
- **Blob**: 10GB storage, 100GB bandwidth
- **Functions**: 100GB-hours, 100K invocations
- **Bandwidth**: 100GB

This is **more than enough** for a small-to-medium sized game with thousands of players!

### Scaling Up

When you need more:
- **Pro Plan**: $20/month - 512MB Postgres, unlimited blob bandwidth
- **Enterprise**: Custom pricing for millions of players

## 📞 Support

- [Vercel Documentation](https://vercel.com/docs)
- [Vercel Support](https://vercel.com/support)
- Check Vercel Community for common issues

---

**Congratulations!** 🎉 Your Racing Run backend is now live and your iOS app is connected to the cloud!
