# 🎯 Coolify Deployment - Step by Step

## 📍 You Are Here → 🚀 Production in 30 Minutes

---

## PART 1: Prepare Your Server (10 mins)

### Step 1.1: Get a VPS Server
```
Recommended Providers:
├─ Hetzner      → €4/month   (Best value)
├─ DigitalOcean → $6/month   (Most popular)  
├─ Vultr        → $6/month   (Fast)
└─ Linode       → $5/month   (Reliable)

Minimum Requirements:
- 2GB RAM
- 2 CPU cores  
- Ubuntu 22.04
```

### Step 1.2: SSH into Server
```bash
ssh root@YOUR_SERVER_IP
```

### Step 1.3: Install Coolify
```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

**Wait 5-10 minutes for installation**

### Step 1.4: Access Coolify
```
Open browser: http://YOUR_SERVER_IP:8000

Create account:
- Email: your@email.com
- Password: (create strong password)
```

✅ **Part 1 Complete!** Coolify is running.

---

## PART 2: Prepare Your Code (5 mins)

### Step 2.1: Check Readiness
```bash
./check-coolify-ready.sh
```

### Step 2.2: Push to GitHub
```bash
# If not already done
git add .
git commit -m "Ready for Coolify deployment"
git push origin main
```

✅ **Part 2 Complete!** Code is on GitHub.

---

## PART 3: Deploy with Coolify (10 mins)

### Step 3.1: Create New Project

**In Coolify Dashboard:**

```
1. Click: "+ New" → "Project"
2. Name: BIMSync Portal
3. Click: "Create"
```

### Step 3.2: Add Application

```
1. Click: "+ New Resource" → "Public Repository"

2. Fill Form:
   ┌─────────────────────────────────────────┐
   │ Repository URL:                         │
   │ https://github.com/tasneemlabeeb/       │
   │ bimsync-portal                          │
   │                                         │
   │ Branch: main                            │
   │                                         │
   │ Build Pack: Dockerfile                  │
   │                                         │
   │ Port: 3000                              │
   └─────────────────────────────────────────┘

3. Click: "Continue"
```

### Step 3.3: Configure Environment

```
Click: "Environment Variables" → "+ Add"

Add these:
┌──────────────────────────────────────────────┐
│ Name: NEXT_PUBLIC_SUPABASE_URL              │
│ Value: https://xxx.supabase.co              │
├──────────────────────────────────────────────┤
│ Name: NEXT_PUBLIC_SUPABASE_ANON_KEY         │
│ Value: eyJxxx...                            │
├──────────────────────────────────────────────┤
│ Name: NODE_ENV                              │
│ Value: production                           │
└──────────────────────────────────────────────┘

Click: "Save"
```

### Step 3.4: Deploy!

```
Click: "Deploy" button

Watch the build logs:
✓ Cloning repository...
✓ Building Docker image...  
✓ Starting container...
✓ Application running!
```

### Step 3.5: Get Your URL

```
After deployment:
- Coolify shows: http://xxx.YOUR_SERVER_IP.sslip.io
- Or: http://YOUR_SERVER_IP:3000

Click the URL to test!
```

✅ **Part 3 Complete!** App is live!

---

## PART 4: Add Custom Domain (5 mins) - OPTIONAL

### Step 4.1: Configure DNS

**In your domain provider (Namecheap, GoDaddy, etc.):**

```
Add A Record:
┌─────────────────────────────────┐
│ Type:  A                        │
│ Name:  bimsync (or @)           │
│ Value: YOUR_SERVER_IP           │
│ TTL:   Automatic                │
└─────────────────────────────────┘

Save changes.
```

### Step 4.2: Add Domain to Coolify

**In Coolify Dashboard:**

```
1. Go to: Your App → "Domains"

2. Click: "+ Add Domain"

3. Enter: bimsync.yourdomain.com

4. Click: "Add"

5. Toggle: "Generate SSL Certificate" → ON

Wait 5-10 minutes for:
✓ DNS propagation
✓ SSL certificate generation
```

### Step 4.3: Access Your Site

```
Visit: https://bimsync.yourdomain.com

You should see:
✓ Your BIMSync Portal
✓ Green lock (SSL active)
```

✅ **Part 4 Complete!** Custom domain with SSL!

---

## 🎉 DEPLOYMENT COMPLETE!

### Your BIMSync Portal is now:
- ✅ Running in production
- ✅ Using Docker
- ✅ Auto-updating from GitHub
- ✅ SSL encrypted (if domain added)
- ✅ Monitored by Coolify

---

## 🔄 Enable Auto-Deploy

```
In Coolify Dashboard:

1. Go to: Your App → "General"

2. Find: "Auto Deploy"

3. Toggle: ON

4. Copy webhook URL

5. Go to GitHub:
   - Settings → Webhooks → Add webhook
   - Paste Coolify webhook URL
   - Content type: application/json
   - Events: Just push events

Now every git push deploys automatically! 🚀
```

---

## 📊 Monitor Your App

### View Logs
```
Coolify → Your App → "Logs"
- Build logs
- Application logs  
- Error tracking
```

### Check Resources
```
Coolify → Your App → "Resources"
- CPU usage
- Memory usage
- Network traffic
```

### Manage Deployments
```
Coolify → Your App → "Deployments"
- View history
- Rollback anytime
- See deployment times
```

---

## 🆘 Troubleshooting Quick Fix

### Build Failed?
```bash
# Check logs in Coolify
# Usually: missing env vars or wrong Dockerfile path
```

### App Not Loading?
```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# Check container
docker ps | grep bimsync

# View logs
docker logs <container-id>
```

### Domain Not Working?
```bash
# Check DNS propagation
nslookup bimsync.yourdomain.com

# Wait up to 24 hours
# Usually works in 5-10 minutes
```

---

## ✅ Success Checklist

- [ ] Coolify installed on server
- [ ] Code pushed to GitHub  
- [ ] App created in Coolify
- [ ] Environment variables added
- [ ] Deployed successfully
- [ ] App accessible via URL
- [ ] Domain configured (optional)
- [ ] SSL working (if domain added)
- [ ] Auto-deploy enabled

**All checked? You're done! 🎉**

---

## 🎯 What You Achieved

```
Before:  Code on laptop
Now:     Live production app!

Infrastructure:
├─ VPS Server (your own)
├─ Docker container  
├─ Coolify managing everything
├─ SSL certificate
├─ Auto-deployments
└─ Monitoring & logs

Total time: ~30 minutes
Total cost: ~$5/month
Total awesomeness: 💯
```

---

## 📚 Learn More

- Full guide: `COOLIFY_DEPLOYMENT.md`
- Coolify docs: https://coolify.io/docs
- Need help? Check logs or Coolify Discord

**Congratulations! Your BIMSync Portal is live! 🚀**
