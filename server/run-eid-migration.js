import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load environment variables from parent directory
dotenv.config({ path: resolve(__dirname, '../.env') });

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing Supabase credentials');
  console.error('VITE_SUPABASE_URL:', supabaseUrl ? '✓' : '✗');
  console.error('SUPABASE_SERVICE_KEY:', supabaseServiceKey ? '✓' : '✗');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function runMigration() {
  console.log('🚀 Running EID column migration...\n');

  try {
    // Step 1: Add the EID column
    console.log('Step 1: Adding EID column to employees table...');
    const { error: addColumnError } = await supabase.rpc('exec_sql', {
      sql: 'ALTER TABLE employees ADD COLUMN IF NOT EXISTS eid VARCHAR(50) UNIQUE;'
    });

    if (addColumnError) {
      // If RPC doesn't exist, we need to run it directly
      // Try alternative method
      console.log('⚠️  RPC method not available, trying direct query...');
      
      // This won't work through the client, but we can guide the user
      console.log('\n📋 Please run this SQL in your Supabase SQL Editor:\n');
      console.log('----------------------------------------');
      console.log('-- Add EID column');
      console.log('ALTER TABLE employees ADD COLUMN IF NOT EXISTS eid VARCHAR(50) UNIQUE;');
      console.log('\n-- Create index for faster lookups');
      console.log('CREATE INDEX IF NOT EXISTS idx_employees_eid ON employees(eid);');
      console.log('\n-- Add comment');
      console.log("COMMENT ON COLUMN employees.eid IS 'Employee ID Number - unique identifier for login';");
      console.log('----------------------------------------\n');
      
      console.log('📍 To run this:');
      console.log('1. Go to your Supabase Dashboard');
      console.log('2. Select your project');
      console.log('3. Go to SQL Editor (in the left sidebar)');
      console.log('4. Paste the SQL above');
      console.log('5. Click "Run" or press Cmd/Ctrl + Enter\n');
      
      return;
    }

    console.log('✅ EID column added successfully');

    // Step 2: Create index
    console.log('Step 2: Creating index on EID column...');
    const { error: indexError } = await supabase.rpc('exec_sql', {
      sql: 'CREATE INDEX IF NOT EXISTS idx_employees_eid ON employees(eid);'
    });

    if (indexError) {
      console.error('❌ Error creating index:', indexError);
    } else {
      console.log('✅ Index created successfully');
    }

    // Step 3: Add comment
    console.log('Step 3: Adding column comment...');
    const { error: commentError } = await supabase.rpc('exec_sql', {
      sql: "COMMENT ON COLUMN employees.eid IS 'Employee ID Number - unique identifier for login';"
    });

    if (commentError) {
      console.error('❌ Error adding comment:', commentError);
    } else {
      console.log('✅ Comment added successfully');
    }

    console.log('\n🎉 Migration completed successfully!');
    console.log('\n✅ You can now:');
    console.log('   - Add employees with EID numbers');
    console.log('   - Login using either Email or EID\n');

  } catch (error) {
    console.error('❌ Migration failed:', error);
    console.log('\n📋 Please run the migration manually in Supabase SQL Editor');
  }
}

runMigration();
