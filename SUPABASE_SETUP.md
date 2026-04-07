# Dhikr Reminder App

## What You Need to Connect to Supabase

### 1. Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com) and sign up/login
2. Create a new project
3. Choose a name (e.g., "dhikr-reminder")
4. Select a region closest to your users
5. Wait for the project to be created (~2 minutes)

### 2. Get Your Credentials

Once your project is ready:

1. Go to **Project Settings** → **API**
2. Copy these values:
   - **Project URL** (e.g., `https://abc123.supabase.co`)
   - **anon public** API key (starts with `eyJ...`)

### 3. Set Environment Variables

Choose one method:

**Option A: Using launch.json (VS Code)**

Create `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Dhikr Reminder",
            "request": "launch",
            "type": "dart",
            "args": [
                "--dart-define", "SUPABASE_URL=https://your-project.supabase.co",
                "--dart-define", "SUPABASE_ANON_KEY=your-anon-key"
            ]
        }
    ]
}
```

**Option B: Using command line**

```bash
flutter run --dart-define SUPABASE_URL=https://your-project.supabase.co --dart-define SUPABASE_ANON_KEY=your-anon-key
```

**Option C: Using .env file with flutter_dotenv**

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Create `.env` file:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### 4. Run the Database Schema

1. Go to Supabase Dashboard → **SQL Editor**
2. Click "New query"
3. Copy the entire contents of `supabase/schema.sql` from this project
4. Paste and click "Run"

This creates:
- `profiles` table (user settings)
- `quotes` table (Dhikr quotes)
- Row Level Security (RLS) policies
- Default seed data with 12 common Dhikr

### 5. Verify Setup

Run these queries in SQL Editor to verify:

```sql
-- Check tables exist
SELECT * FROM information_schema.tables WHERE table_schema = 'public';

-- Check seed data
SELECT * FROM quotes WHERE is_global = true;

-- Check RLS is enabled
SELECT relname, relrowsecurity FROM pg_class WHERE relname IN ('profiles', 'quotes');
```

### 6. Enable Authentication (Optional but Recommended)

1. Go to Supabase Dashboard → **Authentication**
2. Under "Email" provider, make sure it's enabled
3. Configure email templates if desired
4. For production, set up SMTP for real emails

## Quick Test

After setup, create a test user:

1. Run the app
2. Tap "Sign Up" and create an account
3. Check Supabase Dashboard → **Table Editor** → **profiles**
4. You should see a new row with your user's settings

## Troubleshooting

### "Invalid API key" error
- Double-check you've copied the correct key (anon, not service_role)
- Ensure no extra spaces in the URL/key

### "relation does not exist" error
- Database schema hasn't been run
- Go to SQL Editor and run the schema again

### Tables not appearing
- Refresh the Table Editor page
- Check that the query executed without errors

### Authentication not working
- Check Auth → Providers → Email is enabled
- Look at Auth → Logs for error details

## Need Help?

- Supabase Docs: https://supabase.com/docs
- Flutter Supabase: https://supabase.com/docs/guides/getting-started/tutorials/with-flutter
