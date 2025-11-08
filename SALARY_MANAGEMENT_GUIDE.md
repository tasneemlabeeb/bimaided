# Salary Management System - Implementation Guide

## Overview
A comprehensive automated salary disbursement system based on attendance, leave management, and company policies.

## Features Implemented

### 1. Database Schema Enhancement
**File**: `/database/salary-management-schema.sql`

#### New Tables:
- **leave_balance_history**: Tracks yearly leave balances and usage
- **salary_configuration**: System-wide salary calculation rules
- **monthly_payroll**: Monthly salary records for each employee
- **salary_deductions**: Detailed breakdown of deductions
- **salary_slips**: Generated salary slip records

#### Enhanced Tables:
- **employees**: Added salary and bank details
  - `basic_salary`: Monthly basic salary
  - `bank_name`, `bank_account_number`, `bank_branch`: Banking details
  - `casual_leave_balance`, `sick_leave_balance`: Current leave balances

- **attendance**: Added hourly tracking
  - `working_hours`: Total hours worked
  - `late_minutes`: Minutes late
  - `is_late`: Boolean flag for late arrival
  - `leave_hours`: Hours of leave taken

### 2. Salary Calculation Logic

#### Leave Entitlement:
- **20 days/year total** (10 casual + 10 sick)
- Auto-converts excess leave to unpaid
- Hourly leave tracking (8 hours = 1 day)
- Half-day leave (4 hours = 0.5 day)

#### Deduction Rules:
- **Unpaid Leave**: `Daily Rate × Unpaid Days`
- **Late Penalty**: Every 3 late arrivals = 1 day salary deduction
- **Hourly Leave**: Converted to fractional days
- **Daily Rate**: `Basic Salary ÷ 30 (working days)`

#### Formula:
```
Net Salary = Basic Salary - Total Deductions

Where:
Total Deductions = (Unpaid Leave Days + Late Penalty Days + Hourly Leave Days) × Daily Rate
```

### 3. API Endpoints

#### Generate Payroll
**Endpoint**: `POST /api/payroll/generate`
**Body**:
```json
{
  "month": 11,
  "year": 2025,
  "employeeIds": ["optional-array-of-employee-ids"]
}
```
**Response**:
```json
{
  "success": true,
  "message": "Payroll generated for X employees",
  "data": [
    {
      "employee_id": "uuid",
      "employee_name": "John Doe",
      "basic_salary": 60000,
      "total_deduction": 8000,
      "net_payable_salary": 52000,
      "payroll_id": "uuid"
    }
  ]
}
```

#### Approve/Reject Payroll
**Endpoint**: `POST /api/payroll/approve`
**Body**:
```json
{
  "payrollIds": ["uuid1", "uuid2"],
  "action": "approve",  // or "reject"
  "approvedBy": "approver-employee-id",
  "remarks": "Optional remarks"
}
```

### 4. Admin Interface

**Component**: `/components/admin/PayrollManager.tsx`

#### Features:
- ✅ Month/Year selection for payroll period
- ✅ One-click payroll generation
- ✅ Bulk approve/reject with checkboxes
- ✅ Export to Excel/CSV
- ✅ Detailed payroll breakdown table
- ✅ Real-time calculations display
- ✅ Status tracking (Pending/Approved/Paid/Rejected)

#### Table Columns:
- Employee details (Name, EID, Designation)
- Basic Salary
- Attendance metrics (Present, Absent, Late days)
- Leave details (Casual, Sick, Unpaid)
- Deductions breakdown
- Net payable salary
- Status and actions

### 5. Configuration Management

**Table**: `salary_configuration`

Configurable parameters:
- `annual_casual_leave`: 10 days
- `annual_sick_leave`: 10 days
- `late_tolerance_count`: 3 (before penalty)
- `working_days_per_month`: 30
- `half_day_hours`: 4
- `full_day_hours`: 8

## Deployment Steps

### 1. Run Database Migration
```sql
-- In Supabase SQL Editor
-- Run: /database/salary-management-schema.sql
```

### 2. Add PayrollManager to Admin Panel
```tsx
// In /app/admin/page.tsx
import PayrollManager from "@/components/admin/PayrollManager";

// Add to tabs:
<TabsContent value="payroll">
  <PayrollManager />
</TabsContent>
```

### 3. Update Navigation
Add "Payroll" tab to admin navigation with the other tabs.

## Usage Workflow

### Monthly Payroll Process:

1. **Generate Payroll**
   - Select month and year
   - Click "Generate Payroll"
   - System fetches all attendance and leave records
   - Auto-calculates salaries based on rules

2. **Review Payroll**
   - View calculated salaries in table
   - Check deduction breakdowns
   - Verify attendance and leave data

3. **Approve Payroll**
   - Select payroll records using checkboxes
   - Click "Approve Selected" or "Reject Selected"
   - Approved payrolls generate salary slips automatically

4. **Export Reports**
   - Click "Export Excel" to download payroll sheet
   - Share with finance/HR teams
   - Use for bank transfer processing

5. **Mark as Paid**
   - After salary disbursement, update status to "Paid"
   - Maintain audit trail

## Example Calculation

```
Employee: John Doe
Basic Salary: 60,000 BDT
Month: November 2025
Working Days: 30

Attendance:
- Present: 22 days
- Absent: 2 days (unpaid leave)
- Late: 6 times (= 2 days penalty)
- Hourly Leave: 4 hours (= 0.5 days)

Calculation:
Daily Rate = 60,000 ÷ 30 = 2,000 BDT
Total Deduction Days = 2 (unpaid) + 2 (late penalty) + 0.5 (hourly) = 4.5 days
Total Deduction Amount = 4.5 × 2,000 = 9,000 BDT
Net Payable Salary = 60,000 - 9,000 = 51,000 BDT
```

## Additional Features to Implement

### Future Enhancements:
1. **Salary Slip PDF Generation**
   - Auto-generate PDF salary slips
   - Email to employees

2. **Bank Integration**
   - Direct salary transfer API
   - Bulk upload for bank portal

3. **Tax Calculation**
   - Auto-calculate income tax
   - Generate tax statements

4. **Bonus & Incentives**
   - Performance-based bonuses
   - Festival bonuses
   - Overtime calculations

5. **Employee Self-Service**
   - View own salary slips
   - Download payslips
   - View leave balance and salary impact

6. **Advanced Reporting**
   - Department-wise salary analysis
   - Year-over-year comparison
   - Cost center allocation

## Testing Checklist

- [ ] Run salary management schema migration
- [ ] Test payroll generation for single employee
- [ ] Test payroll generation for all employees
- [ ] Verify leave deductions calculation
- [ ] Verify late penalty calculation
- [ ] Test bulk approval
- [ ] Test bulk rejection
- [ ] Export to Excel functionality
- [ ] Check salary slip generation
- [ ] Verify RLS policies work correctly
- [ ] Test with edge cases (no attendance, all absent, etc.)

## Files Created/Modified

### Created:
1. `/database/salary-management-schema.sql` - Database schema
2. `/app/api/payroll/generate/route.ts` - Payroll generation API
3. `/app/api/payroll/approve/route.ts` - Payroll approval API
4. `/components/admin/PayrollManager.tsx` - Admin UI component

### To Modify:
1. `/app/admin/page.tsx` - Add Payroll tab
2. `/database/schema-setup.sql` - Already updated with fixes
3. `/app/api/create-employee/route.ts` - Already fixed

## Support & Maintenance

- System auto-resets leave balances yearly
- All salary calculations are audit-logged
- Historical payroll data retained indefinitely
- Configurable rules allow policy changes without code changes

---

**Status**: Ready for deployment and testing
**Last Updated**: November 9, 2025
