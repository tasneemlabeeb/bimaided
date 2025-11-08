-- =====================================================
-- ADD MISSING COLUMNS TO PROJECTS TABLE
-- =====================================================
-- This migration adds category, gallery images, and published fields

-- Add category column
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS category TEXT;

-- Add gallery image columns
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS gallery_image_1 TEXT,
ADD COLUMN IF NOT EXISTS gallery_image_2 TEXT,
ADD COLUMN IF NOT EXISTS gallery_image_3 TEXT,
ADD COLUMN IF NOT EXISTS gallery_image_4 TEXT,
ADD COLUMN IF NOT EXISTS gallery_image_5 TEXT;

-- Add published column
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS published BOOLEAN DEFAULT true;

-- Verify the changes
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'projects' 
ORDER BY ordinal_position;
