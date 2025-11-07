# Gallery Images Schema Update

## Problem
The application was trying to access `gallery_image_1` column that didn't exist in the projects table, causing a schema cache error.

## Solution
Added 6 gallery image columns to the projects table to support image galleries for each project.

## Changes Made

### 1. Database Schema Files Updated
- ✅ `database/03_create_public_tables.sql` - Added 6 gallery columns to CREATE TABLE statement
- ✅ `database/complete_migration.sql` - Added 6 gallery columns to projects table definition
- ✅ `database/08_add_gallery_columns.sql` - NEW: ALTER TABLE migration for existing databases

### 2. TypeScript Types Updated
- ✅ `src/integrations/supabase/types.ts` - Added gallery_image_1 through gallery_image_6 to Row, Insert, and Update types

### 3. Gallery Columns Added
All columns are of type `TEXT` and nullable:
- `gallery_image_1` - First gallery image URL
- `gallery_image_2` - Second gallery image URL
- `gallery_image_3` - Third gallery image URL
- `gallery_image_4` - Fourth gallery image URL
- `gallery_image_5` - Fifth gallery image URL
- `gallery_image_6` - Sixth gallery image URL

## Migration Paths

### For Fresh Database Setup
Run the complete migration as usual:
```bash
cd database
node run-migrations.js
# OR
bash quick-setup.sh
# OR execute complete_migration.sql in Supabase SQL Editor
```

### For Existing Database (Already Has Projects Table)
Run only the new ALTER TABLE migration:
```bash
# Using Supabase CLI
supabase db push --file database/08_add_gallery_columns.sql

# OR execute in Supabase SQL Editor
# Copy and paste contents of database/08_add_gallery_columns.sql
```

### Using Node.js
```javascript
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const supabase = createClient(
  process.env.VITE_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

const sql = fs.readFileSync('database/08_add_gallery_columns.sql', 'utf8');
const { error } = await supabase.rpc('exec', { sql });
```

## Verification

### Check if columns exist in Supabase
1. Go to Supabase Dashboard → Table Editor → projects table
2. Verify these columns are present:
   - gallery_image_1
   - gallery_image_2
   - gallery_image_3
   - gallery_image_4
   - gallery_image_5
   - gallery_image_6

### Test in Application
1. Restart the frontend server: `npm run dev`
2. Navigate to projects page
3. Schema cache error should be resolved

## Storage Integration

Gallery images should be stored in the `project-images` bucket:

```typescript
// Upload example
const { data, error } = await supabase.storage
  .from('project-images')
  .upload(`${projectId}/gallery-${index}.jpg`, file);

if (data) {
  const publicUrl = supabase.storage
    .from('project-images')
    .getPublicUrl(data.path).data.publicUrl;
  
  // Save publicUrl to gallery_image_1, gallery_image_2, etc.
}
```

## Next Steps

1. **If database is fresh**: Run complete_migration.sql
2. **If database exists**: Run 08_add_gallery_columns.sql
3. **After migration**: Restart frontend to clear any cached schema
4. **Test**: Try accessing a project with gallery images

## Files Reference

| File | Purpose | Status |
|------|---------|--------|
| `database/03_create_public_tables.sql` | Initial table creation | ✅ Updated |
| `database/complete_migration.sql` | All-in-one migration | ✅ Updated |
| `database/08_add_gallery_columns.sql` | ALTER TABLE for existing DBs | ✅ Created |
| `src/integrations/supabase/types.ts` | TypeScript types | ✅ Updated |

---
**Last Updated**: Just now  
**Schema Version**: 1.1 (with gallery columns)
