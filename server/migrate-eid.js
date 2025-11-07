import postgres from 'postgres';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: resolve(__dirname, '../.env') });

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const dbPassword = process.env.SUPABASE_DB_PASSWORD;

function printManualInstructions() {
  console.log('\n╔════════════════════════════════════════════════════════════════╗');
  console.log('║         📋 MANUAL MIGRATION INSTRUCTIONS                       ║');
  console.log('╚════════════════════════════════════════════════════════════════╝\n');
  
  console.log('Copy and run this SQL in your Supabase SQL Editor:\n');
  console.log('─'.repeat(64));
  console.log('-- Migration: Add EID (Employee ID) column');
  console.log('ALTER TABLE employees ADD COLUMN IF NOT EXISTS eid VARCHAR(50) UNIQUE;');
  console.log('');
  console.log('-- Create index for faster lookups');
  console.log('CREATE INDEX IF NOT EXISTS idx_employees_eid ON employees(eid);');
  console.log('');
  console.log('-- Add documentation comment');
  console.log("COMMENT ON COLUMN employees.eid IS 'Employee ID Number - unique identifier for login';");
  console.log('─'.repeat(64));
  console.log('\n📍 Steps to run in Supabase:');
  console.log('   1. Go to https://supabase.com/dashboard');
  console.log('   2. Select your project');
  console.log('   3. Click "SQL Editor" in the left sidebar');
  console.log('   4. Click "New Query"');
  console.log('   5. Paste the SQL above');
  console.log('   6. Click "Run" (or press Cmd+Enter)\n');
  console.log('✅ After running, you can use EID for employee login!\n');
}

async function runMigration() {
  if (!supabaseUrl) {
    console.error('❌ VITE_SUPABASE_URL not found in .env file');
    printManualInstructions();
    process.exit(1);
  }

  if (!dbPassword) {
    console.log('⚠️  SUPABASE_DB_PASSWORD not found in .env file');
    console.log('\n💡 To enable automatic migration, add to your .env:');
    console.log('   SUPABASE_DB_PASSWORD=your_database_password\n');
    console.log('   (Find it in: Supabase Dashboard → Settings → Database → Connection String)\n');
    printManualInstructions();
    process.exit(1);
  }

  // Extract project reference from URL
  const projectRef = supabaseUrl.replace('https://', '').split('.')[0];
  
  console.log('🚀 Running EID Migration\n');
  console.log('📊 Project:', projectRef);
  console.log('🔌 Connecting to database...\n');

  const sql = postgres({
    host: `db.${projectRef}.supabase.co`,
    port: 5432,
    database: 'postgres',
    username: 'postgres',
    password: dbPassword,
    ssl: 'require'
  });

  try {
    // Check if column already exists
    console.log('🔍 Checking if eid column already exists...');
    const existingColumn = await sql`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'employees' AND column_name = 'eid'
    `;

    if (existingColumn.length > 0) {
      console.log('ℹ️  EID column already exists in employees table');
      console.log('✅ Migration already completed!\n');
      await sql.end();
      return;
    }

    // Add column
    console.log('📝 Adding eid column to employees table...');
    await sql`ALTER TABLE employees ADD COLUMN eid VARCHAR(50) UNIQUE`;
    console.log('✅ Column added');

    // Create index
    console.log('📝 Creating index on eid column...');
    await sql`CREATE INDEX idx_employees_eid ON employees(eid)`;
    console.log('✅ Index created');

    // Add comment
    console.log('📝 Adding column comment...');
    await sql`COMMENT ON COLUMN employees.eid IS 'Employee ID Number - unique identifier for login'`;
    console.log('✅ Comment added');

    console.log('\n╔════════════════════════════════════════════════════════════════╗');
    console.log('║             🎉 MIGRATION COMPLETED SUCCESSFULLY! 🎉            ║');
    console.log('╚════════════════════════════════════════════════════════════════╝\n');
    
    console.log('✅ You can now:');
    console.log('   • Add employees with EID numbers in the admin panel');
    console.log('   • Employees can login using either Email OR EID');
    console.log('   • Example EIDs: EMP001, BIM-2024-001, etc.\n');

  } catch (error) {
    console.error('\n❌ Migration failed:', error.message);
    console.log('\n💡 This might be because:');
    console.log('   • Database password is incorrect');
    console.log('   • Network connection issue');
    console.log('   • Database permissions\n');
    printManualInstructions();
  } finally {
    await sql.end();
  }
}

runMigration();
