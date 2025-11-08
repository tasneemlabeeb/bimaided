-- =====================================================
-- FIX STORAGE POLICIES FOR PROJECT IMAGES
-- =====================================================
-- Simplify storage policies to allow authenticated users

-- Drop existing policies
DROP POLICY IF EXISTS "Admin upload for project images" ON storage.objects;
DROP POLICY IF EXISTS "Admin delete for project images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload project images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete project images" ON storage.objects;

-- Allow ANY authenticated user to upload project images
-- Check if user is logged in (has a valid JWT)
CREATE POLICY "Authenticated users can upload project images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'project-images' AND
  auth.uid() IS NOT NULL
);

-- Allow ANY authenticated user to delete project images
CREATE POLICY "Authenticated users can delete project images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'project-images' AND
  auth.uid() IS NOT NULL
);

-- Verify
SELECT policyname, cmd FROM pg_policies 
WHERE schemaname = 'storage' AND tablename = 'objects' 
AND policyname LIKE '%project%'
ORDER BY policyname;
