# 📊 Database Migration Guide

This directory contains all the SQL migration scripts to set up the complete BIMSync Portal database schema.

## 📁 Migration Files

### Individual Migration Files (Execute in Order)

1. **`01_create_enums.sql`** - Custom ENUM types
   - user_role, gender_type, employment_status
   - attendance_status, leave_type
   - project_category, assignment_status

2. **`02_create_hr_tables.sql`** - Core HR tables
   - departments, designations, employees
   - user_roles, emergency_contacts
   - documents, salaries, leave_balances
   - attendance, project_assignments

3. **`03_create_public_tables.sql`** - Public-facing tables
   - projects (portfolio)
   - career_postings (job listings)

4. **`04_create_functions_triggers.sql`** - Database functions and triggers
   - Auto-update timestamps
   - Calculate work hours
   - Initialize leave balances
   - Role checking function

5. **`05_create_rls_policies.sql`** - Row Level Security policies
   - Employee data access controls
   - Admin permissions
   - Supervisor permissions
   - Public access for projects/careers

6. **`06_seed_data.sql`** - Initial seed data
   - 7 departments
   - 18 job designations
   - 5 sample projects
   - 3 sample job postings

### Complete Migration File

- **`complete_migration.sql`** - All migrations combined in one file
  - Use this for a fresh installation
  - Runs all migrations in correct order

## 🚀 How to Run Migrations

### Option 1: Using Supabase SQL Editor (Recommended)

1. Open your Supabase Dashboard
   ```
   http://supabasekong-i480ws8cosk4kwkskssck8o8.72.60.222.97.sslip.io
   ```

2. Navigate to **SQL Editor**

3. Copy and paste the content of `complete_migration.sql`

4. Click **Run** to execute

5. Wait for completion (should take 30-60 seconds)

6. Verify tables are created in the **Table Editor**

### Option 2: Using Node.js Script

1. Make sure you're in the database directory:
   ```bash
   cd database
   ```

2. Run the migration script:
   ```bash
   node run-migrations.js
   ```

3. The script will:
   - Read all migration files in order
   - Execute SQL statements
   - Show progress and results
   - Display summary

### Option 3: Using Supabase CLI

1. Install Supabase CLI if not already installed:
   ```bash
   npm install -g supabase
   ```

2. Link to your project:
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```

3. Run migrations:
   ```bash
   supabase db push
   ```

### Option 4: Manual Execution (Individual Files)

Execute files in order using psql or Supabase Dashboard:

```bash
# If using psql
psql -h supabase-db -U postgres -d postgres -f 01_create_enums.sql
psql -h supabase-db -U postgres -d postgres -f 02_create_hr_tables.sql
psql -h supabase-db -U postgres -d postgres -f 03_create_public_tables.sql
psql -h supabase-db -U postgres -d postgres -f 04_create_functions_triggers.sql
psql -h supabase-db -U postgres -d postgres -f 05_create_rls_policies.sql
psql -h supabase-db -U postgres -d postgres -f 06_seed_data.sql
```

## ✅ Verify Migration Success

After running migrations, check:

### 1. Tables Created (12 tables)
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;
```

Expected tables:
- attendance
- career_postings
- departments
- designations
- documents
- emergency_contacts
- employees
- leave_balances
- project_assignments
- projects
- salaries
- user_roles

### 2. ENUMs Created (7 types)
```sql
SELECT typname 
FROM pg_type 
WHERE typtype = 'e' 
ORDER BY typname;
```

### 3. Seed Data Inserted
```sql
-- Check departments
SELECT COUNT(*) FROM departments; -- Should be 7

-- Check designations
SELECT COUNT(*) FROM designations; -- Should be 18

-- Check projects
SELECT COUNT(*) FROM projects; -- Should be 5

-- Check career postings
SELECT COUNT(*) FROM career_postings; -- Should be 3
```

### 4. RLS Enabled
```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public';
```

All tables should have `rowsecurity = true`

## 🔧 Troubleshooting

### Error: "type already exists"
If you see this error, the ENUMs are already created. You can either:
- Drop them first: `DROP TYPE IF EXISTS type_name CASCADE;`
- Skip the enums file and continue with other migrations

### Error: "relation already exists"
Tables already exist. Options:
- Drop specific table: `DROP TABLE IF EXISTS table_name CASCADE;`
- Drop all and start fresh (⚠️ destroys data):
  ```sql
  DROP SCHEMA public CASCADE;
  CREATE SCHEMA public;
  ```

### Error: "permission denied"
Make sure you're using the Service Role Key, not the Anon Key.

### Error: "function does not exist"
Some functions may require special PostgreSQL extensions. Ensure:
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

## 📝 Database Schema Overview

### Core Entities

**Employees**
- Basic info, contact details
- Links to departments & designations
- Supervisor hierarchy
- Integration with Supabase auth

**Attendance & Leave**
- Daily attendance tracking
- Multiple leave types
- Two-level approval (supervisor + admin)
- Automatic leave balance tracking

**Projects & Assignments**
- Project portfolio for website
- Employee project assignments
- Role tracking

**Public Data**
- Projects (visible on website)
- Career postings (job listings)

### Security

- **Row Level Security (RLS)** enabled on all tables
- **Role-based access control** (admin/employee)
- **Hierarchical permissions** (employees → supervisors → admins)
- **Public access** for marketing data (projects, jobs)

## 🔐 Initial Admin Setup

After migration, create your first admin user:

```sql
-- 1. Create employee record
INSERT INTO employees (
  first_name, last_name, email, 
  joining_date, employment_status
) VALUES (
  'Admin', 'User', 'admin@bimaided.com',
  CURRENT_DATE, 'Active'
);

-- 2. Get the employee ID (copy this)
SELECT id FROM employees WHERE email = 'admin@bimaided.com';

-- 3. Sign up in your app with that email
-- Then update the employee record with the auth user_id

-- 4. Assign admin role
INSERT INTO user_roles (user_id, role) VALUES (
  'YOUR_AUTH_USER_ID_HERE', 'admin'
);
```

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

## 🆘 Need Help?

If you encounter issues:

1. Check Supabase Dashboard logs
2. Verify environment variables are set correctly
3. Ensure using Service Role Key (not Anon Key)
4. Check PostgreSQL version compatibility
5. Review error messages carefully

---

**Last Updated**: November 6, 2025
**Database Version**: 1.0.0
**PostgreSQL Version**: 13+
