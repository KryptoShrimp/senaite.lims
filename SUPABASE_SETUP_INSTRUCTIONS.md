# SENAITE LIMS Supabase Database Setup Instructions

## Method 1: Direct Supabase SQL Editor (Recommended)

Since the Python script has network connectivity issues, follow these steps to manually execute the SQL files in your Supabase dashboard:

### Step 1: Access Supabase SQL Editor
1. Go to your Supabase dashboard: https://app.supabase.com/
2. Select your project
3. Navigate to **SQL Editor** in the left sidebar

### Step 2: Execute SQL Files in Order

Copy and paste the contents of each file below **in this exact order** into the SQL Editor and click "Run":

#### 1. Create User (01_create_user.sql)
```sql
-- SENAITE LIMS Database Setup - User Creation
-- Execute this as a superuser in your Supabase database

-- Create the senaite database user
CREATE USER senaite WITH PASSWORD 'axf-xdh6KAH0xbz2jbq';

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON DATABASE postgres TO senaite;
GRANT ALL PRIVILEGES ON SCHEMA public TO senaite;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO senaite;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO senaite;

-- Allow user to create tables and manage schema
ALTER USER senaite CREATEDB;
ALTER USER senaite CREATEROLE;

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO senaite;
GRANT CREATE ON SCHEMA public TO senaite;

-- Set default privileges for future objects
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO senaite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO senaite;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO senaite;
```

#### 2. Core Tables (02_core_tables.sql)
**Open the file and copy its contents to SQL Editor**

#### 3. Laboratory Tables (03_laboratory_tables.sql)
**Open the file and copy its contents to SQL Editor**

#### 4. Client Tables (04_client_tables.sql)
**Open the file and copy its contents to SQL Editor**

#### 5. Workflow Tables (05_workflow_tables.sql)
**Open the file and copy its contents to SQL Editor**

#### 6. Audit & Reporting Tables (06_audit_reporting_tables.sql)
**Open the file and copy its contents to SQL Editor**

#### 7. Performance Indexes (07_performance_indexes.sql)
**Open the file and copy its contents to SQL Editor**

#### 8. Initial Data (08_initial_data.sql)
**Open the file and copy its contents to SQL Editor**

### Step 3: Verify Setup
After executing all files, run this verification query:

```sql
-- Verify table creation
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE tablename LIKE 'senaite_%'
ORDER BY tablename;

-- Count total tables created
SELECT COUNT(*) as total_tables
FROM pg_tables 
WHERE tablename LIKE 'senaite_%';

-- Check if senaite user exists
SELECT usename, usecreatedb, usesuper 
FROM pg_user 
WHERE usename = 'senaite';
```

### Expected Results
- **45+ tables** starting with `senaite_`
- **senaite user** created with appropriate permissions
- **No errors** during execution

## Method 2: pgAdmin or DBeaver

1. Connect to your Supabase database using:
   - Host: `db.hlegzvytcoqdvoqqqmaa.supabase.co`
   - Port: `5432`
   - Database: `postgres`
   - Username: `postgres`
   - Password: `axf-xdh6KAH0xbz2jbq`

2. Open each SQL file in order and execute them

## Method 3: psql Command Line

If you have psql installed:

```bash
# Execute all files in order
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U postgres -d postgres -f 01_create_user.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U postgres -d postgres -f 02_core_tables.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U postgres -d postgres -f 03_laboratory_tables.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U postgres -d postgres -f 04_client_tables.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U postgres -d postgres -f 05_workflow_tables.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U postgres -d postgres -f 06_audit_reporting_tables.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U postgres -d postgres -f 07_performance_indexes.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U postgres -d postgres -f 08_initial_data.sql
```

## Troubleshooting

### Common Issues:
1. **Permission Errors**: Make sure you're connected as the `postgres` superuser
2. **Syntax Errors**: Copy the entire file contents, don't miss any parts
3. **Duplicate Objects**: If you need to re-run, drop existing tables first

### If You Need to Start Over:
```sql
-- Drop all senaite tables
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

-- Then re-run the setup from step 1
```

## Next Steps
After successful execution:
1. Verify all tables exist
2. Test connection with senaite user
3. Start your SENAITE LIMS application
4. Configure DNS routing for your domain

## Files to Execute in Order:
- ✅ 01_create_user.sql
- ✅ 02_core_tables.sql  
- ✅ 03_laboratory_tables.sql
- ✅ 04_client_tables.sql
- ✅ 05_workflow_tables.sql
- ✅ 06_audit_reporting_tables.sql
- ✅ 07_performance_indexes.sql
- ✅ 08_initial_data.sql