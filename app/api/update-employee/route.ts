import { createClient } from '@supabase/supabase-js';
import { NextResponse } from 'next/server';

// Initialize Supabase Admin Client
if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.SUPABASE_SERVICE_KEY) {
  throw new Error('Supabase credentials not found in environment variables');
}

const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

export async function POST(req: Request) {
  try {
    const { employeeId, ...updateData } = await req.json();

    if (!employeeId) {
      return NextResponse.json({ error: 'Employee ID is required' }, { status: 400 });
    }

    // Convert basicSalary to number if present
    if (updateData.basicSalary) {
      updateData.basicSalary = parseFloat(updateData.basicSalary);
    }

    const { data, error } = await supabaseAdmin
      .from('employees')
      .update(updateData)
      .eq('id', employeeId)
      .select()
      .single();

    if (error) {
      return NextResponse.json({ error: 'Failed to update employee', message: error.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, message: 'Employee updated successfully.', employee: data });

  } catch (error: any) {
    return NextResponse.json({ error: 'Internal server error', message: error.message }, { status: 500 });
  }
}

export async function PUT(req: Request) {
  try {
    // Extract employee ID from URL path
    const url = new URL(req.url);
    const pathParts = url.pathname.split('/');
    const employeeId = pathParts[pathParts.length - 1];

    if (!employeeId) {
      return NextResponse.json({ error: 'Employee ID is required' }, { status: 400 });
    }

    const {
      firstName,
      lastName,
      email,
      eid,
      gender,
      dateOfBirth,
      nationalId,
      phoneNumber,
      address,
      joiningDate,
      departmentId,
      designationId,
      supervisorId,
      employmentStatus,
      basicSalary,
      bankName,
      bankAccountNumber,
      bankBranch
    } = await req.json();

    const updateData: any = {
      first_name: firstName,
      last_name: lastName,
      email: email,
      eid: eid || null,
      gender: gender || null,
      date_of_birth: dateOfBirth || null,
      national_id: nationalId || null,
      phone: phoneNumber || null,
      address: address || null,
      joining_date: joiningDate,
      department_id: departmentId || null,
      designation_id: designationId || null,
      supervisor_id: supervisorId || null,
      employment_status: employmentStatus,
    };

    // Add salary and banking fields if provided
    if (basicSalary) {
      updateData.basic_salary = parseFloat(basicSalary);
    }
    if (bankName !== undefined) {
      updateData.bank_name = bankName || null;
    }
    if (bankAccountNumber !== undefined) {
      updateData.bank_account_number = bankAccountNumber || null;
    }
    if (bankBranch !== undefined) {
      updateData.bank_branch = bankBranch || null;
    }

    const { data, error } = await supabaseAdmin
      .from('employees')
      .update(updateData)
      .eq('id', employeeId)
      .select()
      .single();

    if (error) {
      return NextResponse.json({ success: false, error: 'Failed to update employee', message: error.message }, { status: 400 });
    }

    return NextResponse.json({ success: true, message: 'Employee updated successfully.', employee: data });

  } catch (error: any) {
    return NextResponse.json({ success: false, error: 'Internal server error', message: error.message }, { status: 500 });
  }
}
