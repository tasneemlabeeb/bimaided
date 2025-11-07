-- Add IP whitelist table
CREATE TABLE IF NOT EXISTS ip_whitelist (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  ip_address VARCHAR(45) NOT NULL UNIQUE,
  location_name VARCHAR(255),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add RLS policies for ip_whitelist
ALTER TABLE ip_whitelist ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admin can manage IP whitelist"
ON ip_whitelist
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.user_id = auth.uid()
    AND user_roles.role = 'admin'
  )
);

-- Add new columns to attendance table
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS ip_address VARCHAR(45);
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS manually_added BOOLEAN DEFAULT FALSE;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS added_by UUID;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS admin_notes TEXT;

-- Create index on ip_address for faster lookups
CREATE INDEX IF NOT EXISTS idx_ip_whitelist_active ON ip_whitelist(ip_address, is_active);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON attendance(date);
CREATE INDEX IF NOT EXISTS idx_attendance_employee_date ON attendance(employee_id, date);

-- Add comment for documentation
COMMENT ON TABLE ip_whitelist IS 'Stores whitelisted IP addresses for attendance check-in authorization';
COMMENT ON COLUMN attendance.ip_address IS 'IP address from which the attendance was recorded';
COMMENT ON COLUMN attendance.manually_added IS 'Indicates if attendance was manually added by an admin';
COMMENT ON COLUMN attendance.added_by IS 'User ID of the admin who manually added the record';
COMMENT ON COLUMN attendance.admin_notes IS 'Notes added by admin for manually added records';
