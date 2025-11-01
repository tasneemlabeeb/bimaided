-- Create enum for employment status
CREATE TYPE employment_status AS ENUM ('Active', 'On Leave', 'Resigned', 'Terminated');

-- Create enum for gender
CREATE TYPE gender_type AS ENUM ('Male', 'Female', 'Other');

-- Create enum for leave types
CREATE TYPE leave_type AS ENUM (
  'Sick Leave', 
  'Casual Leave', 
  'Hourly Leave', 
  'Half Day Leave', 
  'Full Day Leave',
  'Earned Leave', 
  'Paid Leave', 
  'Unpaid Leave', 
  'Maternity Leave', 
  'Other Leave'
);

-- Create enum for attendance status
CREATE TYPE attendance_status AS ENUM ('Present', 'Absent', 'Leave', 'Late');

-- Create enum for assignment status
CREATE TYPE assignment_status AS ENUM ('Active', 'Completed');

-- Create enum for user roles
CREATE TYPE user_role AS ENUM ('Admin', 'Employee');

-- Departments table
CREATE TABLE departments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  manager_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Designations table
CREATE TABLE designations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  level TEXT,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Employees table
CREATE TABLE employees (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  gender gender_type,
  date_of_birth DATE,
  national_id TEXT,
  email TEXT UNIQUE NOT NULL,
  phone_number TEXT,
  address TEXT,
  joining_date DATE NOT NULL DEFAULT CURRENT_DATE,
  employment_status employment_status DEFAULT 'Active',
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  designation_id UUID REFERENCES designations(id) ON DELETE SET NULL,
  supervisor_id UUID REFERENCES employees(id) ON DELETE SET NULL,
  profile_photo TEXT,
  remarks TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add manager foreign key to departments (circular reference handled after employees table exists)
ALTER TABLE departments ADD CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES employees(id) ON DELETE SET NULL;

-- User roles table (separate from employees for security)
CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role user_role NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, role)
);

-- Salary table
CREATE TABLE salaries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES employees(id) ON DELETE CASCADE NOT NULL,
  basic_salary DECIMAL(12, 2) NOT NULL,
  allowances DECIMAL(12, 2) DEFAULT 0,
  deductions DECIMAL(12, 2) DEFAULT 0,
  net_salary DECIMAL(12, 2) GENERATED ALWAYS AS (basic_salary + allowances - deductions) STORED,
  pay_frequency TEXT DEFAULT 'Monthly',
  effective_from DATE NOT NULL,
  effective_to DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Attendance and Leave table
CREATE TABLE attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES employees(id) ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL,
  status attendance_status NOT NULL,
  check_in_time TIME,
  check_out_time TIME,
  total_hours DECIMAL(5, 2),
  leave_type leave_type,
  leave_reason TEXT,
  leave_approved BOOLEAN DEFAULT FALSE,
  approved_by UUID REFERENCES employees(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(employee_id, date)
);

-- Documents table
CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES employees(id) ON DELETE CASCADE NOT NULL,
  document_type TEXT NOT NULL,
  file_url TEXT NOT NULL,
  expiry_date DATE,
  uploaded_on TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Projects/Assignments table
CREATE TABLE project_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES employees(id) ON DELETE CASCADE NOT NULL,
  project_name TEXT NOT NULL,
  role TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  status assignment_status DEFAULT 'Active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Emergency contacts table
CREATE TABLE emergency_contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES employees(id) ON DELETE CASCADE NOT NULL,
  contact_name TEXT NOT NULL,
  relationship TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Leave balances table (to track annual, sick, casual leave)
CREATE TABLE leave_balances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID REFERENCES employees(id) ON DELETE CASCADE NOT NULL,
  annual_leave_total INT DEFAULT 20,
  annual_leave_used INT DEFAULT 0,
  sick_leave_total INT DEFAULT 10,
  sick_leave_used INT DEFAULT 0,
  casual_leave_total INT DEFAULT 10,
  casual_leave_used INT DEFAULT 0,
  year INT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(employee_id, year)
);

-- Enable Row Level Security
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE designations ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE salaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_balances ENABLE ROW LEVEL SECURITY;

-- Create security definer function to check user role
CREATE OR REPLACE FUNCTION public.has_role(_user_id UUID, _role user_role)
RETURNS BOOLEAN
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles
    WHERE user_id = _user_id AND role = _role
  )
$$;

-- RLS Policies for departments
CREATE POLICY "Admins can manage departments"
  ON departments FOR ALL
  USING (public.has_role(auth.uid(), 'Admin'));

CREATE POLICY "Employees can view departments"
  ON departments FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- RLS Policies for designations
CREATE POLICY "Admins can manage designations"
  ON designations FOR ALL
  USING (public.has_role(auth.uid(), 'Admin'));

CREATE POLICY "Employees can view designations"
  ON designations FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- RLS Policies for employees
CREATE POLICY "Admins can manage employees"
  ON employees FOR ALL
  USING (public.has_role(auth.uid(), 'Admin'));

CREATE POLICY "Employees can view their own data"
  ON employees FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Employees can update their own data"
  ON employees FOR UPDATE
  USING (user_id = auth.uid());

-- RLS Policies for user_roles
CREATE POLICY "Admins can manage user roles"
  ON user_roles FOR ALL
  USING (public.has_role(auth.uid(), 'Admin'));

-- RLS Policies for salaries
CREATE POLICY "Admins can manage salaries"
  ON salaries FOR ALL
  USING (public.has_role(auth.uid(), 'Admin'));

CREATE POLICY "Employees can view their own salary"
  ON salaries FOR SELECT
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

-- RLS Policies for attendance
CREATE POLICY "Admins can manage attendance"
  ON attendance FOR ALL
  USING (public.has_role(auth.uid(), 'Admin'));

CREATE POLICY "Employees can view their own attendance"
  ON attendance FOR SELECT
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Employees can request leave"
  ON attendance FOR INSERT
  WITH CHECK (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    ) AND status = 'Leave'
  );

-- RLS Policies for documents
CREATE POLICY "Admins can manage documents"
  ON documents FOR ALL
  USING (public.has_role(auth.uid(), 'Admin'));

CREATE POLICY "Employees can view their own documents"
  ON documents FOR SELECT
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

-- RLS Policies for project_assignments
CREATE POLICY "Admins can manage assignments"
  ON project_assignments FOR ALL
  USING (public.has_role(auth.uid(), 'Admin'));

CREATE POLICY "Employees can view their own assignments"
  ON project_assignments FOR SELECT
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

-- RLS Policies for emergency_contacts
CREATE POLICY "Admins can manage emergency contacts"
  ON emergency_contacts FOR ALL
  USING (public.has_role(auth.uid(), 'Admin'));

CREATE POLICY "Employees can view their own emergency contacts"
  ON emergency_contacts FOR SELECT
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

-- RLS Policies for leave_balances
CREATE POLICY "Admins can manage leave balances"
  ON leave_balances FOR ALL
  USING (public.has_role(auth.uid(), 'Admin'));

CREATE POLICY "Employees can view their own leave balances"
  ON leave_balances FOR SELECT
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

-- Trigger function for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers for updated_at
CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON departments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_designations_updated_at BEFORE UPDATE ON designations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON employees
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_salaries_updated_at BEFORE UPDATE ON salaries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_attendance_updated_at BEFORE UPDATE ON attendance
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_project_assignments_updated_at BEFORE UPDATE ON project_assignments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_leave_balances_updated_at BEFORE UPDATE ON leave_balances
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();