import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ eid: string }> }
) {
  try {
    const { eid } = await params;
    const supabaseUrl = 'http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me';
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY!;
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data, error } = await supabase
      .from('employees')
      .select('email')
      .eq('eid', eid)
      .single();

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 404 });
    }

    return NextResponse.json(data);
  } catch (error: any) {
    console.error('Employee lookup error:', error);
    return NextResponse.json(
      { error: error.message || 'An error occurred' },
      { status: 500 }
    );
  }
}
