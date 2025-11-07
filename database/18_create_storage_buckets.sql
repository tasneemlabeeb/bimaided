-- Create storage buckets for file uploads
-- Note: This SQL creates the bucket configurations. You may also need to create them via the Supabase Dashboard UI.

-- Create bucket for project images (preview and gallery)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'project-images',
  'project-images',
  true,
  10485760, -- 10MB limit
  ARRAY['image/jpeg', 'image/png', 'image/jpg', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Create bucket for job application CVs/resumes
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'cvs',
  'cvs',
  false, -- Private bucket - only authenticated users can access
  5242880, -- 5MB limit
  ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for project-images bucket

-- Policy: Anyone can view project images
CREATE POLICY IF NOT EXISTS "Public can view project images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'project-images');

-- Policy: Authenticated users can upload project images
CREATE POLICY IF NOT EXISTS "Authenticated users can upload project images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'project-images');

-- Policy: Authenticated users can update their uploaded project images
CREATE POLICY IF NOT EXISTS "Authenticated users can update project images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'project-images')
WITH CHECK (bucket_id = 'project-images');

-- Policy: Authenticated users can delete project images
CREATE POLICY IF NOT EXISTS "Authenticated users can delete project images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'project-images');

-- Storage policies for cvs bucket

-- Policy: Anyone can upload CVs (for job applications)
CREATE POLICY IF NOT EXISTS "Anyone can upload CVs"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'cvs');

-- Policy: Only authenticated admins can view CVs
CREATE POLICY IF NOT EXISTS "Admins can view CVs"
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

-- Policy: Admins can delete CVs
CREATE POLICY IF NOT EXISTS "Admins can delete CVs"
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

-- Verify buckets were created
SELECT 
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types,
  created_at
FROM 
  storage.buckets
WHERE 
  id IN ('project-images', 'cvs')
ORDER BY 
  created_at;
