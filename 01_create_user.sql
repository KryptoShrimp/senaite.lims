-- =====================================================
-- SENAITE LIMS Database Setup - User Creation
-- =====================================================
-- This script creates the dedicated database user for SENAITE LIMS
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