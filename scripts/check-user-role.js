import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function checkAndAddRole() {
  const userId = '835595cf-811d-4e8a-ba79-39e8b0f1795e';

  console.log('🔍 Checking user role for:', userId);

  // Check if role exists
  const { data: existingRole, error: checkError } = await supabase
    .from('user_roles')
    .select('*')
    .eq('user_id', userId)
    .single();

  if (checkError) {
    console.log('❌ Error checking role:', checkError.message);
    
    if (checkError.code === 'PGRST116') {
      console.log('\n📝 No role found. Adding admin role...');
      
      // Insert admin role
      const { data: newRole, error: insertError } = await supabase
        .from('user_roles')
        .insert({
          user_id: userId,
          role: 'admin'
        })
        .select()
        .single();

      if (insertError) {
        console.log('❌ Error adding role:', insertError.message);
        return;
      }

      console.log('✅ Admin role added successfully!');
      console.log('Role data:', newRole);
    }
  } else {
    console.log('✅ Role found:', existingRole);
  }

  // Also check if user exists in employees table
  console.log('\n🔍 Checking employee record...');
  const { data: employee, error: empError } = await supabase
    .from('employees')
    .select('*')
    .eq('auth_user_id', userId)
    .single();

  if (empError) {
    console.log('❌ Employee record error:', empError.message);
  } else {
    console.log('✅ Employee record found:');
    console.log('   EID:', employee.eid);
    console.log('   Name:', employee.first_name, employee.last_name);
    console.log('   Email:', employee.email);
  }
}

checkAndAddRole().catch(console.error);
