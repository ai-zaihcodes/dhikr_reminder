# Supabase 500 Error Troubleshooting

## What does "500 Internal Server Error" mean?

A 500 error from Supabase typically means:
1. **Database tables don't exist** - The schema hasn't been run yet
2. **RLS policy issues** - Row Level Security is blocking requests
3. **Supabase project is paused** - Free projects pause after inactivity

## Quick Fix Steps

### Step 1: Check Supabase Project Status
1. Go to https://app.supabase.com
2. Select your project: `db.xsveadyxejofublpevsw.supabase.co`
3. Check if the project is **Active** (not paused)

### Step 2: Run the Database Schema

1. In Supabase Dashboard, go to **SQL Editor**
2. Click **New Query**
3. Copy the entire contents of `supabase/schema.sql` from this project
4. Click **Run**

### Step 3: Verify Tables Exist

Run this query in SQL Editor:
```sql
-- Check tables exist
SELECT * FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'quotes');

-- Check seed data
SELECT COUNT(*) FROM quotes WHERE is_global = true;

-- Check RLS is enabled
SELECT relname, relrowsecurity 
FROM pg_class 
WHERE relname IN ('profiles', 'quotes');
```

### Step 4: Check Auth Settings

1. Go to **Authentication** → **Providers**
2. Make sure **Email** provider is enabled
3. Check **URL Configuration**:
   - Site URL: `com.example.dhikr_reminder://login-callback`
   - Redirect URLs: Add your app callback URLs

## Common Issues

### Issue: "relation 'profiles' does not exist"
**Fix**: The schema.sql file hasn't been run. Go to SQL Editor and run it.

### Issue: "new row violates row-level security policy"
**Fix**: Check that the trigger `on_auth_user_created` exists:
```sql
-- Verify trigger exists
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
```

### Issue: "JWT expired" or "Invalid API key"
**Fix**: 
- Check you're using the **anon** key (not service_role)
- Verify the URL is correct in `main.dart`

### Issue: "User not authenticated" when calling database
**Fix**: User must be signed in before accessing database. The RLS policies require auth.

## Testing Connection

Run this simple test in SQL Editor:
```sql
-- Test insert (will fail if RLS blocks)
INSERT INTO quotes (text, translation, category, source, is_global)
VALUES ('Test', 'Test translation', 'general', 'Test', true)
RETURNING *;

-- Clean up test data
DELETE FROM quotes WHERE text = 'Test';
```

## App-Level Debugging

Enable debug logging in the app by setting:
```dart
await Supabase.initialize(
  url: 'https://db.xsveadyxejofublpevsw.supabase.co',
  anonKey: '...',
  debug: true,  // Add this
);
```

This will print detailed request/response logs to help diagnose issues.

## Still Having Issues?

Check Supabase logs:
1. Go to **Logs** → **API Gateway**
2. Look for 500 errors around the time of your requests
3. Check **Logs** → **Postgres** for database errors
