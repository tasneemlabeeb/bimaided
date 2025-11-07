# Database Setup Guide

## 📋 Overview

This guide provides step-by-step instructions for setting up the complete BIMSync Portal database schema in Supabase.

## 🗄️ Database Schema Summary

### Tables (14 Total)

| Table | Purpose | Records |
|-------|---------|---------|
| **departments** | Company departments | 7 seed records |
| **designations** | Job titles/positions | 18 seed records |
| **employees** | Employee master data | Empty |
| **user_roles** | Role assignments (admin/employee) | Empty |
| **emergency_contacts** | Emergency contact info | Empty |
| **documents** | Employee document storage | Empty |
| **salaries** | Salary information | Empty |
| **leave_balances** | Leave tracking | Empty |
| **attendance** | Daily attendance & leave requests | Empty |
| **project_assignments** | Employee project assignments | Empty |
| **projects** | Portfolio projects (public) | Empty |
| **career_postings** | Job postings (public) | Empty |
| **contact_inquiries** | Contact form submissions | Empty |
| **ip_whitelist** | Whitelisted IPs for check-in | Empty |

### Enums (7 Total)
- `user_role`: admin, employee
- `employment_status`: Active, On Leave, Resigned, Terminated
- `gender_type`: Male, Female, Other
- `attendance_status`: Present, Absent, Leave, Late
- `leave_type`: 10 different leave types
- `assignment_status`: Active, Completed
- `project_category`: 6 project categories

## 🚀 Setup Instructions

### Step 1: Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Click **"New Project"**
3. Fill in project details:
   - Name: `bimsync-portal` (or your choice)
   - Database Password: Choose a strong password (save it!)
   - Region: Choose closest to your location
4. Click **"Create new project"**
5. Wait for project to initialize (~2 minutes)

### Step 2: Run Database Migration

#### Option A: Using Supabase SQL Editor (Recommended)

1. In Supabase Dashboard, go to **SQL Editor** (left sidebar)
2. Click **"New Query"**
3. Copy the entire contents of `/supabase/migrations/00_complete_schema.sql`
4. Paste into the SQL editor
5. Click **"Run"** (or press Cmd/Ctrl + Enter)
6. Wait for execution to complete (~30 seconds)
7. You should see "Success. No rows returned" message

#### Option B: Using Supabase CLI

```bash
# Install Supabase CLI (if not already installed)
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF

# Run migrations
supabase db push
```

### Step 3: Verify Schema Installation

1. Go to **Table Editor** in Supabase Dashboard
2. You should see 14 tables in the sidebar
3. Click on **departments** - should have 7 rows
4. Click on **designations** - should have 18 rows
5. Other tables should be empty

### Step 4: Create Storage Buckets

1. Go to **Storage** in Supabase Dashboard
2. Click **"Create a new bucket"**
3. Create 4 buckets:

#### Bucket 1: employee-photos
- Name: `employee-photos`
- Public: **No** (Private)
- File size limit: 5MB
- Allowed MIME types: `image/*`

#### Bucket 2: employee-documents
- Name: `employee-documents`
- Public: **No** (Private)
- File size limit: 10MB
- Allowed MIME types: `image/*, application/pdf`

#### Bucket 3: project-images
- Name: `project-images`
- Public: **Yes** (Public)
- File size limit: 10MB
- Allowed MIME types: `image/*`

#### Bucket 4: leave-attachments
- Name: `leave-attachments`
- Public: **No** (Private)
- File size limit: 5MB
- Allowed MIME types: `image/*, application/pdf`

### Step 5: Set Storage Policies

For each private bucket, add RLS policies:

```sql
-- employee-photos policies
CREATE POLICY "Employees can view their own photos"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'employee-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Employees can upload their own photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'employee-photos' AND auth.uid()::text = (storage.foldername(name))[1]);

-- employee-documents policies
CREATE POLICY "Employees can view their own documents"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'employee-documents' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Admin can view all documents"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'employee-documents' AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- leave-attachments policies
CREATE POLICY "Users can view their own attachments"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'leave-attachments' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Admin can view all leave attachments"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'leave-attachments' AND
  EXISTS (SELECT 1 FROM user_roles WHERE user_id = auth.uid() AND role = 'admin')
);
```

### Step 6: Create First Admin User

#### Method 1: Using Supabase Auth UI

1. Go to **Authentication** → **Users** in Supabase Dashboard
2. Click **"Add user"**
3. Enter:
   - Email: `admin@yourdomain.com`
   - Password: Strong password
   - Confirm password
4. Click **"Create user"**
5. Copy the User ID (UUID)

#### Method 2: Via Application Signup

1. Run your app locally: `npm run dev`
2. Sign up normally through the login page
3. Get user ID from Supabase Dashboard → Authentication → Users

### Step 7: Assign Admin Role

Run this SQL in Supabase SQL Editor (replace `YOUR_USER_ID` with actual UUID):

```sql
-- Assign admin role
INSERT INTO user_roles (user_id, role)
VALUES ('YOUR_USER_ID', 'admin');

-- Create employee record for admin
INSERT INTO employees (
  first_name, 
  last_name, 
  email, 
  user_id, 
  joining_date,
  employment_status
)
VALUES (
  'Admin',
  'User',
  'admin@yourdomain.com',
  'YOUR_USER_ID',
  CURRENT_DATE,
  'Active'
);
```

### Step 8: Configure Environment Variables

1. In Supabase Dashboard, go to **Settings** → **API**
2. Copy these values:
   - Project URL
   - anon/public key

3. Update your `.env` file:

```env
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

### Step 9: Test the Setup

1. Start your development server:
   ```bash
   npm run dev
   ```

2. Navigate to `http://localhost:5173`

3. Login with your admin credentials

4. You should be able to access the Admin Dashboard

5. Test key features:
   - Add a new employee
   - Create a project
   - Post a job opening
   - View attendance records

## ✅ Verification Checklist

- [ ] All 14 tables created successfully
- [ ] Departments table has 7 seed records
- [ ] Designations table has 18 seed records
- [ ] All 7 enums created
- [ ] 4 storage buckets created
- [ ] Storage policies configured
- [ ] Admin user created and assigned role
- [ ] Employee record for admin created
- [ ] Environment variables configured
- [ ] Application connects to database
- [ ] Admin can login successfully

## 🔧 Troubleshooting

### Issue: "relation does not exist" error
**Solution**: Re-run the migration SQL. Make sure all tables are created.

### Issue: "permission denied for table"
**Solution**: Check RLS policies. Make sure user has admin role in user_roles table.

### Issue: Cannot upload files to storage
**Solution**: 
1. Verify bucket exists
2. Check storage policies
3. Ensure bucket name matches in code

### Issue: Auth user created but cannot login to app
**Solution**:
1. Check if user has role in user_roles table
2. Check if employee record exists with matching user_id
3. Verify RLS policies allow user to read their employee data

### Issue: "function has_role does not exist"
**Solution**: Re-run the complete schema SQL. The function should be created.

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Guide](https://supabase.com/docs/guides/storage)
- [SQL Editor Guide](https://supabase.com/docs/guides/database/overview)

## 🆘 Need Help?

If you encounter issues:

1. Check Supabase logs: Dashboard → Logs
2. Check browser console for errors
3. Verify all environment variables are correct
4. Ensure database migration completed successfully
5. Check RLS policies are properly configured

## 📝 Next Steps

After successful setup:

1. Generate TypeScript types (optional):
   ```bash
   npx supabase gen types typescript --project-id YOUR_PROJECT_ID > src/integrations/supabase/types.ts
   ```

2. Customize seed data:
   - Add your actual departments
   - Add your designations
   - Update company-specific enums

3. Import existing data (if migrating):
   - Use CSV import in Table Editor
   - Or write custom SQL scripts

4. Set up regular backups in Supabase Dashboard

5. Configure production environment variables for deployment

---

**Last Updated**: November 8, 2025  
**Schema Version**: 1.0  
**Compatible with**: Supabase PostgreSQL 15+
