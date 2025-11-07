import postgres from 'postgres';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: resolve(__dirname, '../.env') });

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const dbPassword = process.env.SUPABASE_DB_PASSWORD;

function printManualInstructions() {
  console.log('\n╔════════════════════════════════════════════════════════════════╗');
  console.log('║       📋 MANUAL MIGRATION INSTRUCTIONS (Leave Date Range)     ║');
  console.log('╚════════════════════════════════════════════════════════════════╝\n');
  
  console.log('Copy and run this SQL in your Supabase SQL Editor:\n');
  console.log('─'.repeat(64));
  console.log('-- Add leave date range columns to attendance table');
  console.log('ALTER TABLE attendance ADD COLUMN IF NOT EXISTS leave_start_date DATE;');
  console.log('ALTER TABLE attendance ADD COLUMN IF NOT EXISTS leave_end_date DATE;');
  console.log('ALTER TABLE attendance ADD COLUMN IF NOT EXISTS supporting_document_url TEXT;');
  console.log('');
  console.log('-- Create indexes for better query performance');
  console.log('CREATE INDEX IF NOT EXISTS idx_attendance_leave_start_date ON attendance(leave_start_date);');
  console.log('CREATE INDEX IF NOT EXISTS idx_attendance_leave_end_date ON attendance(leave_end_date);');
  console.log('');
  console.log('-- Add comments for documentation');
  console.log("COMMENT ON COLUMN attendance.leave_start_date IS 'Start date of leave period';");
  console.log("COMMENT ON COLUMN attendance.leave_end_date IS 'End date of leave period';");
  console.log("COMMENT ON COLUMN attendance.supporting_document_url IS 'URL to supporting document for leave request';");
  console.log('');
  console.log('-- For existing leave records, copy the date to both start and end');
  console.log("UPDATE attendance SET leave_start_date = date, leave_end_date = date WHERE status = 'Leave' AND leave_start_date IS NULL;");
  console.log('─'.repeat(64));
  console.log('\n📍 Steps to run in Supabase:');
  console.log('   1. Go to https://supabase.com/dashboard');
  console.log('   2. Select your project');
  console.log('   3. Click "SQL Editor" in the left sidebar');
  console.log('   4. Click "New Query"');
  console.log('   5. Paste the SQL above');
  console.log('   6. Click "Run" (or press Cmd+Enter)\n');
  console.log('✅ After running, employees can select date ranges for leave requests!\n');
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
  
  console.log('🚀 Running Leave Date Range Migration\n');
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
    // Check if columns already exist
    console.log('🔍 Checking if leave columns already exist...');
    const existingColumns = await sql`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'attendance' 
      AND column_name IN ('leave_start_date', 'leave_end_date', 'supporting_document_url')
    `;

    if (existingColumns.length === 3) {
      console.log('ℹ️  All leave columns already exist in attendance table');
      console.log('✅ Migration already completed!\n');
      await sql.end();
      return;
    }

    // Add columns
    console.log('📝 Adding leave_start_date column...');
    await sql`ALTER TABLE attendance ADD COLUMN IF NOT EXISTS leave_start_date DATE`;
    console.log('✅ leave_start_date column added');

    console.log('📝 Adding leave_end_date column...');
    await sql`ALTER TABLE attendance ADD COLUMN IF NOT EXISTS leave_end_date DATE`;
    console.log('✅ leave_end_date column added');

    console.log('📝 Adding supporting_document_url column...');
    await sql`ALTER TABLE attendance ADD COLUMN IF NOT EXISTS supporting_document_url TEXT`;
    console.log('✅ supporting_document_url column added');

    // Create indexes
    console.log('📝 Creating indexes...');
    await sql`CREATE INDEX IF NOT EXISTS idx_attendance_leave_start_date ON attendance(leave_start_date)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_attendance_leave_end_date ON attendance(leave_end_date)`;
    console.log('✅ Indexes created');

    // Add comments
    console.log('📝 Adding column comments...');
    await sql`COMMENT ON COLUMN attendance.leave_start_date IS 'Start date of leave period'`;
    await sql`COMMENT ON COLUMN attendance.leave_end_date IS 'End date of leave period'`;
    await sql`COMMENT ON COLUMN attendance.supporting_document_url IS 'URL to supporting document for leave request'`;
    console.log('✅ Comments added');

    // Update existing records
    console.log('📝 Updating existing leave records...');
    const result = await sql`
      UPDATE attendance 
      SET leave_start_date = date, leave_end_date = date 
      WHERE status = 'Leave' AND leave_start_date IS NULL
    `;
    console.log(`✅ Updated ${result.count} existing leave records`);

    console.log('\n╔════════════════════════════════════════════════════════════════╗');
    console.log('║             🎉 MIGRATION COMPLETED SUCCESSFULLY! 🎉            ║');
    console.log('╚════════════════════════════════════════════════════════════════╝\n');
    
    console.log('✅ You can now:');
    console.log('   • Employees can select date ranges for leave (start date and end date)');
    console.log('   • Support for single-day or multi-day leave requests');
    console.log('   • Better leave tracking and reporting\n');

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
