-- =====================================================
-- FIX PROJECTS TABLE RLS POLICIES
-- =====================================================
-- Projects table has RLS enabled but no policies
-- This allows public read and admin write access

-- Drop existing policies if any
DROP POLICY IF EXISTS "Public can view published projects" ON projects;
DROP POLICY IF EXISTS "Admin can insert projects" ON projects;
DROP POLICY IF EXISTS "Admin can update projects" ON projects;
DROP POLICY IF EXISTS "Admin can delete projects" ON projects;

-- Allow anyone to view published projects
CREATE POLICY "Public can view published projects"
ON projects FOR SELECT
USING (published = true OR auth.role() = 'authenticated');

-- Allow admins to insert projects
CREATE POLICY "Admin can insert projects"
ON projects FOR INSERT
WITH CHECK (
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- Allow admins to update projects
CREATE POLICY "Admin can update projects"
ON projects FOR UPDATE
USING (
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- Allow admins to delete projects
CREATE POLICY "Admin can delete projects"
ON projects FOR DELETE
USING (
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- Verify policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE tablename = 'projects';
