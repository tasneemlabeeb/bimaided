import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config({ path: path.join(__dirname, '..', '.env') });

const SUPABASE_URL = process.env.VITE_SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('❌ Error: Missing Supabase credentials in .env file');
  console.error('   Required: VITE_SUPABASE_URL and SUPABASE_SERVICE_KEY');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

// Migration files in order
const migrationFiles = [
  '01_create_enums.sql',
  '02_create_hr_tables.sql',
  '03_create_public_tables.sql',
  '04_create_functions_triggers.sql',
  '05_create_rls_policies.sql',
  '06_seed_data.sql'
];

async function executeSql(sql, description) {
  try {
    console.log(`\n📝 ${description}...`);
    
    const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/exec_sql`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_SERVICE_KEY,
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`,
        'Prefer': 'return=representation'
      },
      body: JSON.stringify({ query: sql })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`HTTP ${response.status}: ${errorText}`);
    }

    console.log('✅ Success!');
    return true;
  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
    return false;
  }
}

async function runMigrations() {
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║       BIMSync Portal - Database Migration Runner          ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');
  
  console.log(`🔗 Connecting to: ${SUPABASE_URL}`);
  console.log(`📁 Migration files: ${migrationFiles.length}\n`);

  let successCount = 0;
  let failureCount = 0;

  for (let i = 0; i < migrationFiles.length; i++) {
    const fileName = migrationFiles[i];
    const filePath = path.join(__dirname, fileName);
    
    console.log(`\n[${ i + 1}/${migrationFiles.length}] 📄 ${fileName}`);
    console.log('─'.repeat(60));

    try {
      // Check if file exists
      if (!fs.existsSync(filePath)) {
        console.error(`❌ File not found: ${filePath}`);
        failureCount++;
        continue;
      }

      // Read SQL file
      const sql = fs.readFileSync(filePath, 'utf8');
      
      // Split into statements (rough split by semicolon)
      const statements = sql
        .split(';')
        .map(s => s.trim())
        .filter(s => s.length > 0 && !s.startsWith('--') && s !== '');

      console.log(`   Found ${statements.length} SQL statements`);

      // Execute each statement
      for (let j = 0; j < statements.length; j++) {
        const statement = statements[j] + ';';
        
        // Skip comment-only statements
        if (statement.trim().replace(/\s+/g, ' ').startsWith('--')) {
          continue;
        }

        const shortDesc = statement.substring(0, 50).replace(/\n/g, ' ') + '...';
        const success = await executeSql(statement, `   [${j + 1}/${statements.length}] ${shortDesc}`);
        
        if (success) {
          successCount++;
        } else {
          failureCount++;
          // Continue with next statement instead of stopping
        }

        // Small delay to avoid rate limiting
        await new Promise(resolve => setTimeout(resolve, 100));
      }

      console.log(`✅ Completed: ${fileName}`);
      
    } catch (error) {
      console.error(`❌ Failed to process ${fileName}:`, error.message);
      failureCount++;
    }
  }

  // Summary
  console.log('\n╔════════════════════════════════════════════════════════════╗');
  console.log('║                    Migration Summary                       ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');
  console.log(`✅ Successful: ${successCount}`);
  console.log(`❌ Failed: ${failureCount}`);
  console.log(`📊 Total: ${successCount + failureCount}\n`);

  if (failureCount === 0) {
    console.log('🎉 All migrations completed successfully!');
    console.log('\n📋 Next steps:');
    console.log('   1. Verify tables in Supabase Dashboard');
    console.log('   2. Create your first admin user');
    console.log('   3. Test the application\n');
  } else {
    console.log('⚠️  Some migrations failed. Please check the errors above.');
    console.log('   You may need to run individual migration files manually.\n');
  }
}

// Run migrations
runMigrations().catch(error => {
  console.error('💥 Fatal error:', error);
  process.exit(1);
});
