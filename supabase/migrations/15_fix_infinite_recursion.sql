-- =====================================================
-- Fix Infinite Recursion in RLS Policies
-- =====================================================
-- Issue: Multiple policies query employees table, causing infinite recursion
-- Solution: Use security definer function to break the recursion chain

-- Create a security definer function to get employee ID from user ID
-- This function runs with the privileges of the function owner, breaking the RLS recursion
CREATE OR REPLACE FUNCTION get_employee_id_by_user(user_uuid UUID)
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT id FROM employees WHERE user_id = user_uuid LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION get_employee_id_by_user(UUID) TO authenticated;

COMMENT ON FUNCTION get_employee_id_by_user IS 'Security definer function to get employee ID from user ID without triggering RLS recursion';

-- =====================================================
-- Fix Employees Table Policies
-- =====================================================

DROP POLICY IF EXISTS "Supervisors can view their team" ON employees;

CREATE POLICY "Supervisors can view their team"
  ON employees FOR SELECT
  TO authenticated
  USING (
    supervisor_id = get_employee_id_by_user(auth.uid())
  );

-- =====================================================
-- Fix Emergency Contacts Policies
-- =====================================================

DROP POLICY IF EXISTS "Employees can view their own emergency contacts" ON emergency_contacts;

CREATE POLICY "Employees can view their own emergency contacts"
  ON emergency_contacts FOR SELECT
  TO authenticated
  USING (
    employee_id = get_employee_id_by_user(auth.uid())
  );

-- =====================================================
-- Fix Documents Policies
-- =====================================================

DROP POLICY IF EXISTS "Employees can view their own documents" ON documents;

CREATE POLICY "Employees can view their own documents"
  ON documents FOR SELECT
  TO authenticated
  USING (
    employee_id = get_employee_id_by_user(auth.uid())
  );

-- =====================================================
-- Fix Salaries Policies
-- =====================================================

DROP POLICY IF EXISTS "Employees can view their own salary" ON salaries;

CREATE POLICY "Employees can view their own salary"
  ON salaries FOR SELECT
  TO authenticated
  USING (
    employee_id = get_employee_id_by_user(auth.uid())
  );

-- =====================================================
-- Fix Leave Balances Policies
-- =====================================================

DROP POLICY IF EXISTS "Employees can view their own leave balance" ON leave_balances;

CREATE POLICY "Employees can view their own leave balance"
  ON leave_balances FOR SELECT
  TO authenticated
  USING (
    employee_id = get_employee_id_by_user(auth.uid())
  );

-- =====================================================
-- Fix Attendance Policies
-- =====================================================

DROP POLICY IF EXISTS "Employees can view their own attendance" ON attendance;
DROP POLICY IF EXISTS "Supervisors can view team attendance" ON attendance;
DROP POLICY IF EXISTS "Employees can insert their own attendance" ON attendance;

CREATE POLICY "Employees can view their own attendance"
  ON attendance FOR SELECT
  TO authenticated
  USING (
    employee_id = get_employee_id_by_user(auth.uid())
  );

CREATE POLICY "Supervisors can view team attendance"
  ON attendance FOR SELECT
  TO authenticated
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE supervisor_id = get_employee_id_by_user(auth.uid())
    )
  );

CREATE POLICY "Employees can insert their own attendance"
  ON attendance FOR INSERT
  TO authenticated
  WITH CHECK (
    employee_id = get_employee_id_by_user(auth.uid())
  );

-- =====================================================
-- Fix Project Assignments Policies
-- =====================================================

DROP POLICY IF EXISTS "Employees can view their own assignments" ON project_assignments;
DROP POLICY IF EXISTS "Supervisors can view team assignments" ON project_assignments;

CREATE POLICY "Employees can view their own assignments"
  ON project_assignments FOR SELECT
  TO authenticated
  USING (
    employee_id = get_employee_id_by_user(auth.uid())
  );

CREATE POLICY "Supervisors can view team assignments"
  ON project_assignments FOR SELECT
  TO authenticated
  USING (
    employee_id IN (
      SELECT id FROM employees WHERE supervisor_id = get_employee_id_by_user(auth.uid())
    )
  );
