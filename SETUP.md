# BIMaided Setup Guide

## Initial Setup

Your BIMaided website and employee management system is ready! Follow these steps to get started:

### 1. Create the First Admin User

To create your first admin account, run this SQL query in your Supabase SQL Editor:

```sql
-- Replace with your actual email and secure password
INSERT INTO auth.users (email, encrypted_password, email_confirmed_at, raw_user_meta_data)
VALUES (
  'admin@bimaided.com',
  crypt('YourSecurePassword123!', gen_salt('bf')),
  now(),
  '{"role": "admin"}'::jsonb
);

-- Get the user_id from the auth.users table
-- Replace USER_ID_HERE with the actual UUID from the query above
INSERT INTO user_roles (user_id, role)
VALUES ('USER_ID_HERE', 'Admin');
```

Or create your admin user through the Supabase dashboard:
1. Go to Authentication → Users
2. Create a new user
3. Copy their user_id
4. Run: `INSERT INTO user_roles (user_id, role) VALUES ('USER_ID_HERE', 'Admin');`

### 2. Add Departments and Designations

Before adding employees, set up your organizational structure:

```sql
-- Add Departments
INSERT INTO departments (name, description) VALUES 
  ('Architecture', 'Architectural design and BIM modeling'),
  ('Engineering', 'Structural and MEP engineering'),
  ('VDC', 'Virtual Design and Construction'),
  ('Human Resources', 'HR and administration'),
  ('Management', 'Project and business management');

-- Add Designations (get department_id from departments table)
INSERT INTO designations (name, level, department_id) VALUES 
  ('BIM Manager', 'Senior', 'DEPT_ID_HERE'),
  ('Senior Architect', 'Senior', 'DEPT_ID_HERE'),
  ('BIM Modeler', 'Mid', 'DEPT_ID_HERE'),
  ('Revit Technician', 'Junior', 'DEPT_ID_HERE');
```

### 3. Access the System

**Public Website:** Visit your homepage to see the beautiful BIMaided corporate website

**Admin Portal:** 
- Navigate to `/login`
- Sign in with your admin credentials
- Access admin dashboard to:
  - Add new employees
  - Manage leave requests
  - View employee data

**Employee Portal:**
- Employees receive their login credentials from admin
- Navigate to `/login`
- Access employee dashboard to:
  - View profile
  - Request leave
  - Check attendance history

## Features

### Public Website
- Landing page with hero section and company overview
- Services page (BIM Modeling, Advanced BIM, VDC, Global BIM)
- Projects portfolio with category filtering
- About Us page
- Career opportunities page
- Blog section

### Employee Management System
- **Leave Management** (Core Feature)
  - Annual Leave: 20 days
  - Sick Leave: 10 days
  - Casual Leave: 10 days
  - Multiple leave types supported
  - Approval workflow
  
- **Admin Capabilities**
  - Add/manage employees
  - Approve/reject leave requests
  - View all employee data
  - Manage departments and designations
  
- **Employee Self-Service**
  - View personal profile
  - Submit leave requests
  - View attendance history
  - Check leave balances

## Security Notes

- RLS (Row Level Security) is enabled on all tables
- Admin role is stored separately for security
- Employees can only view/edit their own data
- Admin has full access to all employee data

## Database Schema

The system includes these main tables:
- `employees` - Employee information
- `departments` - Organizational departments
- `designations` - Job roles and positions
- `user_roles` - Role assignments (Admin/Employee)
- `salaries` - Compensation records
- `attendance` - Attendance and leave records
- `leave_balances` - Annual leave tracking
- `documents` - Employee documents
- `project_assignments` - Project allocations
- `emergency_contacts` - Emergency contact information

## Support

For issues or questions, refer to the Supabase dashboard for:
- Database management
- User authentication
- Logs and monitoring
