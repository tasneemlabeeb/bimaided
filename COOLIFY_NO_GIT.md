# 🚀 Deploy BIMSync Portal to Coolify - Simple Dockerfile Method (No Git)

## ✨ Easiest Method - Direct Dockerfile Deployment

This guide shows you how to deploy **without GitHub/Git** using Coolify's Dockerfile option.

---

## 📋 Prerequisites

1. **Coolify installed** on your server
2. **SSH access** to your server
3. **Your project files** ready

---

## 🎯 Method: Direct Dockerfile Deployment

### Step 1: Transfer Your Project to Server

**Option A: Using SCP (from your laptop)**
```bash
# Compress your project (exclude node_modules)
cd /Users/tasneemzaman/Desktop/Untitled
tar --exclude='node_modules' --exclude='.next' --exclude='.git' -czf bimsync-portal.tar.gz .

# Copy to server
scp bimsync-portal.tar.gz root@YOUR_SERVER_IP:/root/

# SSH to server
ssh root@YOUR_SERVER_IP

# Extract
cd /root
tar -xzf bimsync-portal.tar.gz -C bimsync-portal
cd bimsync-portal
```

**Option B: Using SFTP (if you prefer GUI)**
- Use FileZilla, Cyberduck, or any SFTP client
- Connect to your server
- Upload entire project folder to `/root/bimsync-portal`
- Exclude: `node_modules`, `.next`, `.git`

---

### Step 2: Build Docker Image on Server

```bash
# SSH to your server
ssh root@YOUR_SERVER_IP

# Navigate to project
cd /root/bimsync-portal

# Build the Docker image
docker build -t bimsync-portal:latest .

# Verify image was built
docker images | grep bimsync
```

---

### Step 3: Add to Coolify Dashboard

#### 3.1: In Coolify Dashboard

1. Click **"+ New"** → **"Resource"**

2. Choose **"Docker Based"** section

3. Select **"Docker Image"**

4. Fill in the form:
   ```
   ┌─────────────────────────────────────────┐
   │ Image Name: bimsync-portal:latest      │
   │                                         │
   │ Port: 3000                              │
   │                                         │
   │ Registry: (leave empty - local image)  │
   └─────────────────────────────────────────┘
   ```

5. Click **"Continue"**

---

### Step 4: Configure Environment Variables

In the next screen, add your environment variables:

```
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
```

Click **"Save"**

---

### Step 5: Deploy!

1. Click **"Deploy"** button

2. Coolify will:
   - ✅ Use your local Docker image
   - ✅ Create container
   - ✅ Start application
   - ✅ Assign URL

3. Wait 1-2 minutes

4. Click the generated URL to access your app!

---

## 🔄 Alternative: Docker Compose Method

If you prefer using docker-compose directly:

### Step 1: Create docker-compose.yml on Server

```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# Create project directory
mkdir -p /root/bimsync-portal
cd /root/bimsync-portal

# Upload your files here using SCP or SFTP
```

### Step 2: Use Coolify's Docker Compose Option

1. In Coolify Dashboard: **"+ New"** → **"Docker Compose Empty"**

2. Paste your docker-compose.yml content:
   ```yaml
   version: '3.8'
   
   services:
     bimsync-portal:
       build:
         context: /root/bimsync-portal
         dockerfile: Dockerfile
       ports:
         - "3000:3000"
       environment:
         - NODE_ENV=production
         - NEXT_PUBLIC_SUPABASE_URL=${NEXT_PUBLIC_SUPABASE_URL}
         - NEXT_PUBLIC_SUPABASE_ANON_KEY=${NEXT_PUBLIC_SUPABASE_ANON_KEY}
       restart: unless-stopped
   ```

3. Add environment variables in Coolify

4. Click **"Deploy"**

---

## 🎯 Simplest Method - Manual Docker Run (No Coolify UI)

If you want even simpler, just use Docker directly:

```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# Navigate to project
cd /root/bimsync-portal

# Build
docker build -t bimsync-portal .

# Run
docker run -d \
  --name bimsync-portal \
  -p 3000:3000 \
  -e NEXT_PUBLIC_SUPABASE_URL="your_supabase_url" \
  -e NEXT_PUBLIC_SUPABASE_ANON_KEY="your_anon_key" \
  -e NODE_ENV=production \
  --restart unless-stopped \
  bimsync-portal

# Check status
docker ps

# View logs
docker logs -f bimsync-portal

# Access your app
# http://YOUR_SERVER_IP:3000
```

Then optionally add it to Coolify:
1. Go to Coolify Dashboard
2. **"+ New"** → **"Docker Image"**
3. Use image name: `bimsync-portal:latest`
4. Coolify will manage the existing container

---

## 📦 File Transfer Helper Script

Create this on your laptop to easily upload:

```bash
#!/bin/bash
# upload-to-server.sh

SERVER_IP="YOUR_SERVER_IP"
SERVER_USER="root"

echo "📦 Compressing project..."
tar --exclude='node_modules' \
    --exclude='.next' \
    --exclude='.git' \
    --exclude='*.log' \
    -czf bimsync-portal.tar.gz .

echo "📤 Uploading to server..."
scp bimsync-portal.tar.gz $SERVER_USER@$SERVER_IP:/root/

echo "🚀 Extracting on server..."
ssh $SERVER_USER@$SERVER_IP << 'EOF'
  cd /root
  rm -rf bimsync-portal
  mkdir bimsync-portal
  tar -xzf bimsync-portal.tar.gz -C bimsync-portal
  cd bimsync-portal
  echo "✅ Files ready at /root/bimsync-portal"
EOF

echo "🧹 Cleaning up..."
rm bimsync-portal.tar.gz

echo "✅ Upload complete!"
echo "Next: SSH to server and build Docker image"
```

Make it executable:
```bash
chmod +x upload-to-server.sh
./upload-to-server.sh
```

---

## 🔄 Update Your App (Without Git)

When you make changes:

### Method 1: Upload New Files
```bash
# On your laptop
./upload-to-server.sh

# On server
ssh root@YOUR_SERVER_IP
cd /root/bimsync-portal
docker build -t bimsync-portal:latest .
docker stop bimsync-portal
docker rm bimsync-portal
docker run -d --name bimsync-portal -p 3000:3000 \
  -e NEXT_PUBLIC_SUPABASE_URL="..." \
  -e NEXT_PUBLIC_SUPABASE_ANON_KEY="..." \
  bimsync-portal
```

### Method 2: Use Coolify Rebuild
If you added it to Coolify:
1. Upload new files to server
2. In Coolify Dashboard → Your App
3. Click **"Rebuild"**
4. Done!

---

## 📊 Comparison of Methods

| Method | Difficulty | Updates | Best For |
|--------|-----------|---------|----------|
| **Dockerfile (Recommended)** | ⭐⭐ | Manual upload | You! |
| **Docker Compose** | ⭐⭐ | Manual upload | Multiple services |
| **Manual Docker Run** | ⭐ | Manual rebuild | Quick testing |
| **Git (not wanted)** | ⭐ | Automatic | CI/CD needed |

---

## ✅ Complete Workflow (Recommended for You)

### Initial Setup (One Time):

```bash
# 1. On your laptop - Upload files
tar --exclude='node_modules' --exclude='.next' -czf bimsync.tar.gz .
scp bimsync.tar.gz root@YOUR_SERVER_IP:/root/

# 2. On server - Build and run
ssh root@YOUR_SERVER_IP
cd /root && tar -xzf bimsync.tar.gz -C bimsync-portal
cd bimsync-portal
docker build -t bimsync-portal .
```

### In Coolify Dashboard:

```
1. "+ New" → "Docker Image"
2. Image: bimsync-portal:latest
3. Port: 3000
4. Add env vars
5. Deploy
```

### When You Need to Update:

```bash
# Upload new code
scp -r /Users/tasneemzaman/Desktop/Untitled/* root@YOUR_SERVER_IP:/root/bimsync-portal/

# Rebuild in Coolify
# Dashboard → Your App → "Rebuild"
```

---

## 🎯 My Recommendation for You

**Use: "Docker Image" option in Coolify**

**Why:**
- ✅ No Git needed
- ✅ Simple file upload
- ✅ Coolify manages container
- ✅ Easy to update (just rebuild)
- ✅ All Coolify features (SSL, domains, logs)

**Steps:**
1. Upload files to server (SCP/SFTP)
2. Build Docker image on server
3. Add to Coolify using "Docker Image"
4. Let Coolify handle everything else

---

## 🆘 Quick Troubleshooting

**Can't upload files?**
```bash
# Check SSH access
ssh root@YOUR_SERVER_IP

# Try with password if key fails
scp -o PreferredAuthentications=password bimsync.tar.gz root@YOUR_SERVER_IP:/root/
```

**Build fails?**
```bash
# Check Dockerfile exists
ls -la Dockerfile

# Check Docker is running
docker ps

# View build logs
docker build -t bimsync-portal . 2>&1 | tee build.log
```

**Container won't start?**
```bash
# Check logs
docker logs bimsync-portal

# Check port is free
netstat -tlnp | grep 3000

# Check environment variables
docker exec bimsync-portal env
```

---

## 🎉 You're Done!

Your app is now running without any Git involvement!

**Access:**
- Direct: `http://YOUR_SERVER_IP:3000`
- Via Coolify: `http://xxx.sslip.io` (auto-generated)
- Custom domain: Add in Coolify settings

**To update:** Just upload new files and rebuild!

Simple and effective! 🚀
