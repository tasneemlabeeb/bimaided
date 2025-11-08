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
    const { payrollIds, action, approvedBy, remarks } = await req.json();

    if (!payrollIds || !action || !approvedBy) {
      return NextResponse.json({ 
        error: 'Payroll IDs, action, and approver are required' 
      }, { status: 400 });
    }

    if (!['approve', 'reject'].includes(action)) {
      return NextResponse.json({ 
        error: 'Action must be either "approve" or "reject"' 
      }, { status: 400 });
    }

    const status = action === 'approve' ? 'approved' : 'rejected';
    const now = new Date().toISOString();

    const { data, error } = await supabaseAdmin
      .from('monthly_payroll')
      .update({
        status,
        approved_by: approvedBy,
        approved_at: now,
        remarks: remarks || null
      })
      .in('id', payrollIds)
      .select();

    if (error) throw error;

    // If approved, generate salary slips
    if (action === 'approve') {
      const slips = data.map(payroll => ({
        payroll_id: payroll.id,
        employee_id: payroll.employee_id,
        slip_number: `SLP-${payroll.year}-${String(payroll.month).padStart(2, '0')}-${payroll.employee_id.substring(0, 8)}`,
        month: payroll.month,
        year: payroll.year,
        generated_at: now
      }));

      await supabaseAdmin
        .from('salary_slips')
        .upsert(slips, {
          onConflict: 'slip_number',
          ignoreDuplicates: true
        });
    }

    return NextResponse.json({
      success: true,
      message: `${data.length} payroll records ${status}`,
      data
    });

  } catch (error: any) {
    console.error('Payroll approval error:', error);
    return NextResponse.json({ 
      error: 'Failed to approve payroll',
      message: error.message 
    }, { status: 500 });
  }
}
