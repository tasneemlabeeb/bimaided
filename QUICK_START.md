# 🚀 Quick Start Guide - New Supabase Instance

## ⚡ Current Status
✅ Backend running on `http://localhost:3001`
✅ Frontend running on `http://localhost:8080`
✅ Supabase connection configured and tested

## 🔑 Quick Access

### Supabase Dashboard
- **URL**: http://supabasekong-i480ws8cosk4kwkskssck8o8.72.60.222.97.sslip.io
- **Username**: `Pfol7gWtuISetKvN`
- **Password**: `PDYLkun6aXWF4cYYUopC4R1x8pJi4VCn`

### Application URLs
- **Frontend**: http://localhost:8080
- **Backend API**: http://localhost:3001
- **Network**: http://192.168.0.107:8080

## 📦 Environment Variables (Already Configured)

Your `.env` file now contains:
```env
VITE_SUPABASE_URL=http://supabasekong-i480ws8cosk4kwkskssck8o8.72.60.222.97.sslip.io
VITE_SUPABASE_ANON_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
SUPABASE_SERVICE_KEY=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
DATABASE_URL=postgresql://postgres:417wIu14OxPmnQNpUCeieTSZ7IN6pYSa@supabase-db:5432/postgres
```

## 🛠️ Common Commands

### Start Servers
```bash
# Backend
node /Users/tasneemzaman/Desktop/Untitled/server/index.js

# Frontend
npm run dev
```

### Test Connections
```bash
# Test Supabase connection
cd server && node test-supabase.js

# Test PostgreSQL connection
cd server && node test-connection.js
```

### Stop Servers
```bash
# Kill all node processes
pkill -f node
```

## ⚠️ Important Notes

1. **Database is empty** - You need to create your schema/tables
2. **Google Drive** - Not configured (folder ID undefined)
3. **RLS Policies** - Need to be set up for security
4. **Authentication** - Email/password enabled by default

## 📋 Next Steps Checklist

- [ ] Create database schema/tables
- [ ] Set up Row Level Security policies
- [ ] Configure authentication settings
- [ ] Set up storage buckets (if needed)
- [ ] Test user registration/login
- [ ] Migrate existing data (if any)
- [ ] Configure Google Drive integration (optional)

## 🆘 Quick Troubleshooting

**Frontend not connecting?**
```bash
# Check if .env is loaded
cat .env | grep SUPABASE

# Restart Vite dev server
npm run dev
```

**Backend errors?**
```bash
# Check environment variables
cd server && node -e "require('dotenv').config({path:'../.env'}); console.log(process.env.VITE_SUPABASE_URL)"
```

**Database connection issues?**
```bash
# Test direct connection
cd server && node test-connection.js
```

---

📝 **For complete details**, see `SUPABASE_MIGRATION.md`
