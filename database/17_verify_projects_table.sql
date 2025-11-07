-- Verify and add missing columns to projects table

-- Check if preview_image column exists, if not add it
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' AND column_name = 'preview_image'
    ) THEN
        ALTER TABLE projects ADD COLUMN preview_image TEXT;
    END IF;
END $$;

-- Check if gallery image columns exist, if not add them
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' AND column_name = 'gallery_image_1'
    ) THEN
        ALTER TABLE projects ADD COLUMN gallery_image_1 TEXT;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' AND column_name = 'gallery_image_2'
    ) THEN
        ALTER TABLE projects ADD COLUMN gallery_image_2 TEXT;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' AND column_name = 'gallery_image_3'
    ) THEN
        ALTER TABLE projects ADD COLUMN gallery_image_3 TEXT;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' AND column_name = 'gallery_image_4'
    ) THEN
        ALTER TABLE projects ADD COLUMN gallery_image_4 TEXT;
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' AND column_name = 'gallery_image_5'
    ) THEN
        ALTER TABLE projects ADD COLUMN gallery_image_5 TEXT;
    END IF;
END $$;

-- Check if client_name column exists, if not add it
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' AND column_name = 'client_name'
    ) THEN
        ALTER TABLE projects ADD COLUMN client_name VARCHAR(255);
    END IF;
END $$;

-- Check if completion_date column exists, if not add it
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' AND column_name = 'completion_date'
    ) THEN
        ALTER TABLE projects ADD COLUMN completion_date VARCHAR(50);
    END IF;
END $$;

-- Check if lod column exists, if not add it
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' AND column_name = 'lod'
    ) THEN
        ALTER TABLE projects ADD COLUMN lod VARCHAR(50);
    END IF;
END $$;

-- Check if location column exists, if not add it
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' AND column_name = 'location'
    ) THEN
        ALTER TABLE projects ADD COLUMN location VARCHAR(255);
    END IF;
END $$;

-- Check if scope column exists, if not add it
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'projects' AND column_name = 'scope'
    ) THEN
        ALTER TABLE projects ADD COLUMN scope TEXT;
    END IF;
END $$;

-- Verify the columns were added
SELECT 
    column_name, 
    data_type,
    is_nullable
FROM 
    information_schema.columns
WHERE 
    table_name = 'projects'
ORDER BY 
    ordinal_position;
