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
```

### 2. Set Up Supabase

1. Go to [Supabase](https://supabase.com) and create a new project
2. Wait for the database to initialize
3. Go to Project Settings → API
4. Copy your project URL and anon key

### 3. Configure Environment

Update `.env` file with your Supabase credentials:

```env
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

### 4. Set Up Database Schema

You'll need to create the following tables in your Supabase dashboard:

#### Tables:
- `employees` - Employee records
- `projects` - Project information
- `attendance` - Check-in/check-out records
- `assignments` - Employee assignments
- `leave_requests` - Leave management
- `career_postings` - Job postings
- `job_applications` - Career applications

**See `supabase/` folder for complete SQL schema** (to be added)

### 5. Run Development Server

```bash
npm run dev
```

Open http://localhost:5173 to view the app.

## Available Scripts

```bash
npm run dev      # Start development server
npm run build    # Build for production
npm run preview  # Preview production build
npm run lint     # Run ESLint
```

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
