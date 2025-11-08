import { NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { cookies } from 'next/headers';

export async function GET() {
  try {
    const supabaseUrl = 'http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me';
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY!;
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Get session from cookies if available
    const cookieStore = await cookies();
    const accessToken = cookieStore.get('sb-access-token')?.value;
    const refreshToken = cookieStore.get('sb-refresh-token')?.value;

    if (accessToken && refreshToken) {
      const { data, error } = await supabase.auth.setSession({
        access_token: accessToken,
        refresh_token: refreshToken,
      });

      if (error) {
        return NextResponse.json({ session: null, error: error.message });
      }

      return NextResponse.json({ session: data.session });
    }

    return NextResponse.json({ session: null });
  } catch (error: any) {
    console.error('Session error:', error);
    return NextResponse.json(
      { session: null, error: error.message || 'An error occurred' },
      { status: 500 }
    );
  }
}
