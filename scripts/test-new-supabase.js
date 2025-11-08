import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'http://supabasekong-n4g4og0cos0ocwg0ss8cswss.72.60.222.97.sslip.io';
const supabaseAnonKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjU5Mzk2MCwiZXhwIjo0OTE4MjY3NTYwLCJyb2xlIjoiYW5vbiJ9.TuGXG83THiqENV8Nern5GwkiS7R6OCY4SGcB9cD-6XE';
const supabaseServiceKey = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MjU5Mzk2MCwiZXhwIjo0OTE4MjY3NTYwLCJyb2xlIjoic2VydmljZV9yb2xlIn0.-X1sUGnaBrVLPeh3ZTgJN5SqEb55aI_mauvyKUyE4P8';

async function testConnection() {
  console.log('🧪 Testing connection to new Coolify Supabase instance...\n');
  console.log('📍 URL:', supabaseUrl);
  console.log('');

  // Test with service key
  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  try {
    // Test 1: Check if we can query any table
    console.log('Test 1: Checking database connection...');
    const { data: tables, error: tablesError } = await supabase
      .from('user_roles')
      .select('*')
      .limit(1);

    if (tablesError) {
      console.log('❌ Error:', tablesError.message);
      console.log('   Code:', tablesError.code);
      console.log('   Details:', tablesError.details);
    } else {
      console.log('✅ Database connected!');
      console.log('   Found', tables?.length || 0, 'records in user_roles table');
    }

    // Test 2: List all tables
    console.log('\nTest 2: Checking available tables...');
    const { data: schemaData, error: schemaError } = await supabase
      .rpc('exec_sql', {
        sql: `
          SELECT table_name 
          FROM information_schema.tables 
          WHERE table_schema = 'public' 
          ORDER BY table_name;
        `
      });

    if (schemaError) {
      console.log('❌ Could not list tables:', schemaError.message);
    } else {
      console.log('✅ Available tables:', schemaData);
    }

    // Test 3: Check auth
    console.log('\nTest 3: Checking auth service...');
    const { data: authData, error: authError } = await supabase.auth.getSession();
    
    if (authError) {
      console.log('⚠️  Auth check:', authError.message);
    } else {
      console.log('✅ Auth service is accessible');
    }

    console.log('\n✨ Connection test completed!');
  } catch (error) {
    console.error('❌ Unexpected error:', error);
  }
}

testConnection().catch(console.error);
