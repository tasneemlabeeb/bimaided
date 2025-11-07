-- Add leave date range columns to attendance table
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS leave_start_date DATE;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS leave_end_date DATE;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS supporting_document_url TEXT;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_attendance_leave_start_date ON attendance(leave_start_date);
CREATE INDEX IF NOT EXISTS idx_attendance_leave_end_date ON attendance(leave_end_date);

-- Add comments for documentation
COMMENT ON COLUMN attendance.leave_start_date IS 'Start date of leave period';
COMMENT ON COLUMN attendance.leave_end_date IS 'End date of leave period';
COMMENT ON COLUMN attendance.supporting_document_url IS 'URL to supporting document for leave request';

-- For existing leave records, copy the date to both start and end
UPDATE attendance 
SET leave_start_date = date, leave_end_date = date 
WHERE status = 'Leave' AND leave_start_date IS NULL;
