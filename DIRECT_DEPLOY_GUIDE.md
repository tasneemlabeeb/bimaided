# 🚀 Direct Server Build & Deploy Guide

## Overview
Upload your code to the server, build Docker image there, and deploy with Coolify.

**Total Time:** ~15 minutes  
**Difficulty:** ⭐⭐ Easy

---

## Step 1: Upload to Server (5 minutes)

### Run the upload script:

```bash
./upload-to-server.sh
```

You'll be asked for:
1. **Server IP** - Your Coolify server IP address
2. **SSH Username** - Usually `root`
3. **Destination path** - Default: `/root/bimsync-portal`

The script will:
- ✅ Compress your project (~20-30MB)
- ✅ Upload to server
- ✅ Extract files
- ✅ Show summary

**Expected output:**
```
✅ Archive created: bimsync-portal-20251108-143022.tar.gz (28M)
✅ Upload successful
✅ Extraction successful
🎉 Upload Complete!
```

---

## Step 2: Build on Server (3 minutes)

### SSH to your server:

```bash
ssh root@YOUR_SERVER_IP
```

### Navigate to project:

```bash
cd /root/bimsync-portal
```

### Build Docker image:

```bash
docker build -t bimsync-portal:latest .
```

This will take 2-3 minutes. You'll see:
```
[+] Building 45.2s (14/14) FINISHED
✅ Successfully tagged bimsync-portal:latest
```

### Verify the image:

```bash
docker images | grep bimsync
```

You should see:
```
bimsync-portal   latest   abc123def456   1 minute ago   243MB
```

---

## Step 3: Deploy in Coolify (5 minutes)

### A. In Coolify Dashboard:

1. **Click:** `+ New` → `Resource`

2. **Choose:** `Docker Based` section → `Dockerfile`

3. **Fill in the form:**
   ```
   ┌─────────────────────────────────────────┐
   │ Image Name: bimsync-portal:latest      │
   │                                         │
   │ Port: 3000                              │
   │                                         │
   │ Registry: (leave empty - local image)  │
   └─────────────────────────────────────────┘
   ```

4. **Click:** `Continue`

### B. Add Environment Variables:

Click on "Environment Variables" and add:

```
NEXT_PUBLIC_SUPABASE_URL
= http://supabasekong-n4g4og0cos0ocwg0ss8cswss.72.60.222.97.sslip.io

NEXT_PUBLIC_SUPABASE_ANON_KEY
= eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjU5Mzk2MCwiZXhwIjo0OTE4MjY3NTYwLCJyb2xlIjoiYW5vbiJ9.TuGXG83THiqENV8Nern5GwkiS7R6OCY4SGcB9cD-6XE

SUPABASE_SERVICE_KEY
= eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjU5Mzk2MCwiZXhwIjo0OTE4MjY3NTYwLCJyb2xlIjoic2VydmljZV9yb2xlIn0.-X1sUGnaBrVLPeh3ZTgJN5SqEb55aI_mauvyKUyE4P8

EMAIL_USER
= bimaided.website@gmail.com

EMAIL_PASSWORD
= rwgy biho ilda memw

EMAIL_TO
= tasneemlabeeb@gmail.com

NEXT_PUBLIC_RECAPTCHA_SITE_KEY
= 6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI

NODE_ENV
= production
```

5. **Click:** `Save`

### C. Deploy:

1. **Click:** `Deploy` button

2. **Wait:** 1-2 minutes

3. Coolify will:
   - ✅ Use your local Docker image
   - ✅ Create container
   - ✅ Start application
   - ✅ Generate URL with SSL

4. **Click the URL** to access your app!

---

## Step 4: Configure Domain (Optional)

### In Coolify:

1. Go to your application
2. Click **"Domains"**
3. Add: `yourdomain.com`
4. Coolify auto-configures SSL

### In Your DNS Provider:

Add these records:
```
Type: A
Name: @
Value: YOUR_SERVER_IP

Type: A
Name: www
Value: YOUR_SERVER_IP
```

Wait 5-10 minutes for DNS propagation.

---

## 🔄 How to Update Your App

When you make changes to your code:

### Option A: Re-upload Everything

```bash
./upload-to-server.sh
```

Then on server:
```bash
cd /root/bimsync-portal
docker build -t bimsync-portal:latest .
```

In Coolify: Click **"Rebuild"**

### Option B: Upload Only Changed Files

```bash
# From your Mac
scp -r app/ root@YOUR_SERVER_IP:/root/bimsync-portal/
scp -r components/ root@YOUR_SERVER_IP:/root/bimsync-portal/
```

Then rebuild on server.

---

## 🆘 Troubleshooting

### Upload fails:

```bash
# Test SSH connection first
ssh root@YOUR_SERVER_IP

# If password needed instead of key:
scp -o PreferredAuthentications=password bimsync.tar.gz root@IP:/tmp/
```

### Build fails on server:

```bash
# Check Docker is running
docker ps

# Check disk space
df -h

# View build logs
docker build -t bimsync-portal:latest . 2>&1 | tee build.log
```

### Container won't start:

```bash
# Check if image exists
docker images | grep bimsync

# Try running manually to see errors
docker run -p 3000:3000 bimsync-portal:latest

# Check logs
docker logs CONTAINER_NAME
```

### Coolify can't find image:

The image must be built **on the same server** where Coolify is running!

```bash
# On server, verify:
docker images | grep bimsync-portal

# Should show:
# bimsync-portal   latest   ...   243MB
```

---

## 📊 Quick Commands Reference

### On Your Mac:

```bash
# Upload to server
./upload-to-server.sh

# Upload specific files
scp file.txt root@IP:/root/bimsync-portal/

# Upload directory
scp -r app/ root@IP:/root/bimsync-portal/
```

### On Server:

```bash
# SSH to server
ssh root@YOUR_SERVER_IP

# Navigate to project
cd /root/bimsync-portal

# Build image
docker build -t bimsync-portal:latest .

# List images
docker images

# Remove old image
docker rmi bimsync-portal:latest

# View running containers
docker ps

# View all containers
docker ps -a

# Stop container
docker stop CONTAINER_NAME

# Remove container
docker rm CONTAINER_NAME

# View logs
docker logs -f CONTAINER_NAME
```

---

## ✅ Success Checklist

After deployment, verify:

- [ ] App loads at Coolify-generated URL
- [ ] Homepage displays with image slider
- [ ] Animations work (typing effect, parallax)
- [ ] Services pages load
- [ ] Contact form works
- [ ] Employee login works
- [ ] Admin panel accessible
- [ ] No console errors

---

## 🎯 Summary

1. **Upload:** `./upload-to-server.sh` (5 min)
2. **Build:** SSH to server, run `docker build` (3 min)
3. **Deploy:** Use Coolify Dashboard (5 min)
4. **Access:** Click generated URL
5. **Domain:** Optional - add custom domain

**Total:** ~15 minutes to live! 🚀

---

## 📞 Need Help?

If you encounter any issues:

1. Check the troubleshooting section above
2. View server logs: `docker logs -f CONTAINER_NAME`
3. Check Coolify logs in the dashboard
4. Verify environment variables are set correctly

Your app is ready to deploy! 🎉
