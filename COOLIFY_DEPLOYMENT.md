# 🚀 Deploying BIMSync Portal to Coolify

## What is Coolify?

Coolify is a self-hosted Heroku/Vercel alternative that makes deploying applications incredibly easy. It handles Docker deployment, SSL certificates, domains, and monitoring automatically.

---

## 📋 Prerequisites

1. **A server** (VPS) with:
   - Ubuntu 22.04 or Debian 11+ (recommended)
   - Minimum 2GB RAM, 2 CPU cores
   - Root access
   - Providers: DigitalOcean, Hetzner, Vultr, Linode, etc.

2. **Domain name** (optional but recommended)
   - Point your domain to your server's IP

---

## 🛠️ Step 1: Install Coolify on Your Server

### SSH into your server:
```bash
ssh root@your-server-ip
```

### Install Coolify (one command):
```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

**This will:**
- Install Docker
- Install Coolify
- Set up the dashboard
- Configure networking

**Installation takes 5-10 minutes.**

### After installation:
- Access Coolify at: `http://your-server-ip:8000`
- Or: `http://coolify.yourdomain.com` (if you set up DNS)

### First time setup:
1. Create admin account
2. Set up email (optional)
3. Configure your server

---

## 🚢 Step 2: Deploy BIMSync Portal via Coolify Dashboard

### Method A: Deploy from GitHub (Recommended)

#### 1. **Push your code to GitHub**
```bash
# In your project directory
git add .
git commit -m "Ready for Coolify deployment"
git push origin main
```

#### 2. **In Coolify Dashboard:**

1. Click **"+ New"** → **"Public Repository"**

2. **Fill in the details:**
   ```
   Repository URL: https://github.com/tasneemlabeeb/bimsync-portal
   Branch: main
   Build Pack: Dockerfile
   ```

3. **Port Configuration:**
   ```
   Port: 3000
   ```

4. **Environment Variables** (Click "Add Environment Variable"):
   ```
   NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
   NODE_ENV=production
   ```

5. **Click "Deploy"**

Coolify will:
- ✅ Clone your repository
- ✅ Build using your Dockerfile
- ✅ Start the container
- ✅ Assign a domain
- ✅ Generate SSL certificate (if domain configured)

---

### Method B: Deploy via Git (Manual)

#### 1. **In Coolify Dashboard:**

1. Go to **"+ New"** → **"Git Repository"**

2. **Add Source:**
   - Type: GitHub/GitLab/Gitea
   - Connect your account

3. **Select Repository:**
   - Choose: `bimsync-portal`
   - Branch: `main`

4. **Configure:**
   - Build Pack: Dockerfile
   - Port: 3000
   - Dockerfile path: `./Dockerfile` (default)

5. **Environment Variables:**
   Add your Supabase credentials

6. **Deploy!**

---

## 🔧 Step 3: Configure Domain & SSL

### In Coolify Dashboard:

1. **Go to your application** → **Domains**

2. **Add your domain:**
   ```
   bimsync.yourdomain.com
   ```

3. **SSL Certificate:**
   - Coolify auto-generates Let's Encrypt SSL
   - Certificate renews automatically

4. **DNS Setup** (in your domain provider):
   ```
   Type: A Record
   Name: bimsync (or @)
   Value: your-server-ip
   ```

**Wait 5-10 minutes for DNS propagation**

Your app will be live at: `https://bimsync.yourdomain.com`

---

## 📊 Coolify Features You'll Love

### 1. **Auto-Deploy on Git Push**
- Enable "Auto Deploy" in settings
- Every push to `main` triggers deployment

### 2. **Logs & Monitoring**
```
Dashboard → Your App → Logs
```
- Real-time build logs
- Container logs
- Error tracking

### 3. **Easy Rollbacks**
```
Dashboard → Your App → Deployments
```
- View all deployments
- Rollback to any previous version
- One-click restore

### 4. **Environment Management**
- Separate environments (staging/production)
- Environment variable management
- Secrets encryption

---

## 🐳 Dockerfile Optimization for Coolify

Your current Dockerfile is already perfect for Coolify! But here's a checklist:

### ✅ Verified in your Dockerfile:
```dockerfile
✅ Multi-stage build (smaller image)
✅ Standalone output configured
✅ Port 3000 exposed
✅ Node 20 Alpine (lightweight)
✅ Production optimizations
```

---

## 🎯 Complete Deployment Checklist

### Before Deploying:

- [ ] Code pushed to GitHub
- [ ] `.env` values ready (Supabase credentials)
- [ ] Coolify installed on server
- [ ] Domain DNS configured (optional)

### Deploy Steps:

- [ ] Create new app in Coolify
- [ ] Connect GitHub repository
- [ ] Set build pack to "Dockerfile"
- [ ] Add environment variables
- [ ] Configure port 3000
- [ ] Deploy!

### After Deployment:

- [ ] Check build logs
- [ ] Verify application is running
- [ ] Test the URL
- [ ] Configure custom domain
- [ ] Enable auto-deploy
- [ ] Set up monitoring

---

## 🔥 Quick Deploy Commands

### From Server Terminal:

If you prefer CLI over dashboard:

```bash
# SSH to server
ssh root@your-server-ip

# Clone repository
git clone https://github.com/tasneemlabeeb/bimsync-portal.git
cd bimsync-portal

# Build image
docker build -t bimsync-portal .

# Run container
docker run -d \
  --name bimsync-portal \
  -p 3000:3000 \
  -e NEXT_PUBLIC_SUPABASE_URL=your_url \
  -e NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key \
  --restart unless-stopped \
  bimsync-portal
```

**Then add it to Coolify:**
1. Go to Coolify Dashboard
2. "Add Existing Container"
3. Select `bimsync-portal`
4. Configure domain & SSL

---

## 🔍 Troubleshooting

### Build Fails?

**Check logs:**
```
Coolify Dashboard → Your App → Logs → Build Logs
```

**Common issues:**
1. Missing environment variables
2. Wrong Dockerfile path
3. Port configuration

### App Not Accessible?

**Verify:**
```bash
# Check container status
docker ps | grep bimsync

# Check logs
docker logs bimsync-portal

# Check port
netstat -tlnp | grep 3000
```

### DNS Not Working?

**Check DNS propagation:**
```bash
nslookup bimsync.yourdomain.com
```

Wait up to 24 hours for full propagation

---

## 💡 Pro Tips

### 1. **Use Webhooks**
Enable auto-deploy on git push:
```
Coolify → Your App → Settings → Webhooks
```
Add webhook URL to GitHub repository settings

### 2. **Health Checks**
Add health check endpoint in your Next.js app:
```typescript
// app/api/health/route.ts
export async function GET() {
  return Response.json({ status: 'ok' });
}
```

Configure in Coolify:
```
Health Check Path: /api/health
```

### 3. **Resource Limits**
```
Coolify → Your App → Resources
```
Set CPU/Memory limits for stability

### 4. **Backup Strategy**
Enable automatic backups:
```
Coolify → Settings → Backups
```

---

## 📈 Scaling Options

### Vertical Scaling:
```
Coolify → Your App → Resources
- Increase CPU
- Increase Memory
```

### Horizontal Scaling:
- Add more servers in Coolify
- Use load balancer
- Deploy multiple instances

---

## 🎁 Coolify vs Other Options

| Feature | Coolify | Vercel | Railway |
|---------|---------|--------|---------|
| Cost | $5-10/mo (VPS) | Free tier | $5/mo |
| Control | Full | Limited | Medium |
| Setup | 10 mins | 2 mins | 5 mins |
| SSL | Auto | Auto | Auto |
| Docker | ✅ Yes | ❌ No | ✅ Yes |
| Self-hosted | ✅ Yes | ❌ No | ❌ No |

**Choose Coolify if:**
- ✅ Want full control
- ✅ Multiple projects on one server
- ✅ Need custom configurations
- ✅ Want to save long-term costs

---

## 🆘 Need Help?

### Coolify Resources:
- Documentation: https://coolify.io/docs
- Discord: https://coollabs.io/discord
- GitHub: https://github.com/coollabsio/coolify

### Your Deployment:
```bash
# Check status
docker ps

# View logs
docker logs -f bimsync-portal

# Restart
docker restart bimsync-portal

# Update
git pull && docker-compose up -d --build
```

---

## ✅ Success Indicators

Your deployment is successful when:
- ✅ Build completes without errors
- ✅ Container shows "Running" status
- ✅ App accessible via domain/IP
- ✅ SSL certificate active (green lock)
- ✅ No errors in logs

**Expected deployment time: 5-10 minutes**

---

## 🎯 Next Steps After Deployment

1. ✅ Test all features
2. ✅ Set up monitoring
3. ✅ Configure backups
4. ✅ Enable auto-deploy
5. ✅ Set up analytics
6. ✅ Monitor performance

Your BIMSync Portal is now live! 🚀
