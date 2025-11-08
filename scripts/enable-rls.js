import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function enableRLS() {
  console.log('🔧 Enabling RLS policies for user_roles table...\n');

  // Enable RLS policy for user_roles
  const { error: policyError } = await supabase.rpc('exec_sql', {
    sql: `
      -- Enable RLS on user_roles table
      ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

      -- Drop existing policies if they exist
      DROP POLICY IF EXISTS "Users can view their own role" ON user_roles;
      DROP POLICY IF EXISTS "Service role can do everything" ON user_roles;

      -- Allow users to view their own role
      CREATE POLICY "Users can view their own role"
        ON user_roles
        FOR SELECT
        USING (auth.uid() = user_id);

      -- Allow service role to do everything
      CREATE POLICY "Service role can do everything"
        ON user_roles
        FOR ALL
        USING (true);

      -- Grant SELECT permission to authenticated users
      GRANT SELECT ON user_roles TO authenticated;
      GRANT SELECT ON user_roles TO anon;
    `
  });

  if (policyError) {
    console.log('❌ Error setting up policies:', policyError);
  } else {
    console.log('✅ RLS policies enabled successfully!');
  }
}

enableRLS().catch(console.error);
