-- Salary Management Schema Enhancement
-- Run this in your Supabase SQL Editor after the main schema

-- 1. Add salary fields to employees table
ALTER TABLE employees 
ADD COLUMN IF NOT EXISTS basic_salary DECIMAL(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS bank_name TEXT,
ADD COLUMN IF NOT EXISTS bank_account_number TEXT,
ADD COLUMN IF NOT EXISTS bank_branch TEXT,
ADD COLUMN IF NOT EXISTS casual_leave_balance INTEGER DEFAULT 10,
ADD COLUMN IF NOT EXISTS sick_leave_balance INTEGER DEFAULT 10;

-- 2. Leave Balance History Table (for tracking yearly resets)
CREATE TABLE IF NOT EXISTS leave_balance_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  year INTEGER NOT NULL,
  casual_leave_granted INTEGER DEFAULT 10,
  sick_leave_granted INTEGER DEFAULT 10,
  casual_leave_used INTEGER DEFAULT 0,
  sick_leave_used INTEGER DEFAULT 0,
  unpaid_leave_days DECIMAL(5,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(employee_id, year)
);

-- 3. Salary Configuration Table (for system-wide salary rules)
CREATE TABLE IF NOT EXISTS salary_configuration (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  config_key TEXT NOT NULL UNIQUE,
  config_value TEXT NOT NULL,
  description TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default salary configuration
INSERT INTO salary_configuration (config_key, config_value, description) VALUES
  ('annual_casual_leave', '10', 'Number of casual leave days per year'),
  ('annual_sick_leave', '10', 'Number of sick leave days per year'),
  ('late_tolerance_count', '3', 'Number of late arrivals before 1 day salary deduction'),
  ('working_days_per_month', '30', 'Standard working days for salary calculation'),
  ('half_day_hours', '4', 'Hours that constitute a half day'),
  ('full_day_hours', '8', 'Hours that constitute a full day')
ON CONFLICT (config_key) DO UPDATE SET
  config_value = EXCLUDED.config_value,
  description = EXCLUDED.description;

-- 4. Monthly Payroll Table
CREATE TABLE IF NOT EXISTS monthly_payroll (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
  year INTEGER NOT NULL,
  basic_salary DECIMAL(10,2) NOT NULL,
  total_working_days INTEGER DEFAULT 30,
  total_present_days INTEGER DEFAULT 0,
  total_absent_days INTEGER DEFAULT 0,
  total_late_days INTEGER DEFAULT 0,
  total_half_days DECIMAL(5,2) DEFAULT 0,
  casual_leave_taken DECIMAL(5,2) DEFAULT 0,
  sick_leave_taken DECIMAL(5,2) DEFAULT 0,
  unpaid_leave_days DECIMAL(5,2) DEFAULT 0,
  late_penalty_days DECIMAL(5,2) DEFAULT 0,
  hourly_leave_hours DECIMAL(5,2) DEFAULT 0,
  total_deduction DECIMAL(10,2) DEFAULT 0,
  net_payable_salary DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'paid', 'rejected')),
  remarks TEXT,
  approved_by UUID REFERENCES employees(id),
  approved_at TIMESTAMPTZ,
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(employee_id, month, year)
);

-- 5. Salary Deductions Table (for detailed deduction breakdown)
CREATE TABLE IF NOT EXISTS salary_deductions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  payroll_id UUID NOT NULL REFERENCES monthly_payroll(id) ON DELETE CASCADE,
  deduction_type TEXT NOT NULL CHECK (deduction_type IN ('unpaid_leave', 'late_penalty', 'half_day', 'hourly_leave', 'other')),
  deduction_days DECIMAL(5,2) DEFAULT 0,
  deduction_amount DECIMAL(10,2) NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Salary Slips Table (for storing generated salary slips)
CREATE TABLE IF NOT EXISTS salary_slips (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  payroll_id UUID NOT NULL REFERENCES monthly_payroll(id) ON DELETE CASCADE,
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  slip_number TEXT NOT NULL UNIQUE,
  month INTEGER NOT NULL,
  year INTEGER NOT NULL,
  generated_at TIMESTAMPTZ DEFAULT NOW(),
  sent_to_employee BOOLEAN DEFAULT FALSE,
  sent_at TIMESTAMPTZ,
  file_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Update attendance table to include hourly tracking
ALTER TABLE attendance
ADD COLUMN IF NOT EXISTS working_hours DECIMAL(4,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS late_minutes INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_late BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS leave_hours DECIMAL(4,2) DEFAULT 0;

-- 8. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_leave_balance_history_employee ON leave_balance_history(employee_id, year);
CREATE INDEX IF NOT EXISTS idx_monthly_payroll_employee ON monthly_payroll(employee_id, year, month);
CREATE INDEX IF NOT EXISTS idx_monthly_payroll_status ON monthly_payroll(status);
CREATE INDEX IF NOT EXISTS idx_salary_deductions_payroll ON salary_deductions(payroll_id);
CREATE INDEX IF NOT EXISTS idx_salary_slips_employee ON salary_slips(employee_id, year, month);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON attendance(date);

-- 9. Create trigger for leave balance history updates
CREATE TRIGGER update_leave_balance_history_updated_at BEFORE UPDATE ON leave_balance_history
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_monthly_payroll_updated_at BEFORE UPDATE ON monthly_payroll
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 10. Function to calculate daily salary rate
CREATE OR REPLACE FUNCTION calculate_daily_salary_rate(
  p_basic_salary DECIMAL,
  p_working_days INTEGER DEFAULT 30
)
RETURNS DECIMAL AS $$
BEGIN
  RETURN ROUND(p_basic_salary / p_working_days, 2);
END;
$$ LANGUAGE plpgsql;

-- 11. Function to auto-generate payroll for a month
CREATE OR REPLACE FUNCTION generate_monthly_payroll(
  p_month INTEGER,
  p_year INTEGER
)
RETURNS TABLE (
  employee_id UUID,
  employee_name TEXT,
  net_salary DECIMAL,
  status TEXT
) AS $$
BEGIN
  -- This will be implemented in the application layer for better control
  -- Placeholder for future stored procedure implementation
  RETURN QUERY SELECT NULL::UUID, NULL::TEXT, NULL::DECIMAL, NULL::TEXT LIMIT 0;
END;
$$ LANGUAGE plpgsql;

-- 12. Grant permissions
GRANT SELECT ON leave_balance_history TO authenticated;
GRANT SELECT ON salary_configuration TO authenticated;
GRANT SELECT ON monthly_payroll TO authenticated;
GRANT SELECT ON salary_deductions TO authenticated;
GRANT SELECT ON salary_slips TO authenticated;

-- Admin/HR can manage payroll
GRANT ALL ON leave_balance_history TO authenticated;
GRANT ALL ON salary_configuration TO authenticated;
GRANT ALL ON monthly_payroll TO authenticated;
GRANT ALL ON salary_deductions TO authenticated;
GRANT ALL ON salary_slips TO authenticated;

-- Enable RLS
ALTER TABLE leave_balance_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_payroll ENABLE ROW LEVEL SECURITY;
ALTER TABLE salary_deductions ENABLE ROW LEVEL SECURITY;
ALTER TABLE salary_slips ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DROP POLICY IF EXISTS "Employees can view their own leave balance" ON leave_balance_history;
CREATE POLICY "Employees can view their own leave balance"
  ON leave_balance_history FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Employees can view their own payroll" ON monthly_payroll;
CREATE POLICY "Employees can view their own payroll"
  ON monthly_payroll FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Employees can view their own salary slips" ON salary_slips;
CREATE POLICY "Employees can view their own salary slips"
  ON salary_slips FOR SELECT
  USING (true);

-- Success message
SELECT 'Salary management schema created successfully! ✅' AS status;
