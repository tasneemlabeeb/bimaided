# Fix Storage Upload Error - Production Deployment

## Problem
When trying to upload project images in production (bimaided.com), you're getting:
```
StorageUnknownError: Failed to fetch
```

This happens because the storage buckets don't exist in your production Supabase instance.

## Solution

### Step 1: Access Supabase SQL Editor
1. Open your browser and go to: `http://supabasekong-n4g4og0cos0ocwg0ss8cswss.72.60.222.97.sslip.io`
2. Login to Supabase Studio
3. Click on **SQL Editor** in the left sidebar

### Step 2: Run Storage Setup Script
1. Copy the entire contents of `database/setup-storage-buckets.sql`
2. Paste it into the SQL Editor
3. Click **Run** (or press Cmd/Ctrl + Enter)

This will create 5 storage buckets:
- ✅ `employee-photos` (Private, 5MB, images)
- ✅ `employee-documents` (Private, 10MB, documents)
- ✅ `cvs` (Private, 10MB, documents for job applications)
- ✅ `project-images` (Public, 10MB, images) ← **This fixes your error!**
- ✅ `leave-attachments` (Private, 10MB, docs & images)

### Step 3: Verify Setup
After running the script, you'll see two result tables:
1. **Buckets created** - Should show 5 buckets with their size limits
2. **Storage policies** - Should show ~15 RLS policies for access control

### Step 4: Test Upload
1. Go back to https://bimaided.com/admin
2. Navigate to the **Projects** tab
3. Try adding a project with images
4. The upload should now work! ✅

## What This Script Does

### Storage Buckets Created:
| Bucket | Public | Size Limit | File Types | Purpose |
|--------|--------|------------|------------|---------|
| employee-photos | ❌ Private | 5MB | Images | Employee profile photos |
| employee-documents | ❌ Private | 10MB | PDF, DOC, DOCX | Employee documents |
| cvs | ❌ Private | 10MB | PDF, DOC, DOCX | Job application CVs |
| **project-images** | ✅ Public | 10MB | Images, GIF | Portfolio project images |
| leave-attachments | ❌ Private | 10MB | PDF, Images | Leave request attachments |

### Security Policies:
- **project-images**: Public read, admin-only write/delete
- **employee-photos**: Employee can view own, admin can manage all
- **employee-documents**: Employee can view own, admin can manage all
- **cvs**: Anyone can upload (for applications), admin can view/delete
- **leave-attachments**: Employee/supervisor/admin access based on hierarchy

## Alternative: Quick Fix (If SQL Editor Not Available)

If you can't access the Supabase SQL Editor, SSH into your server and run:

```bash
ssh root@72.60.222.97

# Find the Supabase Postgres container
docker ps | grep postgres

# Execute SQL script (replace CONTAINER_ID with actual ID)
docker exec -i CONTAINER_ID psql -U postgres -d postgres < setup-storage-buckets.sql
```

## After Setup

Once the buckets are created:
1. ✅ Project image uploads will work
2. ✅ Employee photo uploads will work
3. ✅ CV uploads in career portal will work
4. ✅ Leave request attachments will work
5. ✅ All file uploads will have proper access control

## Troubleshooting

**If upload still fails after running the script:**

1. **Check bucket exists:**
   ```sql
   SELECT id, name, public FROM storage.buckets WHERE id = 'project-images';
   ```
   Should return 1 row.

2. **Check RLS policies:**
   ```sql
   SELECT policyname FROM pg_policies 
   WHERE schemaname = 'storage' AND tablename = 'objects'
   AND policyname LIKE '%project%';
   ```
   Should return 3 policies (read, upload, delete).

3. **Check browser console:**
   - Open DevTools (F12)
   - Go to Network tab
   - Try uploading again
   - Look for the failed request to see the exact error

4. **Verify Supabase URL:**
   - Make sure `NEXT_PUBLIC_SUPABASE_URL` in production is set correctly
   - Should be: `http://supabasekong-n4g4og0cos0ocwg0ss8cswss.72.60.222.97.sslip.io`

---

**Need help?** Check the Supabase storage documentation or verify your Supabase instance is running correctly.
