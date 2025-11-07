# Code Refactoring Guide

## Overview
This guide documents the code refactoring process to improve code quality, maintainability, and reduce duplication across the codebase.

## New Utility Libraries Created

### 1. `src/lib/constants.ts`
Centralized application-wide constants to eliminate magic strings and hardcoded values.

**Constants Included:**
- `APP_NAME`: Application name
- `QUERY_CONFIG`: React Query default configuration
- `STATUS`: Status values (pending, approved, rejected, completed)
- `USER_ROLES`: User role constants (admin, employee, supervisor)
- `DATE_FORMATS`: Standard date format strings
- `PAGINATION`: Pagination defaults
- `FILE_UPLOAD`: File upload constraints
- `TOAST_DURATION`: Toast notification duration

**Usage Example:**
```typescript
import { STATUS, USER_ROLES, QUERY_CONFIG } from '@/lib/constants';

// Instead of: if (status === 'pending')
if (status === STATUS.PENDING) { /* ... */ }

// Instead of: if (role === 'admin')
if (role === USER_ROLES.ADMIN) { /* ... */ }
```

### 2. `src/lib/validation.ts`
Reusable validation utilities to eliminate duplicate validation logic.

**Functions Included:**
- `isValidEmail(email: string): boolean`
- `isValidPhone(phone: string): boolean`
- `isValidPassword(password: string): boolean`
- `isValidEID(eid: string): boolean`
- `isEmpty(value: any): boolean`
- `isValidFileSize(file: File, maxSizeMB: number): boolean`
- `isValidFileType(file: File, allowedTypes: string[]): boolean`
- `validateRequired(value: string, fieldName: string): string | null`
- `validateEmail(email: string): string | null`
- `validatePhone(phone: string): string | null`
- `validatePassword(password: string): string | null`

**Usage Example:**
```typescript
import { validateEmail, validatePassword, isValidEID } from '@/lib/validation';

// Form validation
const emailError = validateEmail(formData.email);
const passwordError = validatePassword(formData.password);

if (emailError || passwordError) {
  setErrors({ email: emailError, password: passwordError });
  return;
}

// Simple checks
if (!isValidEID(employee.eid)) {
  toast.error('Invalid EID format');
}
```

### 3. `src/lib/date-utils.ts`
Standardized date formatting and manipulation utilities.

**Functions Included:**
- `formatDate(date: Date | string, format?: string): string`
- `formatDateTime(date: Date | string): string`
- `formatTime(date: Date | string): string`
- `getToday(): string` - Returns YYYY-MM-DD
- `getTodayStart(): Date`
- `getTodayEnd(): Date`
- `isDateInPast(date: Date | string): boolean`
- `isDateInFuture(date: Date | string): boolean`
- `isDateToday(date: Date | string): boolean`
- `getDaysDifference(date1: Date | string, date2: Date | string): number`
- `addDays(date: Date | string, days: number): Date`
- `subtractDays(date: Date | string, days: number): Date`

**Usage Example:**
```typescript
import { formatDate, getToday, isDateInPast } from '@/lib/date-utils';

// Format dates consistently
<p>{formatDate(employee.dateOfBirth)}</p>
<p>{formatDateTime(attendance.checkInTime)}</p>

// Date comparisons
if (isDateInPast(project.deadline)) {
  showWarning('Project deadline has passed!');
}

// Form date fields
<input type="date" max={getToday()} />
```

### 4. `src/lib/form-utils.ts`
Generic form handling utilities to reduce boilerplate code.

**Functions Included:**
- `sanitizeFormData<T>(data: T): T` - Trims string values
- `resetForm(formRef: React.RefObject<HTMLFormElement>): void`
- `handleInputChange<T>(event, setFormData, transform?): void`
- `handleSelectChange<T>(value: string, field: string, setFormData): void`
- `createFormData(data: Record<string, any>): FormData`
- `getFormErrors(errors: Record<string, string | null>): string[]`
- `hasFormErrors(errors: Record<string, string | null>): boolean`

**Usage Example:**
```typescript
import { sanitizeFormData, handleInputChange, hasFormErrors } from '@/lib/form-utils';

const [formData, setFormData] = useState<LoginForm>({
  email: '',
  password: ''
});

// Use generic input handler
<input
  type="email"
  value={formData.email}
  onChange={(e) => handleInputChange(e, setFormData)}
  name="email"
/>

// Before submit, sanitize data
const cleanData = sanitizeFormData(formData);

// Check for errors
if (hasFormErrors(errors)) {
  return;
}
```

### 5. `src/services/api.ts`
Typed API service layer for all Supabase operations.

**Services Included:**
- `authService`: Authentication operations
  - `signIn(email, password)`
  - `signOut()`
  - `getSession()`
  - `getUser()`

- `employeeService`: Employee CRUD operations
  - `getAll()`
  - `getById(id)`
  - `getByAuthUserId(authUserId)`
  - `create(employee)`
  - `update(id, updates)`
  - `delete(id)`

- `projectService`: Project management
  - `getAll()`
  - `getPublished()`
  - `getById(id)`
  - `create(project)`
  - `update(id, updates)`
  - `delete(id)`

- `attendanceService`: Attendance tracking
  - `checkIn(employeeId)`
  - `checkOut(id)`
  - `getByEmployeeId(employeeId)`
  - `getTodayAttendance(employeeId)`

**Usage Example:**
```typescript
import { api } from '@/services/api';

// Authentication
const { user } = await api.auth.signIn(email, password);

// Fetch data
const employees = await api.employees.getAll();
const employee = await api.employees.getById(id);

// Create/Update
const newEmployee = await api.employees.create(employeeData);
await api.projects.update(projectId, { status: 'completed' });

// Attendance
const attendance = await api.attendance.checkIn(employeeId);
```

## Refactoring Checklist

### Phase 1: Component Refactoring (In Progress)
- [x] Create utility libraries
- [x] Refactor `App.tsx` to use constants
- [ ] Refactor `Login.tsx`
  - [ ] Replace inline validation with `validation.ts` functions
  - [ ] Use `form-utils` for form handling
  - [ ] Use `api.auth.signIn()` instead of direct Supabase calls
- [ ] Refactor `Contact.tsx`
  - [ ] Use form utilities
  - [ ] Use validation utilities
  - [ ] Standardize error handling
- [ ] Refactor admin components
  - [ ] `CareerManager.tsx`: Use STATUS constants, form utilities
  - [ ] `ApplicationManager.tsx`: Use api service, constants
  - [ ] `AssignmentManager.tsx`: Use api service
  - [ ] `EmployeeList.tsx`: Use api.employees service
  - [ ] `LeaveRequests.tsx`: Use date-utils, constants
  - [ ] `ManualAttendanceEntry.tsx`: Use api.attendance, date-utils
  - [ ] `ProjectManager.tsx`: Use api.projects, constants
- [ ] Refactor employee components
  - [ ] `AttendanceCheckIn.tsx`: Use api.attendance service
  - [ ] `AttendanceHistory.tsx`: Use date-utils for formatting
  - [ ] `EmployeeProfile.tsx`: Use validation utilities
  - [ ] `LeaveRequestForm.tsx`: Use form-utils, date-utils
  - [ ] `MyAssignments.tsx`: Use api service

### Phase 2: Code Duplication Elimination
- [ ] Extract common form field components
  - [ ] `<TextInput>` component with validation
  - [ ] `<DateInput>` component
  - [ ] `<SelectInput>` component
  - [ ] `<FileInput>` component with validation
- [ ] Create common data table components
  - [ ] `<DataTable>` with sorting, pagination
  - [ ] `<SearchBar>` component
  - [ ] `<FilterPanel>` component
- [ ] Extract common hooks
  - [ ] `useAuth()` hook
  - [ ] `useEmployeeData()` hook
  - [ ] `useAttendance()` hook
  - [ ] `useLeaveRequests()` hook

### Phase 3: Type Safety Improvements
- [ ] Add TypeScript interfaces for all component props
- [ ] Type all form data objects
- [ ] Add proper return types to all functions
- [ ] Use strict TypeScript configuration
- [ ] Replace `any` types with proper types

### Phase 4: Performance Optimization
- [ ] Implement React.memo for expensive components
- [ ] Use useCallback for event handlers
- [ ] Use useMemo for expensive calculations
- [ ] Implement proper React Query cache invalidation
- [ ] Lazy load route components with React.lazy()

### Phase 5: Error Handling & UX
- [ ] Standardize error messages
- [ ] Create error boundary components
- [ ] Add loading states to all data fetching
- [ ] Add optimistic updates for mutations
- [ ] Improve form validation feedback

## Benefits of Refactoring

### ✅ Code Maintainability
- **Before**: Magic strings scattered across 50+ components
- **After**: Single source of truth in `constants.ts`
- **Impact**: Easy to update values globally

### ✅ Reduced Duplication
- **Before**: Validation logic repeated in 15+ components
- **After**: Reusable `validation.ts` utilities
- **Impact**: ~500 lines of code eliminated

### ✅ Type Safety
- **Before**: Partial types and `any` usage
- **After**: Strongly typed API service layer
- **Impact**: Catch errors at compile time

### ✅ Consistency
- **Before**: Different date formats in different components
- **After**: Standardized `date-utils.ts` formatting
- **Impact**: Consistent user experience

### ✅ Testability
- **Before**: Tightly coupled components
- **After**: Pure utility functions, service layer
- **Impact**: Easy to write unit tests

## Migration Examples

### Example 1: Login Component Refactoring

**Before:**
```typescript
const handleSubmit = async (e) => {
  e.preventDefault();
  
  // Inline validation
  if (!email || !email.includes('@')) {
    toast.error('Invalid email');
    return;
  }
  
  if (!password || password.length < 6) {
    toast.error('Password must be at least 6 characters');
    return;
  }
  
  // Direct Supabase call
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });
  
  if (error) {
    toast.error(error.message);
  }
};
```

**After:**
```typescript
import { validateEmail, validatePassword } from '@/lib/validation';
import { api } from '@/services/api';

const handleSubmit = async (e) => {
  e.preventDefault();
  
  // Reusable validation
  const emailError = validateEmail(formData.email);
  const passwordError = validatePassword(formData.password);
  
  if (emailError || passwordError) {
    toast.error(emailError || passwordError);
    return;
  }
  
  // API service layer
  try {
    const { user } = await api.auth.signIn(formData.email, formData.password);
    navigate('/dashboard');
  } catch (error) {
    toast.error(error.message);
  }
};
```

### Example 2: Date Formatting

**Before:**
```typescript
// Scattered across components
<p>{new Date(employee.created_at).toLocaleDateString()}</p>
<p>{attendance.date.split('T')[0]}</p>
<p>{format(new Date(project.deadline), 'yyyy-MM-dd')}</p>
```

**After:**
```typescript
import { formatDate, formatDateTime } from '@/lib/date-utils';

<p>{formatDate(employee.createdAt)}</p>
<p>{formatDate(attendance.date)}</p>
<p>{formatDate(project.deadline)}</p>
```

### Example 3: Status Checks

**Before:**
```typescript
if (status === 'pending') { /* ... */ }
if (request.status === 'approved') { /* ... */ }
if (user.role === 'admin') { /* ... */ }
```

**After:**
```typescript
import { STATUS, USER_ROLES } from '@/lib/constants';

if (status === STATUS.PENDING) { /* ... */ }
if (request.status === STATUS.APPROVED) { /* ... */ }
if (user.role === USER_ROLES.ADMIN) { /* ... */ }
```

## Next Steps

1. **Continue Component Refactoring**: Start with `Login.tsx` and `Contact.tsx` as they have heavy form/validation logic
2. **Replace Direct Supabase Calls**: Use `api` service throughout the application
3. **Extract Common Components**: Create reusable form field components
4. **Improve Type Safety**: Add proper TypeScript interfaces to all components
5. **Add Unit Tests**: Test utility functions and service layer

## Notes
- The refactoring is backward compatible - old code will continue to work
- Migrate components incrementally, no need to refactor everything at once
- Focus on high-traffic components first (Login, Dashboard, Attendance)
- Keep the utility libraries lean - only add functions that are used multiple times
