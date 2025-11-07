# BIMSync Portal

A modern employee management and project portal built with React, TypeScript, and Supabase.

## Features

- 🔐 Role-based authentication (Admin/Employee)
- 👥 Employee management
- 📊 Project showcase and management
- 📅 Attendance tracking with check-in/check-out
- 📋 Assignment management
- 🏖️ Leave request system
- 💼 Career portal with job applications
- 🖼️ Image upload and storage
- 📧 Contact form

## Tech Stack

- **Frontend**: React 18, TypeScript, Vite
- **UI**: Tailwind CSS, shadcn/ui components
- **Backend**: Supabase (PostgreSQL, Storage, Auth)
- **State Management**: TanStack Query (React Query)
- **Routing**: React Router v6
- **Forms**: React Hook Form + Zod validation

## Prerequisites

- Node.js 18+ and npm
- Supabase account (get one free at https://supabase.com)

## Quick Start

### 1. Install Dependencies

```bash
npm install
cd admin-api && npm install && cd ..
```

### 2. Set Up Supabase

1. Go to [Supabase](https://supabase.com) and create a new project
2. Wait for the database to initialize
3. Go to Project Settings → API
4. Copy your project URL, anon key, and service_role key

### 3. Configure Environment

Update `.env` file with your Supabase credentials:

```env
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
VITE_ADMIN_API_URL=http://localhost:3001
```

Create `admin-api/.env` file:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
PORT=3001
ALLOWED_ORIGINS=http://localhost:8094,http://localhost:5173
```

⚠️ **IMPORTANT**: Never commit `admin-api/.env` to git. The service_role key has full database access.

### 4. Set Up Database Schema

Run the SQL migrations in your Supabase SQL Editor:

```bash
# See supabase/migrations/ for all migration files:
# - 00_complete_schema.sql - Main database schema (15 tables)
# - 15_fix_infinite_recursion.sql - RLS policy fixes
# - 16_add_job_applications.sql - Job applications table
```

See `DATABASE_MIGRATION_GUIDE.md` for detailed instructions.

### 5. Run Development Server

**One command to start everything:**

```bash
./start-dev.sh
```

This script will:
- Start the Admin API server (port 3001)
- Wait for it to be healthy
- Start the frontend dev server (port 8094)
- Keep both running together

To stop all servers:

```bash
./stop-dev.sh
```

To check server status:

```bash
./check-status.sh
```

**Manual start (not recommended):**

```bash
# Terminal 1 - Admin API
cd admin-api && npm run dev

# Terminal 2 - Frontend
npm run dev
```

Open http://localhost:8094 to view the app.

## Available Scripts

```bash
# Development
./start-dev.sh     # 🚀 Start both Admin API and Frontend (RECOMMENDED)
./stop-dev.sh      # 🛑 Stop all development servers
./check-status.sh  # 📊 Check if servers are running

# Build & Test
npm run dev        # Start frontend only (port 8094)
npm run build      # Build for production
npm run preview    # Preview production build
npm run lint       # Run ESLint

# Admin API (if running manually)
cd admin-api && npm run dev  # Start Admin API server (port 3001)
```

## Architecture

This project uses a two-server architecture:

1. **Frontend** (Vite/React) - Port 8094
   - User interface
   - Uses Supabase ANON key for public operations
   
2. **Admin API** (Express/Node) - Port 3001
   - Secure backend for privileged operations
   - Uses Supabase SERVICE_ROLE key
   - Required for: Creating employees, updating passwords, etc.

**Why?** Some operations (like creating users with auto-confirmed emails) require the SERVICE_ROLE key which should NEVER be exposed to the frontend for security reasons.

See `ADMIN_API_SETUP.md` for detailed documentation.

## Project Structure

```
src/
├── components/         # Reusable UI components
│   ├── admin/         # Admin dashboard components
│   ├── employee/      # Employee portal components
│   └── ui/            # shadcn/ui base components
├── pages/             # Route pages
├── hooks/             # Custom React hooks
├── lib/               # Utility functions
├── integrations/      # Supabase integration
│   └── supabase/      # Supabase client & types
└── assets/            # Static assets
```

## Authentication

The app uses Supabase Auth with the following default credentials structure:

- **Admin Role**: Full access to all features
- **Employee Role**: Limited to employee portal features

Configure Row Level Security (RLS) policies in Supabase for data protection.

## Storage

Supabase Storage is used for:
- Project images
- Employee profile pictures
- Document uploads

Set up storage buckets in your Supabase dashboard.

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

Private project - All rights reserved
