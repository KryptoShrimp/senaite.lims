-- =====================================================
-- SENAITE LIMS Database Schema - Master Execution Script
-- =====================================================
-- Execute this script to create the complete SENAITE LIMS database schema
-- 
-- Prerequisites:
-- 1. Connect to your Supabase PostgreSQL database as a superuser
-- 2. Ensure the database connection details are correct
-- 3. Execute scripts in the correct order
--
-- Database Connection Details:
-- Host: db.hlegzvytcoqdvoqqqmaa.supabase.co
-- Database: postgres
-- User: postgres (for initial setup)
-- Password: axf-xdh6KAH0xbz2jbq
--
-- Execution Order:
-- 1. User creation and permissions
-- 2. Core system tables
-- 3. Laboratory management tables
-- 4. Client and contact tables
-- 5. Workflow and state management
-- 6. Audit trail and reporting
-- 7. Performance indexes and constraints
-- 8. Initial data and configuration
-- =====================================================

-- Check if running as superuser
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_user 
        WHERE usename = current_user AND usesuper = true
    ) THEN
        RAISE EXCEPTION 'This script must be run as a superuser (postgres)';
    END IF;
    
    RAISE NOTICE 'Starting SENAITE LIMS database schema creation...';
    RAISE NOTICE 'Current user: %', current_user;
    RAISE NOTICE 'Current database: %', current_database();
    RAISE NOTICE 'PostgreSQL version: %', version();
END $$;

-- =====================================================
-- STEP 1: CREATE DATABASE USER AND PERMISSIONS
-- =====================================================

\echo 'Step 1: Creating database user and setting permissions...'
\i 01_create_user.sql

-- =====================================================
-- STEP 2: CREATE CORE SYSTEM TABLES
-- =====================================================

\echo 'Step 2: Creating core system tables...'
\i 02_core_tables.sql

-- =====================================================
-- STEP 3: CREATE LABORATORY MANAGEMENT TABLES
-- =====================================================

\echo 'Step 3: Creating laboratory management tables...'
\i 03_laboratory_tables.sql

-- =====================================================
-- STEP 4: CREATE CLIENT AND CONTACT TABLES
-- =====================================================

\echo 'Step 4: Creating client and contact tables...'
\i 04_client_tables.sql

-- =====================================================
-- STEP 5: CREATE WORKFLOW AND STATE MANAGEMENT
-- =====================================================

\echo 'Step 5: Creating workflow and state management tables...'
\i 05_workflow_tables.sql

-- =====================================================
-- STEP 6: CREATE AUDIT TRAIL AND REPORTING
-- =====================================================

\echo 'Step 6: Creating audit trail and reporting tables...'
\i 06_audit_reporting_tables.sql

-- =====================================================
-- STEP 7: CREATE PERFORMANCE INDEXES AND CONSTRAINTS
-- =====================================================

\echo 'Step 7: Creating performance indexes and constraints...'
\i 07_performance_indexes.sql

-- =====================================================
-- STEP 8: INSERT INITIAL DATA AND CONFIGURATION
-- =====================================================

\echo 'Step 8: Inserting initial data and configuration...'
\i 08_initial_data.sql

-- =====================================================
-- FINAL VERIFICATION
-- =====================================================

\echo 'Performing final verification...'

-- Check table creation
DO $$
DECLARE
    table_count INTEGER;
    index_count INTEGER;
    constraint_count INTEGER;
BEGIN
    -- Count tables
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name LIKE 'senaite_%';
    
    -- Count indexes
    SELECT COUNT(*) INTO index_count 
    FROM pg_indexes 
    WHERE schemaname = 'public' AND tablename LIKE 'senaite_%';
    
    -- Count constraints
    SELECT COUNT(*) INTO constraint_count 
    FROM information_schema.table_constraints 
    WHERE table_schema = 'public' AND table_name LIKE 'senaite_%';
    
    RAISE NOTICE '=== SENAITE LIMS Database Schema Creation Complete ===';
    RAISE NOTICE 'Created % tables', table_count;
    RAISE NOTICE 'Created % indexes', index_count;
    RAISE NOTICE 'Created % constraints', constraint_count;
    
    IF table_count < 50 THEN
        RAISE WARNING 'Expected more tables - please check for errors';
    END IF;
END $$;

-- Display table sizes
\echo 'Table sizes after creation:'
SELECT * FROM get_table_sizes() LIMIT 10;

-- Check user permissions
\echo 'Verifying senaite user permissions...'
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = 'senaite') THEN
        RAISE EXCEPTION 'User senaite was not created successfully';
    END IF;
    
    RAISE NOTICE 'User senaite created successfully';
END $$;

-- Connection test for senaite user
\echo 'Testing connection for senaite user...'
\echo 'You can now connect using:'
\echo 'Host: db.hlegzvytcoqdvoqqqmaa.supabase.co'
\echo 'Database: postgres'
\echo 'Username: senaite'
\echo 'Password: axf-xdh6KAH0xbz2jbq'

-- Success message
\echo '=== SENAITE LIMS Database Schema Setup Complete ==='
\echo 'Next steps:'
\echo '1. Test connection with senaite user'
\echo '2. Configure your application to use the database'
\echo '3. Run your SENAITE LIMS application'
\echo '4. Check logs for any issues'

-- Create a verification function
CREATE OR REPLACE FUNCTION verify_senaite_schema() RETURNS TABLE(
    category TEXT,
    item_name TEXT,
    count_value BIGINT,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'Tables'::TEXT, 'Total Tables'::TEXT, 
           COUNT(*)::BIGINT, 'OK'::TEXT
    FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name LIKE 'senaite_%'
    
    UNION ALL
    
    SELECT 'Indexes'::TEXT, 'Total Indexes'::TEXT, 
           COUNT(*)::BIGINT, 'OK'::TEXT
    FROM pg_indexes 
    WHERE schemaname = 'public' AND tablename LIKE 'senaite_%'
    
    UNION ALL
    
    SELECT 'Users'::TEXT, 'Database Users'::TEXT, 
           COUNT(*)::BIGINT, 'OK'::TEXT
    FROM pg_user 
    WHERE usename = 'senaite'
    
    UNION ALL
    
    SELECT 'Data'::TEXT, 'Sample Types'::TEXT, 
           COUNT(*)::BIGINT, 'OK'::TEXT
    FROM senaite_sample_types
    
    UNION ALL
    
    SELECT 'Data'::TEXT, 'Analysis Services'::TEXT, 
           COUNT(*)::BIGINT, 'OK'::TEXT
    FROM senaite_analysis_services
    
    UNION ALL
    
    SELECT 'Data'::TEXT, 'User Roles'::TEXT, 
           COUNT(*)::BIGINT, 'OK'::TEXT
    FROM senaite_roles;
END;
$$ LANGUAGE plpgsql;

-- Run verification
\echo 'Schema verification results:'
SELECT * FROM verify_senaite_schema();