import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';

export async function POST() {
  try {
    const supabaseUrl = 'http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me';
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY!;
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { error } = await supabase.auth.signOut();

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 });
    }

    // Create response and clear cookies
    const response = NextResponse.json({ success: true });
    
    response.cookies.delete('sb-access-token');
    response.cookies.delete('sb-refresh-token');

    return response;
  } catch (error: any) {
    console.error('Logout error:', error);
    return NextResponse.json(
      { error: error.message || 'An error occurred during logout' },
      { status: 500 }
    );
  }
}
