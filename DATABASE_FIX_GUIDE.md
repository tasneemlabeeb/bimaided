# Database Fix Guide

## Issues Found (from Console Errors)

1. ❌ **404 Error**: `job_applications` table doesn't exist
2. ❌ **400 Bad Request**: Projects table missing required columns for project updates

## Solutions

### Step 1: Create job_applications Table

This table is needed for the Career page to accept job applications.

1. Go to your Supabase Dashboard at: http://supabasekong-i480ws8cosk4kwkskssck8o8.72.60.222.97.sslip.io
2. Navigate to **SQL Editor** in the left sidebar
3. Click **New Query**
4. Copy and paste the entire contents of: `database/16_create_job_applications_table.sql`
5. Click **Run** (or press Cmd+Enter)
6. You should see: "Success. No rows returned"

### Step 2: Verify/Add Missing Columns to Projects Table

This fixes the 400 Bad Request error when updating projects.

1. In the same **SQL Editor**
2. Click **New Query**
3. Copy and paste the entire contents of: `database/17_verify_projects_table.sql`
4. Click **Run**
5. You should see a table showing all columns in the projects table
6. Verify these columns exist:
   - `preview_image`
   - `gallery_image_1` through `gallery_image_5`
   - `client_name`
   - `completion_date`
   - `lod`
   - `location`
   - `scope`

### Step 3: Create Storage Bucket for Project Images

1. In Supabase Dashboard, navigate to **Storage** in the left sidebar
2. Click **Create a new bucket**
3. Set:
   - **Name**: `project-images`
   - **Public bucket**: ✅ Check this (images need to be publicly accessible)
4. Click **Create bucket**
5. Click on the `project-images` bucket
6. Go to **Policies** tab
7. Click **New Policy** → **For full customization**
8. Create SELECT policy:
   ```sql
   CREATE POLICY "Public can view project images"
   ON storage.objects FOR SELECT
   TO public
   USING (bucket_id = 'project-images');
   ```
9. Create INSERT policy:
   ```sql
   CREATE POLICY "Authenticated users can upload project images"
   ON storage.objects FOR INSERT
   TO authenticated
   WITH CHECK (bucket_id = 'project-images');
   ```
10. Create DELETE policy (optional, for cleanup):
    ```sql
    CREATE POLICY "Authenticated users can delete project images"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (bucket_id = 'project-images');
    ```

### Step 4: Test the Fixes

1. **Refresh your browser** (Cmd+R)
2. Navigate to the **Career** page - should load without 404 error
3. Navigate to **Admin Dashboard** → **Projects**
4. Try editing a project and uploading images
5. Click **Update Project** - should work without 400 error

## Verification Checklist

- [ ] No more `job_applications 404` error in console
- [ ] No more `projects 400 Bad Request` error in console
- [ ] Career page loads successfully
- [ ] Can view job applications in Admin Dashboard
- [ ] Can update projects with all fields
- [ ] Can upload preview and gallery images

## Optional: Create Assignments Tables

If you want the Assignment Manager to work for internal team tasks, also run:

1. Copy contents of `database/15_create_assignments_tables.sql`
2. Paste in SQL Editor
3. Click **Run**

This creates:
- `assignments` table
- `assignment_members` table
- `assignment_details` view
- All necessary RLS policies

## Troubleshooting

### Storage Upload Errors

If you get "Bucket not found" errors:
1. Verify bucket name is exactly `project-images`
2. Ensure bucket is set to **Public**
3. Check that storage policies are created

### RLS Policy Errors

If you get permission denied:
1. Make sure you're logged in as admin
2. Check that `user_roles` table has your user with role='admin'
3. Verify RLS policies are enabled

### Image Upload Too Large

The code compresses images to:
- Preview: 500KB max
- Gallery: 50KB max each

If upload fails, try:
- Reducing image resolution
- Using JPEG instead of PNG
- Images under 5MB original size

## Need Help?

Check browser console (F12 → Console tab) for specific error messages.
