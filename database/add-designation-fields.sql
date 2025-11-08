-- Migration: Add level and department_id to designations table
-- Run this in your Supabase SQL Editor

-- Step 1: Fix employees table - rename status to employment_status if needed
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'employees' AND column_name = 'status'
  ) THEN
    ALTER TABLE employees RENAME COLUMN status TO employment_status;
    
    -- Drop old constraint
    ALTER TABLE employees DROP CONSTRAINT IF EXISTS employees_status_check;
    
    -- Add new constraint
    ALTER TABLE employees ADD CONSTRAINT employees_employment_status_check 
      CHECK (employment_status IN ('Active', 'On Leave', 'Resigned', 'Terminated'));
  END IF;
END $$;

-- Step 2: Add the new columns to designations
ALTER TABLE designations 
ADD COLUMN IF NOT EXISTS level TEXT CHECK (level IN ('Junior', 'Mid', 'Senior', 'Lead', 'Manager')),
ADD COLUMN IF NOT EXISTS department_id UUID REFERENCES departments(id);

-- Step 3: Clear existing designations (if any) since they don't have the new structure
-- WARNING: This will delete existing designations. Only run if you haven't started using the system yet.
-- If you have existing data, you'll need to manually update each designation.
TRUNCATE TABLE designations CASCADE;

-- Step 4: Make sure departments exist
INSERT INTO departments (name, description) VALUES
  ('Architecture', 'Architectural design and BIM modeling'),
  ('Engineering', 'Structural and MEP engineering'),
  ('VDC', 'Virtual Design and Construction'),
  ('Human Resources', 'HR and administration'),
  ('Management', 'Project and business management')
ON CONFLICT (name) DO NOTHING;

-- Step 5: Add updated designations with the new structure
INSERT INTO designations (name, level, department_id, description) VALUES
  ('BIM Manager', 'Manager', (SELECT id FROM departments WHERE name = 'Architecture' LIMIT 1), 'BIM project manager'),
  ('Senior Architect', 'Senior', (SELECT id FROM departments WHERE name = 'Architecture' LIMIT 1), 'Senior architectural designer'),
  ('BIM Modeler', 'Mid', (SELECT id FROM departments WHERE name = 'Architecture' LIMIT 1), 'BIM modeling specialist'),
  ('Revit Technician', 'Junior', (SELECT id FROM departments WHERE name = 'Architecture' LIMIT 1), 'Revit drafting and modeling'),
  ('BIM Coordinator', 'Mid', (SELECT id FROM departments WHERE name = 'VDC' LIMIT 1), 'BIM coordination specialist'),
  ('Structural Engineer', 'Senior', (SELECT id FROM departments WHERE name = 'Engineering' LIMIT 1), 'Structural engineering specialist'),
  ('MEP Engineer', 'Mid', (SELECT id FROM departments WHERE name = 'Engineering' LIMIT 1), 'MEP engineering specialist'),
  ('HR Manager', 'Manager', (SELECT id FROM departments WHERE name = 'Human Resources' LIMIT 1), 'Human resources manager'),
  ('Project Manager', 'Manager', (SELECT id FROM departments WHERE name = 'Management' LIMIT 1), 'Project management lead')
ON CONFLICT (name) DO NOTHING;

-- Verify the changes
SELECT 
  d.name as designation,
  d.level,
  dept.name as department,
  d.description
FROM designations d
LEFT JOIN departments dept ON d.department_id = dept.id
ORDER BY dept.name, d.level;

SELECT 'Migration completed successfully! ✅' AS status;
