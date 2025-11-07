-- =====================================================
-- BIMSync Portal - Complete Database Schema
-- =====================================================
-- Description: Complete Supabase database schema for BIMSync Employee Management System
-- Created: 2025-11-08
-- Version: 1.0
-- 
-- Tables: 14 total
-- - departments, designations, employees, user_roles
-- - emergency_contacts, documents, salaries, leave_balances
-- - attendance, project_assignments, projects
-- - career_postings, contact_inquiries, ip_whitelist
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- ENUMS
-- =====================================================

-- User roles enum
CREATE TYPE user_role AS ENUM ('admin', 'employee');

-- Employment status enum
CREATE TYPE employment_status AS ENUM ('Active', 'On Leave', 'Resigned', 'Terminated');

-- Gender type enum
CREATE TYPE gender_type AS ENUM ('Male', 'Female', 'Other');

-- Attendance status enum
CREATE TYPE attendance_status AS ENUM ('Present', 'Absent', 'Leave', 'Late');

-- Leave type enum
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

-- Assignment status enum
CREATE TYPE assignment_status AS ENUM ('Active', 'Completed');

-- Project category enum
CREATE TYPE project_category AS ENUM (
  'Commercial',
  'Education & Healthcare',
  'Cultural & Sports',
  'Residential',
  'Infrastructure & Municipal',
  'Industrial & Park'
);

-- =====================================================
-- TABLES
-- =====================================================

-- -----------------------------------------------------
-- Departments Table
-- -----------------------------------------------------
CREATE TABLE departments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  description TEXT,
  manager_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE departments IS 'Company departments and organizational units';
COMMENT ON COLUMN departments.manager_id IS 'References employee who manages this department';

-- -----------------------------------------------------
-- Designations Table
-- -----------------------------------------------------
CREATE TABLE designations (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  level VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE designations IS 'Job titles and positions within the organization';
COMMENT ON COLUMN designations.level IS 'Hierarchical level (e.g., Junior, Senior, Manager)';

-- -----------------------------------------------------
-- Employees Table
-- -----------------------------------------------------
CREATE TABLE employees (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  eid VARCHAR(50) UNIQUE,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone_number VARCHAR(50),
  date_of_birth DATE,
  gender gender_type,
  national_id VARCHAR(100),
  address TEXT,
  profile_photo TEXT,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  designation_id UUID REFERENCES designations(id) ON DELETE SET NULL,
  supervisor_id UUID REFERENCES employees(id) ON DELETE SET NULL,
  joining_date DATE NOT NULL DEFAULT CURRENT_DATE,
  employment_status employment_status DEFAULT 'Active',
  user_id UUID UNIQUE,
  remarks TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE employees IS 'Core employee information and organizational relationships';
COMMENT ON COLUMN employees.eid IS 'Employee ID Number - unique identifier for login';
COMMENT ON COLUMN employees.user_id IS 'References Supabase auth.users.id for authentication';
COMMENT ON COLUMN employees.supervisor_id IS 'Direct supervisor (employee hierarchy)';

-- Add foreign key for manager_id after employees table is created
ALTER TABLE departments ADD CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES employees(id) ON DELETE SET NULL;

-- -----------------------------------------------------
-- User Roles Table
-- -----------------------------------------------------
CREATE TABLE user_roles (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID NOT NULL,
  role user_role NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, role)
);

COMMENT ON TABLE user_roles IS 'Maps Supabase auth users to application roles (admin/employee)';

-- -----------------------------------------------------
-- Emergency Contacts Table
-- -----------------------------------------------------
CREATE TABLE emergency_contacts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  contact_name VARCHAR(255) NOT NULL,
  relationship VARCHAR(100) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE emergency_contacts IS 'Emergency contact information for employees';

-- -----------------------------------------------------
-- Documents Table
-- -----------------------------------------------------
CREATE TABLE documents (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  document_type VARCHAR(100) NOT NULL,
  file_url TEXT NOT NULL,
  expiry_date DATE,
  uploaded_on TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE documents IS 'Employee document storage (passport, visa, certificates, etc.)';
COMMENT ON COLUMN documents.file_url IS 'URL to document in Supabase Storage';

-- -----------------------------------------------------
-- Salaries Table
-- -----------------------------------------------------
CREATE TABLE salaries (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  basic_salary DECIMAL(12, 2) NOT NULL,
  allowances DECIMAL(12, 2) DEFAULT 0,
  deductions DECIMAL(12, 2) DEFAULT 0,
  net_salary DECIMAL(12, 2),
  pay_frequency VARCHAR(50),
  effective_from DATE NOT NULL,
  effective_to DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE salaries IS 'Employee salary and compensation information';
COMMENT ON COLUMN salaries.pay_frequency IS 'Monthly, Bi-weekly, Weekly, etc.';

-- -----------------------------------------------------
-- Leave Balances Table
-- -----------------------------------------------------
CREATE TABLE leave_balances (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  year INTEGER NOT NULL,
  sick_leave_total DECIMAL(5, 2) DEFAULT 10,
  sick_leave_used DECIMAL(5, 2) DEFAULT 0,
  casual_leave_total DECIMAL(5, 2) DEFAULT 15,
  casual_leave_used DECIMAL(5, 2) DEFAULT 0,
  annual_leave_total DECIMAL(5, 2) DEFAULT 20,
  annual_leave_used DECIMAL(5, 2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(employee_id, year)
);

COMMENT ON TABLE leave_balances IS 'Tracks annual leave balances for each employee';
COMMENT ON COLUMN leave_balances.year IS 'Calendar year for leave balance';

-- -----------------------------------------------------
-- Attendance Table
-- -----------------------------------------------------
CREATE TABLE attendance (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  check_in_time TIMESTAMPTZ,
  check_out_time TIMESTAMPTZ,
  total_hours DECIMAL(5, 2),
  status attendance_status NOT NULL,
  leave_type leave_type,
  leave_reason TEXT,
  leave_start_date DATE,
  leave_end_date DATE,
  supporting_document_url TEXT,
  approved_by UUID REFERENCES employees(id),
  supervisor_approved BOOLEAN DEFAULT FALSE,
  supervisor_approved_by UUID REFERENCES employees(id),
  supervisor_approved_at TIMESTAMPTZ,
  admin_approved BOOLEAN DEFAULT FALSE,
  admin_approved_by UUID REFERENCES employees(id),
  admin_approved_at TIMESTAMPTZ,
  ip_address VARCHAR(45),
  manually_added BOOLEAN DEFAULT FALSE,
  added_by UUID,
  admin_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(employee_id, date)
);

COMMENT ON TABLE attendance IS 'Daily attendance tracking with leave management and two-level approval';
COMMENT ON COLUMN attendance.leave_start_date IS 'Start date of leave period (for multi-day leaves)';
COMMENT ON COLUMN attendance.leave_end_date IS 'End date of leave period';
COMMENT ON COLUMN attendance.supervisor_approved IS 'First level approval by immediate supervisor';
COMMENT ON COLUMN attendance.admin_approved IS 'Second level approval by admin/HR';
COMMENT ON COLUMN attendance.ip_address IS 'IP address from which attendance was recorded';
COMMENT ON COLUMN attendance.manually_added IS 'Indicates if attendance was manually added by admin';

-- -----------------------------------------------------
-- Project Assignments Table
-- -----------------------------------------------------
CREATE TABLE project_assignments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  project_name VARCHAR(500) NOT NULL,
  role VARCHAR(100) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  status assignment_status DEFAULT 'Active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE project_assignments IS 'Tracks employee assignments to internal projects';
COMMENT ON COLUMN project_assignments.project_name IS 'Name of the project (free text)';
COMMENT ON COLUMN project_assignments.role IS 'Employee role in the project (e.g., BIM Coordinator, Architect)';

-- -----------------------------------------------------
-- Projects Table (Portfolio/Public Projects)
-- -----------------------------------------------------
CREATE TABLE projects (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title VARCHAR(500) NOT NULL,
  description TEXT NOT NULL,
  category project_category NOT NULL,
  client_name VARCHAR(255),
  completion_date VARCHAR(100),
  project_value DECIMAL(15, 2),
  image_url TEXT,
  gallery_image_1 TEXT,
  gallery_image_2 TEXT,
  gallery_image_3 TEXT,
  gallery_image_4 TEXT,
  gallery_image_5 TEXT,
  gallery_image_6 TEXT,
  published BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE projects IS 'Portfolio projects displayed on public website';
COMMENT ON COLUMN projects.published IS 'Whether project is visible on website';
COMMENT ON COLUMN projects.gallery_image_1 IS 'Gallery image URLs for project showcase';

-- -----------------------------------------------------
-- Career Postings Table
-- -----------------------------------------------------
CREATE TABLE career_postings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title VARCHAR(500) NOT NULL,
  description TEXT NOT NULL,
  employment_type VARCHAR(100) NOT NULL,
  location VARCHAR(255) NOT NULL,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  responsibilities TEXT,
  requirements TEXT,
  posted_date TIMESTAMPTZ DEFAULT NOW(),
  closing_date DATE,
  published BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE career_postings IS 'Job openings displayed on careers page';
COMMENT ON COLUMN career_postings.employment_type IS 'Full-time, Part-time, Contract, etc.';
COMMENT ON COLUMN career_postings.published IS 'Whether job posting is visible on website';

-- -----------------------------------------------------
-- Contact Inquiries Table
-- -----------------------------------------------------
CREATE TABLE contact_inquiries (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  subject VARCHAR(500) NOT NULL,
  message TEXT NOT NULL,
  status VARCHAR(50) DEFAULT 'new' CHECK (status IN ('new', 'in-progress', 'resolved', 'closed')),
  admin_notes TEXT,
  assigned_to UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE contact_inquiries IS 'Contact form submissions from website';
COMMENT ON COLUMN contact_inquiries.assigned_to IS 'Employee assigned to handle this inquiry (references employees.user_id)';

-- -----------------------------------------------------
-- IP Whitelist Table
-- -----------------------------------------------------
CREATE TABLE ip_whitelist (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  ip_address VARCHAR(45) NOT NULL UNIQUE,
  location_name VARCHAR(255),
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  added_by UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE ip_whitelist IS 'Whitelisted IP addresses for attendance check-in authorization';
COMMENT ON COLUMN ip_whitelist.added_by IS 'Admin user who added this IP';

-- =====================================================
-- INDEXES
-- =====================================================

-- Employees indexes
CREATE INDEX idx_employees_email ON employees(email);
CREATE INDEX idx_employees_eid ON employees(eid);
CREATE INDEX idx_employees_user_id ON employees(user_id);
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_designation ON employees(designation_id);
CREATE INDEX idx_employees_supervisor ON employees(supervisor_id);
CREATE INDEX idx_employees_status ON employees(employment_status);

-- Attendance indexes
CREATE INDEX idx_attendance_employee ON attendance(employee_id);
CREATE INDEX idx_attendance_date ON attendance(date);
CREATE INDEX idx_attendance_employee_date ON attendance(employee_id, date);
CREATE INDEX idx_attendance_status ON attendance(status);
CREATE INDEX idx_attendance_leave_start_date ON attendance(leave_start_date);
CREATE INDEX idx_attendance_leave_end_date ON attendance(leave_end_date);

-- Project assignments indexes
CREATE INDEX idx_project_assignments_employee ON project_assignments(employee_id);
CREATE INDEX idx_project_assignments_status ON project_assignments(status);

-- Projects indexes
CREATE INDEX idx_projects_category ON projects(category);
CREATE INDEX idx_projects_published ON projects(published);

-- Career postings indexes
CREATE INDEX idx_career_postings_published ON career_postings(published);
CREATE INDEX idx_career_postings_department ON career_postings(department_id);

-- Contact inquiries indexes
CREATE INDEX idx_contact_inquiries_status ON contact_inquiries(status);
CREATE INDEX idx_contact_inquiries_created_at ON contact_inquiries(created_at DESC);
CREATE INDEX idx_contact_inquiries_email ON contact_inquiries(email);

-- IP whitelist indexes
CREATE INDEX idx_ip_whitelist_active ON ip_whitelist(ip_address, is_active);

-- User roles indexes
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);

-- Leave balances indexes
CREATE INDEX idx_leave_balances_employee ON leave_balances(employee_id);
CREATE INDEX idx_leave_balances_year ON leave_balances(year);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function to check if user has a specific role
CREATE OR REPLACE FUNCTION has_role(_role user_role, _user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = _user_id AND role = _role
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION has_role IS 'Check if a user has a specific role (admin/employee)';

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Update timestamps triggers
CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON departments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_designations_updated_at BEFORE UPDATE ON designations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON employees
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_emergency_contacts_updated_at BEFORE UPDATE ON emergency_contacts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_salaries_updated_at BEFORE UPDATE ON salaries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_leave_balances_updated_at BEFORE UPDATE ON leave_balances
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_attendance_updated_at BEFORE UPDATE ON attendance
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_project_assignments_updated_at BEFORE UPDATE ON project_assignments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_career_postings_updated_at BEFORE UPDATE ON career_postings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contact_inquiries_updated_at BEFORE UPDATE ON contact_inquiries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ip_whitelist_updated_at BEFORE UPDATE ON ip_whitelist
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE designations ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE salaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE career_postings ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_inquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE ip_whitelist ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------
-- Departments RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Everyone can view departments"
  ON departments FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin can manage departments"
  ON departments FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- Designations RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Everyone can view designations"
  ON designations FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin can manage designations"
  ON designations FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- Employees RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Admin can view all employees"
  ON employees FOR SELECT
  TO authenticated
  USING (has_role('admin', auth.uid()));

CREATE POLICY "Employees can view their own data"
  ON employees FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Supervisors can view their team"
  ON employees FOR SELECT
  TO authenticated
  USING (
    supervisor_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Admin can manage employees"
  ON employees FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- User Roles RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Users can view their own roles"
  ON user_roles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Admin can manage all roles"
  ON user_roles FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- Emergency Contacts RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Employees can view their own emergency contacts"
  ON emergency_contacts FOR SELECT
  TO authenticated
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Admin can manage all emergency contacts"
  ON emergency_contacts FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- Documents RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Employees can view their own documents"
  ON documents FOR SELECT
  TO authenticated
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Admin can manage all documents"
  ON documents FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- Salaries RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Employees can view their own salary"
  ON salaries FOR SELECT
  TO authenticated
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Admin can manage all salaries"
  ON salaries FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- Leave Balances RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Employees can view their own leave balance"
  ON leave_balances FOR SELECT
  TO authenticated
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Admin can manage all leave balances"
  ON leave_balances FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- Attendance RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Employees can view their own attendance"
  ON attendance FOR SELECT
  TO authenticated
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Supervisors can view team attendance"
  ON attendance FOR SELECT
  TO authenticated
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE supervisor_id IN (
        SELECT id FROM employees WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Admin can view all attendance"
  ON attendance FOR SELECT
  TO authenticated
  USING (has_role('admin', auth.uid()));

CREATE POLICY "Employees can insert their own attendance"
  ON attendance FOR INSERT
  TO authenticated
  WITH CHECK (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Admin can manage all attendance"
  ON attendance FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- Project Assignments RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Employees can view their own assignments"
  ON project_assignments FOR SELECT
  TO authenticated
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Supervisors can view team assignments"
  ON project_assignments FOR SELECT
  TO authenticated
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE supervisor_id IN (
        SELECT id FROM employees WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Admin can manage all project assignments"
  ON project_assignments FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- Projects RLS Policies (Public Portfolio)
-- -----------------------------------------------------
CREATE POLICY "Anyone can view published projects"
  ON projects FOR SELECT
  TO anon, authenticated
  USING (published = true);

CREATE POLICY "Admin can view all projects"
  ON projects FOR SELECT
  TO authenticated
  USING (has_role('admin', auth.uid()));

CREATE POLICY "Admin can manage projects"
  ON projects FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- Career Postings RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Anyone can view published career postings"
  ON career_postings FOR SELECT
  TO anon, authenticated
  USING (published = true);

CREATE POLICY "Admin can view all career postings"
  ON career_postings FOR SELECT
  TO authenticated
  USING (has_role('admin', auth.uid()));

CREATE POLICY "Admin can manage career postings"
  ON career_postings FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- Contact Inquiries RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Anyone can submit contact inquiries"
  ON contact_inquiries FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Admin can view all contact inquiries"
  ON contact_inquiries FOR SELECT
  TO authenticated
  USING (has_role('admin', auth.uid()));

CREATE POLICY "Admin can update contact inquiries"
  ON contact_inquiries FOR UPDATE
  TO authenticated
  USING (has_role('admin', auth.uid()))
  WITH CHECK (has_role('admin', auth.uid()));

CREATE POLICY "Admin can delete contact inquiries"
  ON contact_inquiries FOR DELETE
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- -----------------------------------------------------
-- IP Whitelist RLS Policies
-- -----------------------------------------------------
CREATE POLICY "Admin can manage IP whitelist"
  ON ip_whitelist FOR ALL
  TO authenticated
  USING (has_role('admin', auth.uid()));

-- =====================================================
-- SEED DATA
-- =====================================================

-- Insert default departments
INSERT INTO departments (name, description) VALUES
  ('Administration', 'Administrative and management staff'),
  ('BIM Department', 'Building Information Modeling team'),
  ('Architecture', 'Architectural design and planning'),
  ('Engineering', 'Civil, MEP, and structural engineering'),
  ('Project Management', 'Project coordination and management'),
  ('Quality Assurance', 'Quality control and assurance'),
  ('IT Support', 'Information technology support')
ON CONFLICT (name) DO NOTHING;

-- Insert default designations
INSERT INTO designations (name, level) VALUES
  ('Managing Director', 'Executive'),
  ('BIM Manager', 'Senior Management'),
  ('Senior BIM Coordinator', 'Senior'),
  ('BIM Coordinator', 'Mid-Level'),
  ('Junior BIM Coordinator', 'Junior'),
  ('Architect', 'Mid-Level'),
  ('Senior Architect', 'Senior'),
  ('Structural Engineer', 'Mid-Level'),
  ('MEP Engineer', 'Mid-Level'),
  ('Civil Engineer', 'Mid-Level'),
  ('Project Manager', 'Senior Management'),
  ('Project Coordinator', 'Mid-Level'),
  ('QA/QC Engineer', 'Mid-Level'),
  ('Draughtsman', 'Junior'),
  ('3D Modeler', 'Mid-Level'),
  ('HR Manager', 'Senior Management'),
  ('Accountant', 'Mid-Level'),
  ('IT Administrator', 'Mid-Level')
ON CONFLICT DO NOTHING;

-- =====================================================
-- STORAGE BUCKETS (Run separately in Supabase Dashboard)
-- =====================================================

-- Note: Storage buckets must be created via Supabase Dashboard or API
-- Recommended buckets:
-- 1. employee-photos (private) - Profile pictures
-- 2. employee-documents (private) - Personal documents
-- 3. project-images (public) - Portfolio project images
-- 4. leave-attachments (private) - Leave request supporting documents

-- =====================================================
-- POST-INSTALLATION NOTES
-- =====================================================

-- After running this migration:
-- 
-- 1. Create your first admin user:
--    a. Sign up via Supabase Auth (email/password)
--    b. Get the user ID from auth.users table
--    c. Insert into user_roles table: INSERT INTO user_roles (user_id, role) VALUES ('YOUR_USER_ID', 'admin');
--
-- 2. Create employee record for admin:
--    INSERT INTO employees (first_name, last_name, email, user_id, joining_date)
--    VALUES ('Admin', 'User', 'admin@example.com', 'YOUR_USER_ID', CURRENT_DATE);
--
-- 3. Set up storage buckets in Supabase Dashboard
--
-- 4. Update .env file with Supabase credentials:
--    VITE_SUPABASE_URL=your_supabase_project_url
--    VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
--
-- 5. Generate TypeScript types (optional):
--    npx supabase gen types typescript --project-id YOUR_PROJECT_ID > src/integrations/supabase/types.ts

-- =====================================================
-- END OF SCHEMA
-- =====================================================
