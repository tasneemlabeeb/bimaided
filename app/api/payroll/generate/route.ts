import { createClient } from '@supabase/supabase-js';
import { NextResponse } from 'next/server';

const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

export async function POST(req: Request) {
  try {
    const { month, year, employeeIds } = await req.json();

    if (!month || !year) {
      return NextResponse.json({ 
        error: 'Month and year are required' 
      }, { status: 400 });
    }

    // Get salary configuration
    const { data: config } = await supabaseAdmin
      .from('salary_configuration')
      .select('*');

    const configMap = config?.reduce((acc, item) => {
      acc[item.config_key] = parseInt(item.config_value);
      return acc;
    }, {} as Record<string, number>) || {};

    const lateTolerance = configMap.late_tolerance_count || 3;
    const workingDaysPerMonth = configMap.working_days_per_month || 30;

    // Get employees to process
    let employeeQuery = supabaseAdmin
      .from('employees')
      .select('id, first_name, last_name, basic_salary, casual_leave_balance, sick_leave_balance')
      .eq('employment_status', 'Active');

    if (employeeIds && employeeIds.length > 0) {
      employeeQuery = employeeQuery.in('id', employeeIds);
    }

    const { data: employees, error: empError } = await employeeQuery;

    if (empError) throw empError;

    const results = [];

    for (const employee of employees || []) {
      // Get attendance for the month
      const startDate = new Date(year, month - 1, 1);
      const endDate = new Date(year, month, 0);

      const { data: attendance } = await supabaseAdmin
        .from('attendance')
        .select('*')
        .eq('employee_id', employee.id)
        .gte('date', startDate.toISOString().split('T')[0])
        .lte('date', endDate.toISOString().split('T')[0]);

      // Get approved leaves for the month
      const { data: leaves } = await supabaseAdmin
        .from('leave_requests')
        .select('*')
        .eq('employee_id', employee.id)
        .eq('status', 'approved')
        .or(`start_date.lte.${endDate.toISOString().split('T')[0]},end_date.gte.${startDate.toISOString().split('T')[0]}`);

      // Calculate attendance metrics
      let presentDays = 0;
      let absentDays = 0;
      let lateDays = 0;
      let halfDays = 0;
      let hourlyLeaveHours = 0;

      attendance?.forEach(record => {
        if (record.status === 'present') presentDays++;
        else if (record.status === 'absent') absentDays++;
        else if (record.status === 'late') lateDays++;
        else if (record.status === 'half_day') halfDays += 0.5;

        if (record.leave_hours) hourlyLeaveHours += parseFloat(record.leave_hours);
      });

      // Calculate leave metrics
      let casualLeaveTaken = 0;
      let sickLeaveTaken = 0;
      let unpaidLeaveDays = 0;

      leaves?.forEach(leave => {
        const leaveStart = new Date(leave.start_date);
        const leaveEnd = new Date(leave.end_date);
        const monthStart = new Date(startDate);
        const monthEnd = new Date(endDate);

        const effectiveStart = leaveStart < monthStart ? monthStart : leaveStart;
        const effectiveEnd = leaveEnd > monthEnd ? monthEnd : leaveEnd;
        
        const leaveDays = Math.ceil((effectiveEnd.getTime() - effectiveStart.getTime()) / (1000 * 3600 * 24)) + 1;

        if (leave.leave_type === 'casual') casualLeaveTaken += leaveDays;
        else if (leave.leave_type === 'sick') sickLeaveTaken += leaveDays;
        else if (leave.leave_type === 'unpaid') unpaidLeaveDays += leaveDays;
      });

      // Check if leave exceeds entitlement
      const totalPaidLeaveUsed = casualLeaveTaken + sickLeaveTaken;
      const casualBalance = employee.casual_leave_balance || 10;
      const sickBalance = employee.sick_leave_balance || 10;
      const totalLeaveEntitlement = casualBalance + sickBalance;

      if (totalPaidLeaveUsed > totalLeaveEntitlement) {
        unpaidLeaveDays += (totalPaidLeaveUsed - totalLeaveEntitlement);
      }

      // Calculate late penalty
      const latePenaltyDays = Math.floor(lateDays / lateTolerance);

      // Calculate hourly leave as fractional days
      const hourlyLeaveDays = hourlyLeaveHours / 8; // Assuming 8 hours = 1 day

      // Calculate total deduction days
      const totalDeductionDays = unpaidLeaveDays + latePenaltyDays + hourlyLeaveDays;

      // Calculate daily rate and deductions
      const dailyRate = employee.basic_salary / workingDaysPerMonth;
      const totalDeduction = totalDeductionDays * dailyRate;
      const netPayableSalary = employee.basic_salary - totalDeduction;

      // Insert or update payroll record
      const { data: payroll, error: payrollError } = await supabaseAdmin
        .from('monthly_payroll')
        .upsert({
          employee_id: employee.id,
          month,
          year,
          basic_salary: employee.basic_salary,
          total_working_days: workingDaysPerMonth,
          total_present_days: presentDays,
          total_absent_days: absentDays,
          total_late_days: lateDays,
          total_half_days: halfDays,
          casual_leave_taken: casualLeaveTaken,
          sick_leave_taken: sickLeaveTaken,
          unpaid_leave_days: unpaidLeaveDays,
          late_penalty_days: latePenaltyDays,
          hourly_leave_hours: hourlyLeaveHours,
          total_deduction: totalDeduction,
          net_payable_salary: netPayableSalary,
          status: 'pending'
        }, {
          onConflict: 'employee_id,month,year'
        })
        .select()
        .single();

      if (payrollError) throw payrollError;

      // Insert deduction breakdown
      const deductions = [];

      if (unpaidLeaveDays > 0) {
        deductions.push({
          payroll_id: payroll.id,
          deduction_type: 'unpaid_leave',
          deduction_days: unpaidLeaveDays,
          deduction_amount: unpaidLeaveDays * dailyRate,
          description: `${unpaidLeaveDays} unpaid leave days`
        });
      }

      if (latePenaltyDays > 0) {
        deductions.push({
          payroll_id: payroll.id,
          deduction_type: 'late_penalty',
          deduction_days: latePenaltyDays,
          deduction_amount: latePenaltyDays * dailyRate,
          description: `${lateDays} late arrivals (every ${lateTolerance} = 1 day)`
        });
      }

      if (hourlyLeaveDays > 0) {
        deductions.push({
          payroll_id: payroll.id,
          deduction_type: 'hourly_leave',
          deduction_days: hourlyLeaveDays,
          deduction_amount: hourlyLeaveDays * dailyRate,
          description: `${hourlyLeaveHours} hours of leave taken`
        });
      }

      if (deductions.length > 0) {
        await supabaseAdmin
          .from('salary_deductions')
          .delete()
          .eq('payroll_id', payroll.id);

        await supabaseAdmin
          .from('salary_deductions')
          .insert(deductions);
      }

      results.push({
        employee_id: employee.id,
        employee_name: `${employee.first_name} ${employee.last_name}`,
        basic_salary: employee.basic_salary,
        total_deduction: totalDeduction,
        net_payable_salary: netPayableSalary,
        payroll_id: payroll.id
      });
    }

    return NextResponse.json({
      success: true,
      message: `Payroll generated for ${results.length} employees`,
      data: results
    });

  } catch (error: any) {
    console.error('Payroll generation error:', error);
    return NextResponse.json({ 
      error: 'Failed to generate payroll',
      message: error.message 
    }, { status: 500 });
  }
}
