-- Add missing leave approval columns to attendance table
ALTER TABLE attendance 
ADD COLUMN IF NOT EXISTS leave_approved BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS supervisor_approved BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS supervisor_approved_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS supervisor_approved_by UUID REFERENCES employees(id),
ADD COLUMN IF NOT EXISTS admin_approved BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS admin_approved_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS admin_approved_by UUID REFERENCES employees(id);

-- Add Google Drive file tracking columns to attendance table
ALTER TABLE attendance 
ADD COLUMN IF NOT EXISTS supporting_document_url TEXT,
ADD COLUMN IF NOT EXISTS supporting_document_id TEXT;

-- Add indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_attendance_document_id ON attendance(supporting_document_id);
CREATE INDEX IF NOT EXISTS idx_attendance_supervisor_approved ON attendance(supervisor_approved);
CREATE INDEX IF NOT EXISTS idx_attendance_admin_approved ON attendance(admin_approved);
