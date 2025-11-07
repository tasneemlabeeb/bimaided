# Employee Account Creation Fix

## Problem
The application was trying to call `create_employee_account` database function that didn't exist, causing the error:
> "Could not find the function public.create_employee_account(...) in the schema cache"

## Solution
Created a server-side API endpoint that uses Supabase Admin API to create employee accounts securely.

## Changes Made

### 1. Backend Server (`server/index.js`)
✅ Added `@supabase/supabase-js` dependency
✅ Created Supabase Admin Client with service role key
✅ Added `/api/create-employee` POST endpoint
✅ Implemented proper error handling and rollback

**New Endpoint**: `POST http://localhost:3001/api/create-employee`

**Request Body**:
```json
{
  "email": "employee@example.com",
  "password": "securePassword123",
  "firstName": "John",
  "lastName": "Doe",
  "gender": "Male",
  "dateOfBirth": "1990-01-15",
  "nationalId": "123456789",
  "phoneNumber": "+1234567890",
  "address": "123 Main St",
  "joiningDate": "2024-01-01",
  "departmentId": "uuid-here",
  "designationId": "uuid-here",
  "supervisorId": "uuid-here"
}
```

**Response (Success)**:
```json
{
  "success": true,
  "user_id": "uuid-here",
  "employee_id": "uuid-here",
  "message": "Employee account created successfully"
}
```

**Response (Error)**:
```json
{
  "error": "Error type",
  "message": "Detailed error message"
}
```

### 2. Frontend Component (`src/components/admin/AddEmployeeForm.tsx`)
✅ Changed from `supabase.rpc()` to API fetch call
✅ Updated to use REST endpoint instead of database function
✅ Maintains the same UI and validation logic

### 3. Database Functions (Created but Optional)
✅ `database/09_create_employee_account_function.sql` - Direct database function (requires auth.users access)
✅ `database/10_alternative_employee_function.sql` - Simplified version for employee records only
✅ Updated `database/complete_migration.sql` with the function

## How It Works

### Step 1: Create Auth User
The server uses Supabase Admin API to create an authenticated user:
```javascript
const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
  email: email,
  password: password,
  email_confirm: true, // Auto-confirm email
  user_metadata: {
    first_name: firstName,
    last_name: lastName
  }
});
```

### Step 2: Create Employee Record
Insert the employee data into the `employees` table:
```javascript
const { data: employeeData, error: employeeError } = await supabaseAdmin
  .from('employees')
  .insert({
    user_id: authData.user.id,
    first_name: firstName,
    last_name: lastName,
    email: email,
    // ... other fields
    employment_status: 'Active'
  })
  .select()
  .single();
```

### Step 3: Create User Role
Assign the employee role:
```javascript
await supabaseAdmin
  .from('user_roles')
  .insert({
    user_id: authData.user.id,
    role: 'employee'
  });
```

### Step 4: Error Handling & Rollback
If employee creation fails, the auth user is automatically deleted:
```javascript
if (employeeError) {
  // Rollback: Delete the auth user
  await supabaseAdmin.auth.admin.deleteUser(authData.user.id);
  return res.status(400).json({ error: 'Failed to create employee record' });
}
```

## Migration Options

### Option A: Use API Endpoint (Recommended ✅)
The server is already configured and running. Just use the application normally.

**Benefits**:
- ✅ More secure (uses service role key server-side)
- ✅ Better error handling and rollback
- ✅ No direct database function needed
- ✅ Works out of the box

### Option B: Run Database Function
If you prefer database-side logic, run the migration:

```bash
# Execute in Supabase SQL Editor
# Copy contents of database/09_create_employee_account_function.sql
```

Then update `AddEmployeeForm.tsx` to use `supabase.rpc('create_employee_account', ...)` instead of fetch.

## Testing

### 1. Start the Server
```bash
cd /Users/tasneemzaman/Desktop/Untitled
node server/index.js
```

Should see:
```
Environment check:
- VITE_SUPABASE_URL: ✓ Loaded
- SUPABASE_SERVICE_KEY: ✓ Loaded
✅ Supabase Admin Client initialized
🚀 BIMaided API Server running on port 3001
```

### 2. Test Adding Employee
1. Go to Admin Dashboard → Employee Management
2. Click "Add Employee"
3. Fill in all required fields:
   - First Name & Last Name (required)
   - Email (required, must be unique)
   - Password (required)
   - Department & Designation (recommended)
4. Click "Add Employee"
5. Should see success toast and employee appears in list

### 3. Verify in Supabase
Check three tables:
1. **auth.users** - Should have new user with confirmed email
2. **employees** - Should have new employee record
3. **user_roles** - Should have role='employee' for the user

## Troubleshooting

### Error: "supabaseUrl is required"
**Cause**: Environment variables not loaded
**Fix**: 
```bash
# Check .env file exists
ls -la /Users/tasneemzaman/Desktop/Untitled/.env

# Verify VITE_SUPABASE_URL and SUPABASE_SERVICE_KEY are set
cat /Users/tasneemzaman/Desktop/Untitled/.env | grep SUPABASE
```

### Error: "User already registered"
**Cause**: Email already exists in auth.users
**Fix**: Use a different email or delete the existing user from Supabase Dashboard

### Error: "Failed to create employee record"
**Cause**: Database constraint violation (foreign key, unique constraint, etc.)
**Fix**: 
- Ensure department_id and designation_id exist in respective tables
- Check if email is unique
- Verify supervisor_id is valid employee UUID

### Error: "Network request failed"
**Cause**: Backend server not running
**Fix**:
```bash
# Start the server
cd /Users/tasneemzaman/Desktop/Untitled
node server/index.js
```

## Security Notes

### Service Role Key
- ✅ Used only server-side (never exposed to frontend)
- ✅ Stored in `.env` file (not committed to git)
- ✅ Has admin privileges to create users

### Password Handling
- ✅ Sent over HTTPS in production
- ✅ Hashed by Supabase Auth automatically
- ✅ Never stored in plain text

### Email Confirmation
- ✅ Auto-confirmed for admin-created accounts
- ✅ Employees can login immediately
- ✅ No email verification required

## Next Steps

1. **Test the feature**: Add a test employee to verify everything works
2. **Update existing employees**: If you have employees without auth accounts, you'll need to create them manually
3. **Monitor logs**: Check server logs for any issues during employee creation

## Files Reference

| File | Purpose | Status |
|------|---------|--------|
| `server/index.js` | Backend API with employee creation endpoint | ✅ Updated |
| `server/package.json` | Added @supabase/supabase-js dependency | ✅ Updated |
| `src/components/admin/AddEmployeeForm.tsx` | Frontend form using API endpoint | ✅ Updated |
| `database/09_create_employee_account_function.sql` | Database function (optional) | ✅ Created |
| `database/10_alternative_employee_function.sql` | Simplified function (optional) | ✅ Created |
| `database/complete_migration.sql` | Includes employee function | ✅ Updated |

---
**Last Updated**: Just now  
**Server Status**: ✅ Running on port 3001  
**Feature Status**: ✅ Ready to use
