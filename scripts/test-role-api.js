import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function testRoleAPI() {
  const userId = '835595cf-811d-4e8a-ba79-39e8b0f1795e';

  console.log('🧪 Testing role API with anon key...\n');

  const { data, error } = await supabase
    .from('user_roles')
    .select('role')
    .eq('user_id', userId)
    .single();

  if (error) {
    console.log('❌ Error:', error);
    console.log('   Code:', error.code);
    console.log('   Message:', error.message);
    console.log('   Details:', error.details);
    console.log('   Hint:', error.hint);
  } else {
    console.log('✅ Success! Role data:', data);
  }
}

testRoleAPI().catch(console.error);
