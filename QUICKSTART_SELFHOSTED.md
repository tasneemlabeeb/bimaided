# 🚀 Quick Start - Self-Hosted Supabase

## ⚡ Immediate Access

**Supabase Studio**: http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me:3000

**Login**:
- Username: `supabase`
- Password: `jn1oeccs4konh8dsixz8xsapeowgg44s`

## 📝 Quick Setup Checklist

- [ ] **Step 1**: Access Supabase Studio (link above)
- [ ] **Step 2**: Run migration SQL (`00_complete_schema.sql` in SQL Editor)
- [ ] **Step 3**: Create 4 storage buckets (employee-photos, employee-documents, project-images, leave-attachments)
- [ ] **Step 4**: Create admin user (Authentication → Add User)
- [ ] **Step 5**: Assign admin role (run SQL below with your user ID)
- [ ] **Step 6**: Test app (`npm run dev` → http://localhost:5173)

## 🔑 Assign Admin Role SQL

```sql
-- Replace YOUR_USER_ID with the UUID from Authentication → Users
INSERT INTO user_roles (user_id, role)
VALUES ('YOUR_USER_ID', 'admin');

INSERT INTO employees (first_name, last_name, email, user_id, joining_date, employment_status, eid)
VALUES ('Admin', 'User', 'admin@bimaided.com', 'YOUR_USER_ID', CURRENT_DATE, 'Active', 'EID001');
```

## ⚠️ BEFORE PRODUCTION

**YOU MUST CHANGE THESE**:
- ✋ JWT_SECRET (currently demo value)
- ✋ ANON_KEY (currently demo value)
- ✋ SERVICE_ROLE_KEY (currently demo value)
- ✋ DASHBOARD_PASSWORD (currently weak)
- ✋ Enable HTTPS (currently HTTP only)

See `SUPABASE_SELFHOSTED_SETUP.md` for detailed instructions.

## 🔗 Current .env Configuration

Your `.env` file has been updated with:

```env
VITE_SUPABASE_URL=http://bimaided-website-pre0225supabase-ec4f00-72-60-222-97.traefik.me
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE
```

## 🏃 Start Development

```bash
npm run dev
```

Then open: http://localhost:5173

---

**For full setup guide**: See `SUPABASE_SELFHOSTED_SETUP.md`  
**For database schema**: See `supabase/migrations/00_complete_schema.sql`  
**For general setup**: See `DATABASE_SETUP_GUIDE.md`
