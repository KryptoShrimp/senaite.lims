# SENAITE LIMS Database Schema Setup

This document provides comprehensive instructions for setting up the SENAITE LIMS database schema in Supabase PostgreSQL.

## Overview

The SENAITE LIMS database schema consists of:
- **Core System Tables**: User authentication, roles, settings, and laboratory information
- **Laboratory Management**: Samples, analyses, instruments, and methods
- **Client Management**: Clients, contacts, pricing, and contracts
- **Workflow Management**: State tracking, tasks, and notifications
- **Audit Trail**: Comprehensive logging and compliance tracking
- **Reporting System**: Report templates and generated reports

## Prerequisites

Before setting up the database, ensure you have:

1. **Supabase Account**: Access to your Supabase project
2. **Database Access**: Connection details for your PostgreSQL database
3. **Superuser Privileges**: Access to create users and manage permissions
4. **SQL Client**: Tool to execute SQL scripts (pgAdmin, psql, or Supabase SQL Editor)

## Database Connection Details

Your Supabase project details:
- **Host**: db.hlegzvytcoqdvoqqqmaa.supabase.co
- **Database**: postgres
- **Port**: 5432
- **Initial User**: postgres
- **Password**: axf-xdh6KAH0xbz2jbq

## Installation Methods

### Method 1: Automated Setup (Recommended)

Execute the master script that runs all setup steps:

```bash
# Using psql command line
psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U postgres -d postgres -f 00_execute_all.sql

# Or using Supabase SQL Editor
# Copy and paste the contents of 00_execute_all.sql
```

### Method 2: Manual Step-by-Step Setup

Execute each script in the correct order:

1. **Create Database User**
   ```sql
   \i 01_create_user.sql
   ```

2. **Create Core Tables**
   ```sql
   \i 02_core_tables.sql
   ```

3. **Create Laboratory Tables**
   ```sql
   \i 03_laboratory_tables.sql
   ```

4. **Create Client Tables**
   ```sql
   \i 04_client_tables.sql
   ```

5. **Create Workflow Tables**
   ```sql
   \i 05_workflow_tables.sql
   ```

6. **Create Audit and Reporting Tables**
   ```sql
   \i 06_audit_reporting_tables.sql
   ```

7. **Create Performance Indexes**
   ```sql
   \i 07_performance_indexes.sql
   ```

8. **Insert Initial Data**
   ```sql
   \i 08_initial_data.sql
   ```

## Schema Components

### Core Tables (02_core_tables.sql)
- `senaite_users`: User authentication and profiles
- `senaite_roles`: Role definitions and permissions
- `senaite_user_roles`: User-role assignments
- `senaite_user_sessions`: Active user sessions
- `senaite_settings`: System configuration
- `senaite_laboratory`: Laboratory information
- `senaite_departments`: Laboratory departments

### Laboratory Tables (03_laboratory_tables.sql)
- `senaite_sample_types`: Sample type definitions
- `senaite_sample_containers`: Container specifications
- `senaite_samples`: Sample records
- `senaite_analysis_categories`: Analysis groupings
- `senaite_analysis_services`: Available tests
- `senaite_analyses`: Individual analysis records
- `senaite_instruments`: Laboratory equipment
- `senaite_methods`: Analytical methods

### Client Tables (04_client_tables.sql)
- `senaite_clients`: Client organizations
- `senaite_contacts`: Client contacts
- `senaite_client_pricing`: Custom pricing
- `senaite_service_contracts`: Service agreements
- `senaite_invoices`: Billing records

### Workflow Tables (05_workflow_tables.sql)
- `senaite_workflows`: Workflow definitions
- `senaite_workflow_states`: State definitions
- `senaite_workflow_transitions`: State transitions
- `senaite_workflow_instances`: Object state tracking
- `senaite_tasks`: Task management
- `senaite_notifications`: System notifications

### Audit and Reporting Tables (06_audit_reporting_tables.sql)
- `senaite_audit_log`: Comprehensive audit trail
- `senaite_data_history`: Field-level change tracking
- `senaite_reports`: Generated reports
- `senaite_compliance_records`: Regulatory compliance
- `senaite_documents`: Document management

## Database User Configuration

The setup creates a dedicated database user for SENAITE:

- **Username**: senaite
- **Password**: axf-xdh6KAH0xbz2jbq
- **Permissions**: Full access to all SENAITE tables and sequences

## Initial Data

The schema includes initial configuration data:

### System Configuration
- Laboratory profile with departments
- User roles and permissions
- System settings and preferences

### Sample Data
- Sample types (Blood, Urine, Tissue, etc.)
- Container types (Tubes, bottles, etc.)
- Analysis categories and services
- Instrument types and sample instruments

### Workflow Configuration
- Sample processing workflow
- Analysis execution workflow
- Standard workflow states and transitions

### Reference Data
- Client types and sample clients
- Contact types
- Audit event types
- Notification types
- Task types

## Verification

After installation, verify the setup:

```sql
-- Check table creation
SELECT COUNT(*) as table_count 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name LIKE 'senaite_%';

-- Check user creation
SELECT usename FROM pg_user WHERE usename = 'senaite';

-- Run verification function
SELECT * FROM verify_senaite_schema();

-- Check table sizes
SELECT * FROM get_table_sizes() LIMIT 10;
```

Expected results:
- 50+ tables created
- 200+ indexes created
- User 'senaite' exists
- Initial data populated

## Application Configuration

Update your SENAITE LIMS application configuration:

### Environment Variables
```bash
# Database connection
SUPABASE_HOST=db.hlegzvytcoqdvoqqqmaa.supabase.co
SUPABASE_DB=postgres
SUPABASE_USER=senaite
SUPABASE_PASSWORD=axf-xdh6KAH0xbz2jbq

# Connection string format
RELSTORAGE_DSN=postgresql://senaite:axf-xdh6KAH0xbz2jbq@db.hlegzvytcoqdvoqqqmaa.supabase.co:5432/postgres
```

### Connection Testing
```python
import psycopg2

# Test connection
conn = psycopg2.connect(
    host="db.hlegzvytcoqdvoqqqmaa.supabase.co",
    database="postgres",
    user="senaite",
    password="axf-xdh6KAH0xbz2jbq"
)

# Test query
cursor = conn.cursor()
cursor.execute("SELECT COUNT(*) FROM senaite_users;")
print(f"Users table created: {cursor.fetchone()[0]} rows")
```

## Performance Optimization

The schema includes performance optimizations:

### Indexes
- Primary key indexes on all tables
- Foreign key indexes for relationships
- Composite indexes for common queries
- Partial indexes for filtered queries
- Functional indexes for case-insensitive searches

### Constraints
- Data validation constraints
- Referential integrity constraints
- Check constraints for valid values
- Unique constraints for business rules

### Maintenance Functions
- `update_table_statistics()`: Update query planner statistics
- `vacuum_analyze_senaite_tables()`: Maintenance and optimization
- `reindex_senaite_tables()`: Rebuild indexes
- `cleanup_old_logs()`: Remove old audit entries

## Security Considerations

The schema implements security best practices:

### User Management
- Dedicated database user with minimal privileges
- Role-based access control
- Session management and timeout
- Password complexity requirements

### Audit Trail
- Comprehensive logging of all activities
- Regulatory compliance tracking
- Data change history
- System event logging

### Data Protection
- Sensitive data identification
- Retention policies for audit logs
- Backup and recovery procedures

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Ensure you're connected as a superuser (postgres)
   - Check user privileges: `SELECT * FROM pg_user WHERE usename = 'senaite';`

2. **Table Already Exists**
   - Drop existing tables if recreating: `DROP TABLE IF EXISTS senaite_* CASCADE;`
   - Or use: `DROP SCHEMA public CASCADE; CREATE SCHEMA public;`

3. **Connection Issues**
   - Verify host, port, and credentials
   - Check firewall and network connectivity
   - Test with: `psql -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U senaite -d postgres`

4. **Foreign Key Errors**
   - Ensure scripts are executed in correct order
   - Check for circular dependencies
   - Verify referenced tables exist

### Logs and Monitoring

Monitor the setup process:

```sql
-- Check for errors in PostgreSQL logs
SELECT * FROM pg_stat_activity WHERE state = 'active';

-- Monitor table creation progress
SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del 
FROM pg_stat_user_tables 
WHERE schemaname = 'public' AND tablename LIKE 'senaite_%'
ORDER BY n_tup_ins DESC;
```

## Maintenance

### Regular Maintenance Tasks

1. **Update Statistics** (Weekly)
   ```sql
   SELECT update_table_statistics();
   ```

2. **Vacuum and Analyze** (Monthly)
   ```sql
   SELECT vacuum_analyze_senaite_tables();
   ```

3. **Clean Old Logs** (Monthly)
   ```sql
   SELECT cleanup_old_logs();
   ```

4. **Reindex Tables** (Quarterly)
   ```sql
   SELECT reindex_senaite_tables();
   ```

### Backup Strategy

1. **Database Backup**
   ```bash
   pg_dump -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U senaite -d postgres > senaite_backup.sql
   ```

2. **Schema Only Backup**
   ```bash
   pg_dump -h db.hlegzvytcoqdvoqqqmaa.supabase.co -U senaite -d postgres --schema-only > senaite_schema.sql
   ```

3. **Use Supabase Built-in Backup**
   - Enable automated backups in Supabase dashboard
   - Configure backup retention policies

## Support

For issues with the database schema:

1. Check the troubleshooting section above
2. Review PostgreSQL and Supabase documentation
3. Verify the application configuration
4. Test database connectivity independently

## Schema Version

- **Version**: 1.0.0
- **Compatible with**: SENAITE LIMS 2.x
- **PostgreSQL Version**: 12+
- **Last Updated**: 2025-01-16

## License

This database schema is part of the SENAITE LIMS project and follows the same licensing terms as the main application.