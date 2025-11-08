# 🚀 Your BIMSync Portal Deployment - Let's Do This Together!

## What We're Going to Do

1. ✅ **Build Docker image on your Mac** (using your Docker Desktop)
2. ✅ **Test it locally** to make sure everything works
3. ✅ **Transfer to your server** (I'll guide you)
4. ✅ **Deploy with Coolify** (super easy!)

---

## Step 1: Build Locally (Do This Now!)

### First, add your Supabase credentials:

1. Open `.env.production` file (I just created it)
2. Add your actual Supabase URL and key
3. Save it

### Then run the build:

```bash
./deploy-local.sh
```

This script will:
- ✅ Check Docker Desktop is running
- ✅ Build your Docker image
- ✅ Offer to test it locally on http://localhost:3000
- ✅ Show you the next steps

**Expected time:** 2-3 minutes

---

## Step 2: Test Locally (Optional but Recommended)

When the script asks "Would you like to test locally?", say **yes** (y)

Then open: **http://localhost:3000**

Check:
- ✅ Homepage loads
- ✅ Images appear
- ✅ Animations work
- ✅ Services pages work
- ✅ No console errors

If everything looks good, we're ready for production! 🎉

---

## Step 3: Transfer to Your Server

### Option A: Docker Hub (Easiest - Recommended)

1. **Create free Docker Hub account**: https://hub.docker.com/signup

2. **Login on your Mac:**
   ```bash
   docker login
   ```
   Enter your Docker Hub username and password

3. **Tag your image:**
   ```bash
   docker tag bimsync-portal:latest YOUR_DOCKERHUB_USERNAME/bimsync-portal:latest
   ```
   Replace `YOUR_DOCKERHUB_USERNAME` with your actual username

4. **Push to Docker Hub:**
   ```bash
   docker push YOUR_DOCKERHUB_USERNAME/bimsync-portal:latest
   ```
   This uploads your image (takes 2-5 minutes)

5. **Now your image is public!** Anyone (including your Coolify server) can pull it:
   ```bash
   docker pull YOUR_DOCKERHUB_USERNAME/bimsync-portal:latest
   ```

### Option B: Direct Transfer to Server (No Docker Hub)

1. **Save image to file:**
   ```bash
   docker save bimsync-portal:latest | gzip > bimsync-portal.tar.gz
   ```
   This creates a compressed file (~200-300MB)

2. **Upload to your server:**
   ```bash
   scp bimsync-portal.tar.gz root@YOUR_SERVER_IP:/root/
   ```
   Replace `YOUR_SERVER_IP` with your actual server IP

3. **Load on server:**
   ```bash
   ssh root@YOUR_SERVER_IP
   docker load < /root/bimsync-portal.tar.gz
   ```

---

## Step 4: Deploy with Coolify

### If you used Docker Hub (Option A):

1. **In Coolify Dashboard:**
   - Click **"+ New"** → **"Resource"**
   - Choose **"Docker Based"** section
   - Click **"Docker Image"**

2. **Fill in the form:**
   ```
   Image Name: YOUR_DOCKERHUB_USERNAME/bimsync-portal:latest
   Port: 3000
   ```

3. **Add Environment Variables:**
   Click "Environment Variables" section:
   ```
   NEXT_PUBLIC_SUPABASE_URL = your_supabase_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY = your_anon_key
   NODE_ENV = production
   ```

4. **Click "Deploy"**

5. **Wait 1-2 minutes** - Coolify will:
   - Pull your image from Docker Hub
   - Create container
   - Start application
   - Generate URL with SSL

6. **Access your app!** Click the generated URL 🎉

### If you used Direct Transfer (Option B):

Same steps as above, but use:
```
Image Name: bimsync-portal:latest
```
(No username prefix since it's local)

---

## Step 5: Configure Domain (Optional)

In Coolify:
1. Go to your application
2. Click **"Domains"**
3. Add your domain: `yourdomain.com`
4. Coolify auto-configures SSL (Let's Encrypt)
5. Update your DNS:
   ```
   A Record: @ → YOUR_SERVER_IP
   A Record: www → YOUR_SERVER_IP
   ```

Wait 5-10 minutes for DNS propagation, then visit `https://yourdomain.com`

---

## 🆘 I'm Here to Help!

After you run `./deploy-local.sh`, let me know:

1. ✅ **If build succeeded** - I'll help with the transfer
2. ❌ **If build failed** - Share the error, I'll fix it
3. 🧪 **If local test works** - Screenshot it! Then we proceed
4. ❓ **Any questions** - Just ask!

---

## Quick Reference

### Useful Docker Commands

```bash
# List images
docker images

# List running containers
docker ps

# View logs
docker logs bimsync-portal-test

# Stop container
docker stop bimsync-portal-test

# Remove container
docker rm bimsync-portal-test

# Remove image
docker rmi bimsync-portal:latest

# Clean up everything (careful!)
docker system prune -a
```

### Environment Variables You Need

- `NEXT_PUBLIC_SUPABASE_URL` - Your Supabase project URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Your Supabase anonymous key
- `NODE_ENV` - Set to "production"

---

## Timeline

- **Local Build:** 2-3 minutes
- **Local Test:** 1 minute
- **Docker Hub Upload:** 3-5 minutes (or skip if direct transfer)
- **Coolify Deploy:** 1-2 minutes
- **Total:** ~10-15 minutes to live! 🚀

---

## Ready? Let's Go! 🎯

Run this command now:

```bash
./deploy-local.sh
```

Then tell me what happens! 
