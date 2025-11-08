# BIMSync Portal - Docker Deployment Guide

## 🚀 Quick Start with Docker

### Prerequisites
- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed (included with Docker Desktop)
- Your Supabase credentials

### Option 1: Using Docker Compose (Recommended)

1. **Create environment file**
   ```bash
   cp .env.example .env
   ```
   
2. **Edit `.env` with your credentials**
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Build and run**
   ```bash
   docker-compose up -d
   ```

4. **View logs**
   ```bash
   docker-compose logs -f
   ```

5. **Access the application**
   - Open browser: `http://localhost:3000`

6. **Stop the application**
   ```bash
   docker-compose down
   ```

### Option 2: Using Docker Commands

1. **Build the image**
   ```bash
   docker build -t bimsync-portal .
   ```

2. **Run the container**
   ```bash
   docker run -d \
     --name bimsync-portal \
     -p 3000:3000 \
     -e NEXT_PUBLIC_SUPABASE_URL=your_supabase_url \
     -e NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key \
     bimsync-portal
   ```

3. **View logs**
   ```bash
   docker logs -f bimsync-portal
   ```

4. **Stop the container**
   ```bash
   docker stop bimsync-portal
   docker rm bimsync-portal
   ```

## 🌐 Production Deployment Options

### 1. **Docker on VPS/Cloud Server**

**Recommended for**: Full control, cost-effective

**Providers**: DigitalOcean, AWS EC2, Google Cloud, Azure

**Steps**:
1. SSH into your server
2. Install Docker and Docker Compose
3. Clone your repository
4. Set up environment variables
5. Run `docker-compose up -d`
6. Set up Nginx as reverse proxy (optional)
7. Configure SSL with Let's Encrypt

### 2. **Vercel (Easiest for Next.js)**

**Recommended for**: Fastest deployment, serverless

**Steps**:
1. Push code to GitHub
2. Import project in Vercel dashboard
3. Add environment variables
4. Deploy automatically

**Pros**: 
- Zero configuration
- Automatic SSL
- CDN included
- Free tier available

### 3. **Railway.app**

**Recommended for**: Simple Docker deployment

**Steps**:
1. Connect GitHub repository
2. Railway auto-detects Dockerfile
3. Add environment variables
4. Deploy

### 4. **AWS ECS / Google Cloud Run**

**Recommended for**: Enterprise scale

**Steps**:
1. Push Docker image to registry (ECR/GCR)
2. Create service definition
3. Deploy container
4. Configure load balancer

## 🔧 Environment Variables

Create a `.env` file with these variables:

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# Optional
NODE_ENV=production
PORT=3000
```

## 📊 Docker Commands Cheat Sheet

```bash
# Build image
docker build -t bimsync-portal .

# Run container
docker run -d -p 3000:3000 --name bimsync-portal bimsync-portal

# View logs
docker logs -f bimsync-portal

# Stop container
docker stop bimsync-portal

# Remove container
docker rm bimsync-portal

# Remove image
docker rmi bimsync-portal

# View running containers
docker ps

# Enter container shell
docker exec -it bimsync-portal sh

# Docker Compose commands
docker-compose up -d        # Start services
docker-compose down         # Stop services
docker-compose logs -f      # View logs
docker-compose restart      # Restart services
docker-compose ps           # List services
```

## 🔒 Security Best Practices

1. **Never commit `.env` files**
2. **Use strong Supabase RLS policies**
3. **Enable HTTPS in production**
4. **Use secrets management for production**
5. **Keep Docker images updated**

## 🎯 Recommended Deployment Path

**For your project, I recommend:**

1. **Quick Testing**: Docker Compose locally
2. **Production**: Vercel (easiest) or Railway (Docker support)

### Why Vercel for Production?
- ✅ Built specifically for Next.js
- ✅ Free SSL certificates
- ✅ Global CDN
- ✅ Automatic deployments from GitHub
- ✅ Free tier generous enough for most projects
- ✅ No Docker knowledge required
- ✅ Preview deployments for each PR

### When to use Docker deployment?
- ✅ Need full control over infrastructure
- ✅ Running other services alongside
- ✅ Specific compliance requirements
- ✅ Custom server configurations needed

## 🚀 One-Line Deploy Commands

### Deploy to Vercel
```bash
npx vercel --prod
```

### Deploy with Docker Compose
```bash
docker-compose up -d --build
```

## 📝 Next Steps

1. Test locally with Docker
2. Push to GitHub
3. Deploy to Vercel or Railway
4. Configure custom domain
5. Set up analytics
6. Monitor performance

## 🆘 Troubleshooting

**Port already in use**
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9
```

**Docker build fails**
```bash
# Clean Docker cache
docker system prune -a
```

**Environment variables not working**
```bash
# Check container env
docker exec bimsync-portal env
```

Need help? Check the logs:
```bash
docker-compose logs -f
```
