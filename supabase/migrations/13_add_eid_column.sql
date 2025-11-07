-- Add EID (Employee ID Number) column to employees table
ALTER TABLE employees ADD COLUMN IF NOT EXISTS eid VARCHAR(50) UNIQUE;

-- Create index for faster EID lookups
CREATE INDEX IF NOT EXISTS idx_employees_eid ON employees(eid);

-- Add comment for documentation
COMMENT ON COLUMN employees.eid IS 'Employee ID Number - unique identifier for login';

-- Update existing employees with placeholder EIDs (optional - you can remove this if not needed)
-- UPDATE employees SET eid = 'EID' || LPAD(CAST(ROW_NUMBER() OVER (ORDER BY created_at) AS TEXT), 4, '0') WHERE eid IS NULL;
