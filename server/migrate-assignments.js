import dotenv from 'dotenv';
import { Client } from 'pg';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({ path: path.join(__dirname, '..', '.env') });

const runMigration = async () => {
  console.log('🚀 Starting Assignments Tables Migration...\n');

  // Check for database password
  if (!process.env.SUPABASE_DB_PASSWORD) {
    console.log('⚠️  SUPABASE_DB_PASSWORD not found in environment variables.\n');
    console.log('📋 Please run this SQL manually in your Supabase SQL Editor:\n');
    console.log('Dashboard → SQL Editor → New Query\n');
    
    const sqlPath = path.join(__dirname, '..', 'database', 'migrations', '15_create_assignments_tables.sql');
    const sqlContent = fs.readFileSync(sqlPath, 'utf8');
    
    console.log('--- SQL TO RUN ---');
    console.log(sqlContent);
    console.log('--- END SQL ---\n');
    
    process.exit(1);
  }

  const connectionString = `postgresql://postgres.${process.env.SUPABASE_PROJECT_REF}:${process.env.SUPABASE_DB_PASSWORD}@aws-0-us-east-1.pooler.supabase.com:6543/postgres`;

  const client = new Client({
    connectionString,
    ssl: { rejectUnauthorized: false }
  });

  try {
    console.log('📡 Connecting to database...');
    await client.connect();
    console.log('✅ Connected successfully\n');

    // Check if tables already exist
    const checkQuery = `
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'assignments'
      ) as assignments_exists,
      EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'assignment_members'
      ) as members_exists;
    `;
    
    const checkResult = await client.query(checkQuery);
    const { assignments_exists, members_exists } = checkResult.rows[0];
    
    if (assignments_exists && members_exists) {
      console.log('ℹ️  Assignments tables already exist. Skipping creation.\n');
      console.log('✅ Migration complete!\n');
      process.exit(0);
    }

    console.log('📝 Creating assignments tables...');
    
    // Read and execute migration SQL
    const sqlPath = path.join(__dirname, '..', 'database', 'migrations', '15_create_assignments_tables.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    await client.query(sql);
    
    console.log('✅ Assignments tables created successfully\n');
    
    console.log('📊 Tables created:');
    console.log('   - assignments');
    console.log('   - assignment_members');
    console.log('   - assignment_details (view)\n');
    
    console.log('🔐 Row Level Security policies applied\n');
    
    console.log('✅ Migration complete!\n');

  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    console.error('\n📋 Full error:', error);
    process.exit(1);
  } finally {
    await client.end();
  }
};

runMigration();
