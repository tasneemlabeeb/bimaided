# Self-Hosted Supabase Setup Guide

## ⚠️ CRITICAL SECURITY WARNING

Your current Supabase configuration is using **DEFAULT DEMO KEYS**. These MUST be changed before deploying to production!

### 🔒 Keys That MUST Be Changed:

1. **JWT_SECRET** - Currently using demo value
2. **ANON_KEY** - Currently using demo value  
3. **SERVICE_ROLE_KEY** - Currently using demo value
4. **SECRET_KEY_BASE** - Currently a weak value
5. **VAULT_ENC_KEY** - Currently a placeholder
6. **DASHBOARD_PASSWORD** - Currently a weak value
7. **POSTGRES_PASSWORD** - Change for production

## 📋 Current Configuration

**Supabase URL**: `http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me`  
**Studio URL**: `http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me` (port 3000)  
**Database Port**: 5432  
**Kong HTTP Port**: 8000

## 🚀 Setup Steps

### Step 1: Access Supabase Studio

1. Open your browser and go to:
   ```
   http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me:3000
   ```

2. Login with:
   - **Username**: `supabase`
   - **Password**: `jn1oeccs4konh8dsixz8xsapeowgg44s`

### Step 2: Run Database Migration

1. In Supabase Studio, go to **SQL Editor** (left sidebar)

2. Click **"New Query"**

3. Copy the entire contents of:
   ```
   /Users/tasneemzaman/Desktop/Untitled/supabase/migrations/00_complete_schema.sql
   ```

4. Paste into the SQL editor

5. Click **"Run"** or press `Cmd + Enter`

6. Wait for completion (~30-60 seconds)

7. Verify success:
   - Go to **Table Editor**
   - You should see 14 tables
   - **departments** should have 7 rows
   - **designations** should have 18 rows

### Step 3: Create Storage Buckets

Go to **Storage** in Studio and create these buckets:

#### 1. employee-photos
```
Name: employee-photos
Public: No (Private)
File size limit: 5MB
Allowed file types: image/*
```

#### 2. employee-documents
```
Name: employee-documents
Public: No (Private)
File size limit: 10MB
Allowed file types: image/*, application/pdf
```

#### 3. project-images
```
Name: project-images
Public: Yes (Public)
File size limit: 10MB
Allowed file types: image/*
```

#### 4. leave-attachments
```
Name: leave-attachments
Public: No (Private)
File size limit: 5MB
Allowed file types: image/*, application/pdf
```

### Step 4: Create First Admin User

#### Option A: Via Studio Dashboard

1. Go to **Authentication** → **Users**
2. Click **"Add user"**
3. Enter:
   - Email: `admin@bimaided.com` (or your email)
   - Password: Strong password (save it!)
4. Click **"Create user"**
5. Copy the **User ID** (UUID format)

#### Option B: Via Your Application

1. Start your dev server: `npm run dev`
2. Open: `http://localhost:5173`
3. Sign up with your email/password
4. Go back to Studio → Authentication → Users
5. Find your user and copy the **User ID**

### Step 5: Assign Admin Role

1. In Supabase Studio, go to **SQL Editor**

2. Run this SQL (replace `YOUR_USER_ID` with actual UUID):

```sql
-- Assign admin role
INSERT INTO user_roles (user_id, role)
VALUES ('YOUR_USER_ID', 'admin');

-- Create employee record
INSERT INTO employees (
  first_name, 
  last_name, 
  email, 
  user_id, 
  joining_date,
  employment_status,
  eid
)
VALUES (
  'Admin',
  'User',
  'admin@bimaided.com',  -- Match the email you signed up with
  'YOUR_USER_ID',
  CURRENT_DATE,
  'Active',
  'EID001'  -- Your employee ID
);
```

### Step 6: Test Your Setup

1. Make sure your `.env` file has been updated with:
   ```env
   VITE_SUPABASE_URL=http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me
   VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

2. Start development server:
   ```bash
   npm run dev
   ```

3. Navigate to `http://localhost:5173`

4. Login with your admin credentials

5. Test features:
   - ✅ Admin Dashboard access
   - ✅ Add new employee
   - ✅ Create project
   - ✅ Check-in attendance
   - ✅ View reports

## 🔧 Troubleshooting

### Issue: Cannot connect to Supabase

**Check**:
1. Is the Supabase container running?
2. Can you access Studio at the URL?
3. Is the URL correct in `.env`?

**Solution**:
```bash
# Check if containers are running
docker ps | grep supabase

# Check logs
docker logs supabase-fdd1-kong
docker logs supabase-fdd1-db
```

### Issue: "relation does not exist" error

**Solution**: Run the migration SQL again in Studio SQL Editor

### Issue: Login works but cannot access dashboard

**Solution**:
1. Verify user has admin role:
   ```sql
   SELECT * FROM user_roles WHERE user_id = 'YOUR_USER_ID';
   ```

2. Verify employee record exists:
   ```sql
   SELECT * FROM employees WHERE user_id = 'YOUR_USER_ID';
   ```

3. If missing, run the SQL from Step 5 again

### Issue: "permission denied" errors

**Solution**: Check RLS policies are enabled. Run:
```sql
-- Check RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
```

All tables should have `rowsecurity = true`

### Issue: Storage upload fails

**Solution**:
1. Verify bucket exists in Storage tab
2. Check bucket policies (should be auto-created)
3. Ensure correct bucket name in code

## 🔐 Security Recommendations (BEFORE PRODUCTION)

### 1. Generate New JWT Secret

```bash
# Generate a secure JWT secret (32+ characters)
openssl rand -base64 32
```

Update in your Supabase `.env` file:
```
JWT_SECRET=your-new-secure-jwt-secret-here
```

### 2. Generate New Keys

Use the Supabase API to generate new keys with your new JWT secret:

```bash
# Install supabase CLI
npm install -g supabase

# Generate new anon key
supabase gen keys --project-ref your-project --type anon

# Generate new service role key
supabase gen keys --project-ref your-project --type service_role
```

Or use online JWT generator at https://jwt.io with:
- Algorithm: HS256
- Payload for anon key:
  ```json
  {
    "role": "anon",
    "iss": "supabase",
    "iat": 1641769200,
    "exp": 1799535600
  }
  ```
- Payload for service_role key:
  ```json
  {
    "role": "service_role",
    "iss": "supabase",
    "iat": 1641769200,
    "exp": 1799535600
  }
  ```

### 3. Change Dashboard Password

Update in Supabase `.env`:
```
DASHBOARD_PASSWORD=your-strong-password-here
```

### 4. Enable HTTPS

For production, you MUST use HTTPS. Update:
```
SUPABASE_PUBLIC_URL=https://your-domain.com
API_EXTERNAL_URL=https://your-domain.com
```

### 5. Configure SMTP for Real Email

Update these in Supabase `.env`:
```
SMTP_ADMIN_EMAIL=noreply@bimaided.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_SENDER_NAME=BIMSync Portal
```

### 6. Update Redirect URLs

After deploying to production domain:
```
SITE_URL=https://bimaided.com
ADDITIONAL_REDIRECT_URLS=https://bimaided.com/*,https://www.bimaided.com/*
```

## 📊 Database Connection Info

If you need to connect external tools:

**Host**: `bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me`  
**Port**: `5432`  
**Database**: `postgres`  
**User**: `postgres`  
**Password**: `iibktji91xds4y0axrqwmonywcq5vqhb`  

**Connection String**:
```
postgresql://postgres:iibktji91xds4y0axrqwmonywcq5vqhb@bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me:5432/postgres
```

## 📝 Next Steps

1. ✅ Run the database migration
2. ✅ Create storage buckets
3. ✅ Create admin user
4. ✅ Test the application
5. 🔒 **IMPORTANT**: Change all security keys before production
6. 🔐 Enable HTTPS for production
7. 📧 Configure real SMTP for emails
8. 🌐 Update redirect URLs to production domain

## 🆘 Need Help?

**Check Logs**:
```bash
# Kong (API Gateway)
docker logs -f supabase-fdd1-kong

# Database
docker logs -f supabase-fdd1-db

# Auth (GoTrue)
docker logs -f supabase-fdd1-auth

# Storage
docker logs -f supabase-fdd1-storage
```

**Restart Services**:
```bash
# Restart all Supabase containers
docker restart $(docker ps -q --filter name=supabase-fdd1)
```

**Access Database Directly**:
```bash
docker exec -it supabase-fdd1-db psql -U postgres
```

---

**Last Updated**: November 8, 2025  
**Instance**: Self-Hosted Supabase  
**Container Prefix**: supabase-fdd1
