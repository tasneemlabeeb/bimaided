-- Create assignments table
CREATE TABLE IF NOT EXISTS assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  project_note TEXT,
  start_date DATE NOT NULL,
  deadline DATE NOT NULL,
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'approved')),
  supervisor_id UUID REFERENCES employees(id) ON DELETE SET NULL,
  created_by UUID REFERENCES employees(id) ON DELETE SET NULL,
  approved_by UUID REFERENCES employees(id) ON DELETE SET NULL,
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create assignment_members table (junction table for employees assigned to assignments)
CREATE TABLE IF NOT EXISTS assignment_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID REFERENCES assignments(id) ON DELETE CASCADE,
  employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
  role TEXT NOT NULL,
  personal_note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(assignment_id, employee_id)
);

-- Enable RLS
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_members ENABLE ROW LEVEL SECURITY;

-- Policies for assignments table

-- Anyone authenticated can view assignments
CREATE POLICY "Authenticated users can view assignments"
  ON assignments
  FOR SELECT
  TO authenticated
  USING (true);

-- Only admins can create assignments
CREATE POLICY "Admins can create assignments"
  ON assignments
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'Admin'
    )
  );

-- Admins and supervisors can update assignments
CREATE POLICY "Admins and supervisors can update assignments"
  ON assignments
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'Admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM employees
      WHERE employees.user_id = auth.uid()
      AND employees.id = supervisor_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'Admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM employees
      WHERE employees.user_id = auth.uid()
      AND employees.id = supervisor_id
    )
  );

-- Only admins can delete assignments
CREATE POLICY "Admins can delete assignments"
  ON assignments
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'Admin'
    )
  );

-- Policies for assignment_members table

-- Anyone authenticated can view assignment members
CREATE POLICY "Authenticated users can view assignment members"
  ON assignment_members
  FOR SELECT
  TO authenticated
  USING (true);

-- Admins and supervisors can add assignment members
CREATE POLICY "Admins and supervisors can add assignment members"
  ON assignment_members
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'Admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM assignments a
      INNER JOIN employees e ON e.user_id = auth.uid()
      WHERE a.id = assignment_id
      AND a.supervisor_id = e.id
    )
  );

-- Admins and supervisors can update assignment members
CREATE POLICY "Admins and supervisors can update assignment members"
  ON assignment_members
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'Admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM assignments a
      INNER JOIN employees e ON e.user_id = auth.uid()
      WHERE a.id = assignment_id
      AND a.supervisor_id = e.id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'Admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM assignments a
      INNER JOIN employees e ON e.user_id = auth.uid()
      WHERE a.id = assignment_id
      AND a.supervisor_id = e.id
    )
  );

-- Admins and supervisors can delete assignment members
CREATE POLICY "Admins and supervisors can delete assignment members"
  ON assignment_members
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_roles.user_id = auth.uid()
      AND user_roles.role = 'Admin'
    )
    OR
    EXISTS (
      SELECT 1 FROM assignments a
      INNER JOIN employees e ON e.user_id = auth.uid()
      WHERE a.id = assignment_id
      AND a.supervisor_id = e.id
    )
  );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_assignments_status ON assignments(status);
CREATE INDEX IF NOT EXISTS idx_assignments_deadline ON assignments(deadline);
CREATE INDEX IF NOT EXISTS idx_assignments_supervisor_id ON assignments(supervisor_id);
CREATE INDEX IF NOT EXISTS idx_assignments_created_by ON assignments(created_by);
CREATE INDEX IF NOT EXISTS idx_assignment_members_assignment_id ON assignment_members(assignment_id);
CREATE INDEX IF NOT EXISTS idx_assignment_members_employee_id ON assignment_members(employee_id);

-- Create a view for easy querying of assignments with member details
CREATE OR REPLACE VIEW assignment_details AS
SELECT 
  a.id,
  a.title,
  a.project_note,
  a.start_date,
  a.deadline,
  a.status,
  a.supervisor_id,
  a.created_by,
  a.approved_by,
  a.approved_at,
  a.created_at,
  a.updated_at,
  CONCAT(supervisor.first_name, ' ', supervisor.last_name) as supervisor_name,
  json_agg(
    json_build_object(
      'member_id', am.id,
      'employee_id', am.employee_id,
      'employee_name', CONCAT(e.first_name, ' ', e.last_name),
      'employee_email', e.email,
      'role', am.role,
      'personal_note', am.personal_note
    )
  ) FILTER (WHERE am.id IS NOT NULL) as members
FROM assignments a
LEFT JOIN employees supervisor ON a.supervisor_id = supervisor.id
LEFT JOIN assignment_members am ON a.id = am.assignment_id
LEFT JOIN employees e ON am.employee_id = e.id
GROUP BY a.id, a.title, a.project_note, a.start_date, a.deadline, a.status, 
         a.supervisor_id, a.created_by, a.approved_by, a.approved_at, a.created_at, a.updated_at,
         supervisor.first_name, supervisor.last_name;

-- Grant access to the view
GRANT SELECT ON assignment_details TO authenticated;
