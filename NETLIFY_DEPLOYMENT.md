# Netlify Deployment Guide

## ✅ Changes Made

1. **Removed sensitive files from Git:**
   - `.env` and `.env.production` are now excluded from version control
   - Added to `.gitignore` to prevent future commits

2. **Created `netlify.toml`:**
   - Configured build settings
   - Disabled secrets scanning for documentation files
   - Added SPA redirect rules

## 🚀 Next Steps to Deploy

### Step 1: Get Production Supabase Credentials

Your current Supabase URL (`http://supabasekong-i480ws8cosk4kwkskssck8o8.72.60.222.97.sslip.io`) is a **local development instance** and won't work in production.

**Option A: Use Supabase Cloud (Recommended - Free)**

1. Go to https://supabase.com and sign up
2. Create a new project
3. Wait for it to finish setting up (~2 minutes)
4. Go to **Project Settings** → **API**
5. Copy these values:
   - **Project URL** (looks like: `https://abcdefgh.supabase.co`)
   - **anon/public key** (a long JWT token)

**Option B: Use Your Local Supabase**
You'll need to expose your local Supabase to the internet using:
- ngrok
- Cloudflare Tunnel
- Or deploy Supabase to a cloud server

### Step 2: Configure Netlify Environment Variables

1. Go to your **Netlify Dashboard**: https://app.netlify.com
2. Select your site
3. Go to **Site settings** → **Environment variables**
4. Click **Add a variable** and add these:

```
Variable: VITE_SUPABASE_URL
Value: https://your-project.supabase.co
```

```
Variable: VITE_SUPABASE_ANON_KEY
Value: your-actual-anon-key-here
```

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
