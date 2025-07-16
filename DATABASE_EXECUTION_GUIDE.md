# SENAITE LIMS Database Setup Execution Guide

This guide provides multiple methods to execute the SENAITE LIMS database schema in your Supabase database.

## Connection Information

- **Host**: `db.hlegzvytcoqdvoqqqmaa.supabase.co`
- **Database**: `postgres`
- **Port**: `5432`
- **User**: `postgres`
- **Password**: `axf-xdh6KAH0xbz2jbq`

## SQL Files Execution Order

The following SQL files must be executed in this exact order:

1. `01_create_user.sql` - Creates the dedicated senaite database user
2. `02_core_tables.sql` - Creates core authentication and system tables
3. `03_laboratory_tables.sql` - Creates laboratory management tables
4. `04_client_tables.sql` - Creates client management tables
5. `05_workflow_tables.sql` - Creates workflow and process management tables
6. `06_audit_reporting_tables.sql` - Creates audit trail and reporting tables
7. `07_performance_indexes.sql` - Creates performance indexes and constraints
8. `08_initial_data.sql` - Inserts initial configuration data

## Method 1: Using Python Script (Recommended)

### Prerequisites
```bash
# Install PostgreSQL Python library
pip install psycopg2-binary
# OR if psycopg2 fails to install
pip install pg8000
```

### Execute
```bash
python execute_database_setup.py
```

The script will:
- Connect to your Supabase database
- Execute all SQL files in the correct order
- Verify table creation
- Provide detailed logging
- Show record counts for key tables

## Method 2: Using psql Command Line

### Prerequisites
Install PostgreSQL client tools:
- **Windows**: Download from https://www.postgresql.org/download/windows/
- **macOS**: `brew install postgresql`
- **Ubuntu/Debian**: `sudo apt-get install postgresql-client`

### Execute
```bash
# Execute each file individually
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -p 5432 -U postgres -d postgres -f 01_create_user.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -p 5432 -U postgres -d postgres -f 02_core_tables.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -p 5432 -U postgres -d postgres -f 03_laboratory_tables.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -p 5432 -U postgres -d postgres -f 04_client_tables.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -p 5432 -U postgres -d postgres -f 05_workflow_tables.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -p 5432 -U postgres -d postgres -f 06_audit_reporting_tables.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -p 5432 -U postgres -d postgres -f 07_performance_indexes.sql
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -p 5432 -U postgres -d postgres -f 08_initial_data.sql
```

## Method 3: Using Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Copy and paste the content of each SQL file in order
4. Execute each file one by one

## Method 4: Using pgAdmin

1. Open pgAdmin
2. Create a new server connection with the provided details
3. Right-click on your database → Query Tool
4. Open each SQL file and execute in order

## Method 5: Using DBeaver

1. Create a new PostgreSQL connection with the provided details
2. Right-click on your database → SQL Editor → Open SQL script
3. Open each SQL file and execute in order

## Verification Queries

After execution, run these queries to verify the setup:

### Check Tables Created
```sql
SELECT schemaname, tablename, tableowner 
FROM pg_tables 
WHERE schemaname = 'public' AND tablename LIKE 'senaite_%'
ORDER BY tablename;
```

### Check Initial Data
```sql
-- Check laboratory setup
SELECT name, code FROM senaite_laboratory;

-- Check departments
SELECT name, code FROM senaite_departments;

-- Check roles
SELECT name, description FROM senaite_roles;

-- Check sample types
SELECT name, code, sample_matrix FROM senaite_sample_types;

-- Check analysis services
SELECT name, code, unit, price FROM senaite_analysis_services LIMIT 10;

-- Check system settings
SELECT key, value, description FROM senaite_settings WHERE is_public = true;
```

### Check Record Counts
```sql
SELECT 
    'senaite_users' as table_name, COUNT(*) as record_count FROM senaite_users
UNION ALL
SELECT 
    'senaite_roles' as table_name, COUNT(*) as record_count FROM senaite_roles
UNION ALL
SELECT 
    'senaite_departments' as table_name, COUNT(*) as record_count FROM senaite_departments
UNION ALL
SELECT 
    'senaite_sample_types' as table_name, COUNT(*) as record_count FROM senaite_sample_types
UNION ALL
SELECT 
    'senaite_analysis_services' as table_name, COUNT(*) as record_count FROM senaite_analysis_services
UNION ALL
SELECT 
    'senaite_clients' as table_name, COUNT(*) as record_count FROM senaite_clients
UNION ALL
SELECT 
    'senaite_workflows' as table_name, COUNT(*) as record_count FROM senaite_workflows
UNION ALL
SELECT 
    'senaite_settings' as table_name, COUNT(*) as record_count FROM senaite_settings
ORDER BY table_name;
```

## What Gets Created

### Core Components
- **1 Laboratory** with 6 departments (Chemistry, Microbiology, Hematology, Pathology, QC, Sample Management)
- **7 User roles** with defined permissions (Administrator, Lab Manager, Senior Analyst, Analyst, Sample Manager, Client, QC)
- **15 System settings** for configuration

### Laboratory Setup
- **10 Sample types** (Whole Blood, Serum, Plasma, Urine, Stool, Tissue, Swab, Water, Soil, Food)
- **10 Container types** (EDTA Tube, Serum Tube, Heparin Tube, etc.)
- **8 Analysis categories** (Clinical Chemistry, Hematology, Microbiology, Immunology, Pathology, Toxicology, Molecular Biology, Endocrinology)
- **21 Analysis services** (Glucose, Cholesterol, CBC, Bacterial Culture, etc.)

### Instrument Management
- **8 Instrument types** (Chemistry Analyzer, Hematology Analyzer, Microscope, etc.)
- **4 Sample instruments** pre-configured

### Client Management
- **8 Client types** (Hospital, Clinic, Physician Office, Research, Pharmaceutical, Environmental, Industrial, Government)
- **3 Sample clients** pre-configured
- **5 Contact types** (Primary, Billing, Technical, Lab Manager, Physician)

### Workflow System
- **4 Workflow types** (Sample, Analysis, Instrument, Quality Control)
- **1 Complete sample workflow** with 6 states and 5 transitions

### Audit and Compliance
- **17 Audit event types** for comprehensive tracking
- **9 Notification types** for system alerts
- **10 Task types** for workflow management

## Troubleshooting

### Common Issues

1. **Connection Issues**
   - Verify your Supabase project is active
   - Check if your IP is whitelisted (if applicable)
   - Ensure SSL connection is enabled

2. **Permission Errors**
   - Make sure you're using the correct database user
   - The first script creates a dedicated 'senaite' user with proper permissions

3. **Table Already Exists**
   - If you need to re-run the setup, you may need to drop existing tables first
   - Use with caution: `DROP SCHEMA public CASCADE; CREATE SCHEMA public;`

4. **Foreign Key Errors**
   - Ensure you execute the files in the exact order specified
   - Do not skip any files

### Support

If you encounter issues:
1. Check the `database_setup.log` file for detailed error messages
2. Verify your connection details are correct
3. Ensure all prerequisite libraries are installed
4. Run the verification queries to check what was created successfully

## Security Notes

- The scripts create a dedicated 'senaite' user with appropriate permissions
- All passwords and sensitive data should be changed after initial setup
- Consider enabling additional security features in your Supabase project
- Regular backups are recommended before making schema changes

---

**Status**: Ready for execution
**Version**: 1.0
**Last Updated**: 2025-01-16