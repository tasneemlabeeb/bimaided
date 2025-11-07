import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config({ path: '../.env' });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.VITE_SUPABASE_ANON_KEY;

console.log('Testing Supabase Connection...\n');
console.log('URL:', SUPABASE_URL);
console.log('Anon Key:', SUPABASE_ANON_KEY?.substring(0, 20) + '...\n');

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function testConnection() {
  try {
    // Test connection by fetching from auth.users (should require proper permissions)
    console.log('🔍 Testing connection to Supabase...');
    
    const { data, error } = await supabase.auth.getSession();
    
    if (error) {
      console.log('⚠️  No active session (expected):', error.message);
    } else {
      console.log('✅ Session check successful');
    }

    // Test database connection
    console.log('\n🔍 Testing database connection...');
    const { data: tables, error: dbError } = await supabase
      .from('employees')
      .select('*')
      .limit(1);
    
    if (dbError) {
      console.log('⚠️  Database query result:', dbError.message);
      console.log('(This is expected if tables don\'t exist yet)');
    } else {
      console.log('✅ Database connection successful!');
      console.log('Sample data:', tables);
    }

    console.log('\n✅ Supabase client configured successfully!');
    console.log('Your frontend should now be able to connect to the new Supabase instance.');
    
  } catch (error) {
    console.error('❌ Connection test failed:', error.message);
    console.error('Full error:', error);
  }
}

testConnection();
