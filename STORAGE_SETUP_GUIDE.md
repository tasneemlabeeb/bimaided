# Storage Buckets Setup Guide

## Issue
When submitting job applications, you're getting "no bucket found" error because the storage buckets haven't been created yet.

## Required Buckets

### 1. `project-images` (Public)
- **Purpose**: Store project preview images and gallery photos
- **Access**: Public (anyone can view)
- **File Types**: JPEG, PNG, WebP
- **Size Limit**: 10MB per file
- **Used By**: 
  - ProjectManager (admin uploads)
  - Projects page (displays images)
  - Landing page (featured projects)

### 2. `cvs` (Private)
- **Purpose**: Store job application resumes/CVs
- **Access**: Private (only admins can view)
- **File Types**: PDF, DOC, DOCX
- **Size Limit**: 5MB per file
- **Used By**:
  - Career page (applicants upload)
  - ApplicationManager (admins review)

## Setup Method 1: Using Supabase Dashboard (Recommended)

### Step 1: Create project-images Bucket

1. Go to your Supabase Dashboard: http://supabasekong-i480ws8cosk4kwkskssck8o8.72.60.222.97.sslip.io
2. Click **Storage** in the left sidebar
3. Click **Create a new bucket** button
4. Fill in:
   - **Name**: `project-images`
   - **Public bucket**: ✅ **Check this box** (images need to be publicly viewable)
   - **File size limit**: 10485760 (10MB)
   - **Allowed MIME types**: Leave empty or add: `image/jpeg,image/png,image/jpg,image/webp`
5. Click **Create bucket**

### Step 2: Create Policies for project-images

1. Click on the `project-images` bucket
2. Go to **Policies** tab
3. Click **New Policy** → **For full customization**

**Policy 1 - Public View:**
```sql
CREATE POLICY "Public can view project images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'project-images');
```

**Policy 2 - Authenticated Upload:**
```sql
CREATE POLICY "Authenticated users can upload project images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'project-images');
```

**Policy 3 - Authenticated Update:**
```sql
CREATE POLICY "Authenticated users can update project images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'project-images')
WITH CHECK (bucket_id = 'project-images');
```

**Policy 4 - Authenticated Delete:**
```sql
CREATE POLICY "Authenticated users can delete project images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'project-images');
```

### Step 3: Create cvs Bucket

1. Go back to **Storage** main page
2. Click **Create a new bucket**
3. Fill in:
   - **Name**: `cvs`
   - **Public bucket**: ❌ **UNCHECK this box** (CVs should be private)
   - **File size limit**: 5242880 (5MB)
   - **Allowed MIME types**: Leave empty or add: `application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document`
4. Click **Create bucket**

### Step 4: Create Policies for cvs

1. Click on the `cvs` bucket
2. Go to **Policies** tab
3. Click **New Policy** → **For full customization**

**Policy 1 - Public Upload (for job applicants):**
```sql
CREATE POLICY "Anyone can upload CVs"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'cvs');
```

**Policy 2 - Admin View Only:**
```sql
CREATE POLICY "Admins can view CVs"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'cvs' AND
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.user_id = auth.uid()
    AND user_roles.role = 'admin'
  )
);
```

**Policy 3 - Admin Delete:**
```sql
CREATE POLICY "Admins can delete CVs"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'cvs' AND
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.user_id = auth.uid()
    AND user_roles.role = 'admin'
  )
);
```

## Setup Method 2: Using SQL (Alternative)

If you prefer SQL, you can run the file `database/18_create_storage_buckets.sql` in the SQL Editor.

**Note**: Some Supabase instances require buckets to be created via the Dashboard UI first, then policies can be added via SQL.

## Verification

After setup, verify buckets exist:

1. Go to **Storage** in Supabase Dashboard
2. You should see both buckets:
   - ✅ `project-images` (Public)
   - ✅ `cvs` (Private)

3. Test upload:
   - Go to Career page
   - Try submitting an application with a PDF
   - Should upload successfully
   - Check the `cvs` bucket - you should see the file

4. Test project images:
   - Go to Admin Dashboard → Projects
   - Edit a project and upload images
   - Images should appear in `project-images` bucket

## Troubleshooting

### "Bucket not found" Error
- Make sure bucket names are exactly: `project-images` and `cvs`
- Check that buckets are created (visible in Storage section)
- Verify RLS is enabled on storage.objects table

### "Permission denied" Error
- Check that policies are created correctly
- For public uploads (CVs), ensure policy allows `TO public`
- For admin-only access, verify user_roles table has admin role

### Files Upload But Can't Be Viewed
- **project-images**: Make sure bucket is set to **Public**
- **cvs**: Should be private - only admins with proper role can view

### Upload Size Errors
- project-images: Max 10MB per file
- cvs: Max 5MB per file
- Compress images if needed before upload

## Important Notes

- **CVs are private**: Only admins can view uploaded resumes
- **Project images are public**: Anyone can view project photos
- **File cleanup**: Consider setting up lifecycle policies to delete old CVs after 6 months
- **Backup**: Storage files are not included in database backups - set up separate backup strategy

## Next Steps After Setup

1. ✅ Create both storage buckets
2. ✅ Add all required policies
3. Test job application submission
4. Test project image upload
5. Verify files appear in correct buckets
6. Check that only admins can view CVs

## Security Checklist

- [ ] `project-images` bucket is public
- [ ] `cvs` bucket is private
- [ ] Public can upload CVs (for applications)
- [ ] Only admins can view CVs
- [ ] Authenticated users can upload project images
- [ ] File size limits are enforced
- [ ] MIME type restrictions are set (optional but recommended)
