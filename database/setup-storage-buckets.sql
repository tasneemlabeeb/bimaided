-- =====================================================
-- STORAGE BUCKETS SETUP FOR BIMAIDED PORTAL
-- =====================================================
-- This script creates all required storage buckets and their RLS policies
-- Run this in your Supabase SQL Editor

-- =====================================================
-- 1. CREATE STORAGE BUCKETS
-- =====================================================

-- Delete existing buckets if they exist (optional - comment out if you want to keep existing data)
-- DELETE FROM storage.buckets WHERE id IN ('employee-photos', 'employee-documents', 'cvs', 'project-images', 'leave-attachments');

-- Create buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('employee-photos', 'employee-photos', false, 5242880, ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp']),
  ('employee-documents', 'employee-documents', false, 10485760, ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']),
  ('cvs', 'cvs', false, 10485760, ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']),
  ('project-images', 'project-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp', 'image/gif']),
  ('leave-attachments', 'leave-attachments', false, 10485760, ARRAY['application/pdf', 'image/jpeg', 'image/png', 'image/jpg'])
ON CONFLICT (id) DO UPDATE 
SET 
  name = EXCLUDED.name,
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- =====================================================
-- 2. DROP EXISTING POLICIES (if any)
-- =====================================================

DROP POLICY IF EXISTS "Public read access for project images" ON storage.objects;
DROP POLICY IF EXISTS "Admin upload for project images" ON storage.objects;
DROP POLICY IF EXISTS "Admin delete for project images" ON storage.objects;

DROP POLICY IF EXISTS "Employee photo access" ON storage.objects;
DROP POLICY IF EXISTS "Employee photo upload" ON storage.objects;
DROP POLICY IF EXISTS "Employee photo delete" ON storage.objects;

DROP POLICY IF EXISTS "Employee document access" ON storage.objects;
DROP POLICY IF EXISTS "Employee document upload" ON storage.objects;
DROP POLICY IF EXISTS "Employee document delete" ON storage.objects;

DROP POLICY IF EXISTS "CV access for admins" ON storage.objects;
DROP POLICY IF EXISTS "CV upload by applicants" ON storage.objects;
DROP POLICY IF EXISTS "CV delete by admins" ON storage.objects;

DROP POLICY IF EXISTS "Leave attachment access" ON storage.objects;
DROP POLICY IF EXISTS "Leave attachment upload" ON storage.objects;
DROP POLICY IF EXISTS "Leave attachment delete" ON storage.objects;

-- =====================================================
-- 3. CREATE RLS POLICIES FOR STORAGE BUCKETS
-- =====================================================

-- ---------------------------------------------------
-- Bucket 1: employee-photos (Private - 5MB, images only)
-- ---------------------------------------------------

-- Allow employees to view their own photos and admins to view all
CREATE POLICY "Employee photo access"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'employee-photos' AND (
    auth.uid()::text = (storage.foldername(name))[1] OR
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  )
);

-- Allow admins to upload employee photos
CREATE POLICY "Employee photo upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'employee-photos' AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- Allow admins to delete employee photos
CREATE POLICY "Employee photo delete"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'employee-photos' AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- ---------------------------------------------------
-- Bucket 2: employee-documents (Private - 10MB, documents)
-- ---------------------------------------------------

-- Allow employees to view their own documents and admins to view all
CREATE POLICY "Employee document access"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'employee-documents' AND (
    auth.uid()::text = (storage.foldername(name))[1] OR
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  )
);

-- Allow admins to upload employee documents
CREATE POLICY "Employee document upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'employee-documents' AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- Allow admins to delete employee documents
CREATE POLICY "Employee document delete"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'employee-documents' AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- ---------------------------------------------------
-- Bucket 3: cvs (Private - 10MB, documents)
-- ---------------------------------------------------

-- Allow admins to view all CVs
CREATE POLICY "CV access for admins"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'cvs' AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- Allow anyone to upload CV (for job applications)
CREATE POLICY "CV upload by applicants"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'cvs');

-- Allow admins to delete CVs
CREATE POLICY "CV delete by admins"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'cvs' AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- ---------------------------------------------------
-- Bucket 4: project-images (Public - 10MB, images)
-- ---------------------------------------------------

-- Allow public read access for project images
CREATE POLICY "Public read access for project images"
ON storage.objects FOR SELECT
USING (bucket_id = 'project-images');

-- Allow authenticated users to upload project images
CREATE POLICY "Admin upload for project images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'project-images' AND
  auth.role() = 'authenticated'
);

-- Allow authenticated users to delete project images
CREATE POLICY "Admin delete for project images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'project-images' AND
  auth.role() = 'authenticated'
);

-- ---------------------------------------------------
-- Bucket 5: leave-attachments (Private - 10MB, docs & images)
-- ---------------------------------------------------

-- Allow employees to view their own attachments, supervisors to view their team's, and admins to view all
CREATE POLICY "Leave attachment access"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'leave-attachments' AND (
    -- Employee can view their own
    auth.uid()::text = (storage.foldername(name))[1] OR
    -- Supervisor can view their team's
    EXISTS (
      SELECT 1 FROM employees e
      WHERE e.id::text = (storage.foldername(name))[1]
      AND e.supervisor_id IN (
        SELECT id FROM employees WHERE email = auth.email()
      )
    ) OR
    -- Admin can view all
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  )
);

-- Allow employees to upload their own leave attachments
CREATE POLICY "Leave attachment upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'leave-attachments' AND (
    -- Employee uploading their own
    auth.uid()::text = (storage.foldername(name))[1] OR
    -- Or admin uploading
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  )
);

-- Allow employees to delete their own attachments or admins to delete any
CREATE POLICY "Leave attachment delete"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'leave-attachments' AND (
    auth.uid()::text = (storage.foldername(name))[1] OR
    EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
  )
);

-- =====================================================
-- 4. VERIFY SETUP
-- =====================================================

-- List all buckets
SELECT 
  id,
  name,
  public,
  file_size_limit / 1048576 as size_limit_mb,
  allowed_mime_types,
  created_at
FROM storage.buckets
ORDER BY name;

-- List all storage policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
ORDER BY policyname;

-- =====================================================
-- SETUP COMPLETE!
-- =====================================================
