# 🚀 BIM Portal - Netlify + Coolify Deployment Guide

## 📋 Architecture Overview

```
Frontend (Netlify) → Backend API (Coolify) → Supabase (Coolify)
     ↓                       ↓                      ↓
React SPA Build        Node.js Express API     PostgreSQL DB
```

**Benefits of this setup:**
- ✅ **Netlify**: Excellent for React SPAs, CDN, automatic deployments
- ✅ **Coolify Backend**: Your existing infrastructure, internal Supabase connection
- ✅ **Supabase on Coolify**: Keep existing database, no migration needed

---

## 🎯 Part 1: Deploy Backend API to Coolify

### Step 1: Create Backend Service in Coolify

1. **Login to your Coolify Dashboard**
   - Go to your Coolify URL on Hostinger VPS

2. **Create New Application**
   - Click **"+ New"** → **"Application"**
   - Choose **"Public Repository"**
   - Repository URL: `https://github.com/tasneemlabeeb/bimsync-portal.git`
   - Branch: `main`
   - **Name**: `bim-portal-backend-api`

3. **Configure Build Settings**
   - Build Pack: **Docker**
   - Dockerfile Location: `Dockerfile.backend`
   - Port: `3001`
   - Health Check URL: `/api/health`

### Step 2: Backend Environment Variables

Copy these to Coolify → Backend App → **Environment Variables**:

```bash
NODE_ENV=production
PORT=3001
VITE_SUPABASE_URL=http://supabasekong-i480ws8cosk4kwkskssck8o8.72.60.222.97.sslip.io
VITE_SUPABASE_ANON_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
SUPABASE_SERVICE_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
DATABASE_URL=postgresql://postgres:417wIu14OxPmnQNpUCeieTSZ7IN6pYSa@supabase-db:5432/postgres
JWT_SECRET=rt4h4cKZkKWezb8AwtUxN3buEKwEVqzO
EMAIL_USER=bimaided.website@gmail.com
EMAIL_PASSWORD=rwgy biho ilda memw
EMAIL_TO=tasneemlabeeb@gmail.com
VITE_RECAPTCHA_SITE_KEY=6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI
RECAPTCHA_SECRET_KEY=your_recaptcha_secret_key_here
```

### Step 3: Deploy Backend

1. **Deploy** in Coolify
2. **Set Custom Domain** (e.g., `api.yourdomain.com`)
3. **Test Backend**: Visit `https://api.yourdomain.com/api/health`

---

## 🌐 Part 2: Deploy Frontend to Netlify

### Step 1: Connect GitHub to Netlify

1. **Go to Netlify.com** → Login/Signup
2. **Import from Git** → Choose GitHub → Select `tasneemlabeeb/bimsync-portal`
3. **Branch**: `main`

### Step 2: Configure Build Settings

```bash
Build command: npm run build
Publish directory: dist
Node version: 18
```

### Step 3: Frontend Environment Variables

In Netlify → **Site settings** → **Environment variables**, add:

```bash
VITE_SUPABASE_URL=http://supabasekong-i480ws8cosk4kwkskssck8o8.72.60.222.97.sslip.io
VITE_SUPABASE_ANON_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
VITE_API_URL=https://api.yourdomain.com
VITE_RECAPTCHA_SITE_KEY=6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI
NODE_ENV=production
```

**Important**: Replace `https://api.yourdomain.com` with your actual Coolify backend domain.

**⚠️ IMPORTANT:** Use your PRODUCTION credentials, not the local development ones!

### Step 3: Update Supabase URL Configuration

In Supabase Dashboard:

1. Go to **Authentication** → **URL Configuration**
2. Add your Netlify URLs:
   - **Site URL**: `https://your-site-name.netlify.app`
   - **Redirect URLs**: `https://your-site-name.netlify.app/**`

### Step 4: Trigger Deployment

1. Go to **Deploys** in Netlify
2. Click **Trigger deploy** → **Clear cache and deploy site**
3. Wait for the build to complete
4. Your site should now be live! 🎉

## 📝 Local Development Setup

Your local `.env.production` file still exists on your machine (just not in Git). For local development, you can keep using:

```bash
VITE_SUPABASE_URL=http://supabasekong-i480ws8cosk4kwkskssck8o8.72.60.222.97.sslip.io
VITE_SUPABASE_ANON_KEY=your-local-key
```

This file won't be committed to Git, so your local credentials stay secure.

## 🔍 Troubleshooting

### Build still failing with secrets detected?
- Make sure you triggered a **Clear cache and deploy**
- Check that `netlify.toml` is in your repo

### Site loads but shows "Failed to fetch"?
- Verify environment variables are set in Netlify
- Check that URLs don't have trailing slashes
- Ensure Netlify domain is added to Supabase allowed URLs

### Authentication not working?
- Make sure redirect URLs in Supabase include your Netlify domain
- Check that environment variables are correctly set

## 📚 Additional Resources

- [Netlify Environment Variables](https://docs.netlify.com/environment-variables/overview/)
- [Supabase Documentation](https://supabase.com/docs)
- [Netlify Redirects](https://docs.netlify.com/routing/redirects/)

---

**Need help?** Check the Netlify build logs for specific error messages.
