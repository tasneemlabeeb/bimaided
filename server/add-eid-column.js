import pg from 'pg';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: resolve(__dirname, '../.env') });

const { Client } = pg;

// Parse Supabase URL to get database connection details
const supabaseUrl = process.env.VITE_SUPABASE_URL;
const dbPassword = process.env.SUPABASE_DB_PASSWORD;

if (!supabaseUrl) {
  console.error('❌ VITE_SUPABASE_URL not found in .env');
  console.log('\n📋 Please run the migration manually in Supabase SQL Editor:\n');
  printMigrationSQL();
  process.exit(1);
}

if (!dbPassword) {
  console.error('❌ SUPABASE_DB_PASSWORD not found in .env');
  console.log('\n💡 You can find your database password in:');
  console.log('   Supabase Dashboard → Project Settings → Database → Connection String\n');
  console.log('📋 Or run the migration manually in Supabase SQL Editor:\n');
  printMigrationSQL();
  process.exit(1);
}

function printMigrationSQL() {
  console.log('----------------------------------------');
  console.log('-- Migration: Add EID column to employees table');
  console.log('----------------------------------------\n');
  console.log('-- Add EID column');
  console.log('ALTER TABLE employees ADD COLUMN IF NOT EXISTS eid VARCHAR(50) UNIQUE;\n');
  console.log('-- Create index for faster lookups');
  console.log('CREATE INDEX IF NOT EXISTS idx_employees_eid ON employees(eid);\n');
  console.log('-- Add comment for documentation');
  console.log("COMMENT ON COLUMN employees.eid IS 'Employee ID Number - unique identifier for login';");
  console.log('\n----------------------------------------\n');
  console.log('📍 To run this in Supabase:');
  console.log('1. Go to https://supabase.com/dashboard');
  console.log('2. Select your project');
  console.log('3. Click "SQL Editor" in the left sidebar');
  console.log('4. Click "New Query"');
  console.log('5. Paste the SQL above');
  console.log('6. Click "Run" or press Cmd/Ctrl + Enter\n');
}

async function runMigration() {
  // Extract project reference from Supabase URL
  const projectRef = supabaseUrl.replace('https://', '').split('.')[0];
  
  const client = new Client({
    host: `db.${projectRef}.supabase.co`,
    port: 5432,
    database: 'postgres',
    user: 'postgres',
    password: dbPassword,
    ssl: { rejectUnauthorized: false }
  });

  try {
    console.log('🔌 Connecting to database...');
    await client.connect();
    console.log('✅ Connected successfully\n');

    console.log('🚀 Running migration: Add EID column to employees table\n');

    // Step 1: Add the column
    console.log('Step 1: Adding eid column...');
    await client.query('ALTER TABLE employees ADD COLUMN IF NOT EXISTS eid VARCHAR(50) UNIQUE;');
    console.log('✅ Column added');

    // Step 2: Create index
    console.log('Step 2: Creating index...');
    await client.query('CREATE INDEX IF NOT EXISTS idx_employees_eid ON employees(eid);');
    console.log('✅ Index created');

    // Step 3: Add comment
    console.log('Step 3: Adding column comment...');
    await client.query("COMMENT ON COLUMN employees.eid IS 'Employee ID Number - unique identifier for login';");
    console.log('✅ Comment added');

    console.log('\n🎉 Migration completed successfully!\n');
    console.log('✅ You can now:');
    console.log('   - Add employees with EID numbers in the admin panel');
    console.log('   - Employees can login using either Email or EID\n');

  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    console.log('\n📋 Please run the migration manually instead:\n');
    printMigrationSQL();
  } finally {
    await client.end();
  }
}

// Check if we have password, if not, just print instructions
if (!dbPassword) {
  printMigrationSQL();
} else {
  runMigration();
}
