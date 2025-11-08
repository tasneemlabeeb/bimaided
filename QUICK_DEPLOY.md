# 🚀 Quick Deploy - BIMSync Portal

## Fastest Way to Deploy

### Option 1: Using Deploy Script (Easiest)
```bash
./deploy.sh
```

### Option 2: Using Docker Compose
```bash
# 1. Create .env file with your Supabase credentials
cp .env.example .env

# 2. Build and run
docker-compose up -d

# 3. Access at http://localhost:3000
```

### Option 3: Deploy to Vercel (Recommended for Production)
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

---

## Deployment Comparison

| Method | Difficulty | Cost | Best For |
|--------|-----------|------|----------|
| **Vercel** | ⭐ Easy | Free tier | Production (Recommended) |
| **Railway** | ⭐⭐ Medium | $5/month | Docker + Database |
| **Docker VPS** | ⭐⭐⭐ Hard | $5-20/month | Full control |
| **Docker Local** | ⭐ Easy | Free | Testing |

---

## My Recommendation for You

### For Production: **Vercel**
- Deploy in 2 minutes
- Free SSL + CDN
- Automatic from GitHub
- No server management

### Steps:
1. Push to GitHub
2. Go to vercel.com
3. Import repository
4. Add environment variables
5. Deploy ✅

---

## Common Commands

```bash
# Test locally with Docker
docker-compose up

# Stop
docker-compose down

# View logs
docker-compose logs -f

# Rebuild
docker-compose up --build
```

---

## Need Help?
- Read: `DEPLOYMENT_GUIDE.md`
- Run: `./deploy.sh`
- Deploy: `vercel --prod`
