#!/usr/bin/env python3
"""
SENAITE LIMS Database Verification Script

This script verifies that the SENAITE LIMS database has been set up correctly.
"""

import sys
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('database_verification.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Database connection parameters
DB_CONFIG = {
    'host': 'db.hlegzvytcoqdvoqqqmaa.supabase.co',
    'database': 'postgres',
    'user': 'postgres',
    'password': 'axf-xdh6KAH0xbz2jbq',
    'port': 5432,
    'sslmode': 'require'
}

def get_db_connection():
    """Get database connection using available PostgreSQL library"""
    try:
        import psycopg2
        conn = psycopg2.connect(**DB_CONFIG)
        logger.info("Connected using psycopg2")
        return conn
    except ImportError:
        try:
            import pg8000
            conn = pg8000.connect(**DB_CONFIG)
            logger.info("Connected using pg8000")
            return conn
        except ImportError:
            logger.error("Neither psycopg2 nor pg8000 is installed. Please install one of them:")
            logger.error("  pip install psycopg2-binary")
            logger.error("  or")
            logger.error("  pip install pg8000")
            return None

def verify_tables(cursor):
    """Verify that all expected tables exist"""
    expected_tables = [
        'senaite_users', 'senaite_roles', 'senaite_user_roles',
        'senaite_laboratory', 'senaite_departments', 'senaite_settings',
        'senaite_samples', 'senaite_sample_types', 'senaite_sample_containers',
        'senaite_analyses', 'senaite_analysis_services', 'senaite_analysis_categories',
        'senaite_clients', 'senaite_client_types', 'senaite_contacts',
        'senaite_instruments', 'senaite_instrument_types',
        'senaite_workflows', 'senaite_workflow_types', 'senaite_workflow_states',
        'senaite_audit_log', 'senaite_reports', 'senaite_documents'
    ]
    
    cursor.execute("""
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public' AND tablename LIKE 'senaite_%'
        ORDER BY tablename;
    """)
    
    existing_tables = [row[0] for row in cursor.fetchall()]
    
    logger.info(f"Found {len(existing_tables)} SENAITE tables:")
    for table in existing_tables:
        logger.info(f"  ✓ {table}")
    
    missing_tables = [table for table in expected_tables if table not in existing_tables]
    if missing_tables:
        logger.warning(f"Missing {len(missing_tables)} expected tables:")
        for table in missing_tables:
            logger.warning(f"  ✗ {table}")
        return False
    
    logger.info("✓ All expected tables are present")
    return True

def verify_initial_data(cursor):
    """Verify that initial data was loaded correctly"""
    data_checks = [
        ('senaite_laboratory', 'Laboratory', 1),
        ('senaite_departments', 'Departments', 6),
        ('senaite_roles', 'User Roles', 7),
        ('senaite_sample_types', 'Sample Types', 10),
        ('senaite_analysis_services', 'Analysis Services', 21),
        ('senaite_clients', 'Clients', 3),
        ('senaite_workflows', 'Workflows', 1),
        ('senaite_settings', 'System Settings', 15)
    ]
    
    logger.info("Verifying initial data...")
    all_good = True
    
    for table, description, expected_count in data_checks:
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {table};")
            actual_count = cursor.fetchone()[0]
            
            if actual_count >= expected_count:
                logger.info(f"  ✓ {description}: {actual_count} records (expected: {expected_count})")
            else:
                logger.warning(f"  ✗ {description}: {actual_count} records (expected: {expected_count})")
                all_good = False
        except Exception as e:
            logger.error(f"  ✗ {description}: Error checking - {str(e)}")
            all_good = False
    
    return all_good

def verify_constraints(cursor):
    """Verify that key constraints are in place"""
    try:
        cursor.execute("""
            SELECT conname, contype, conrelid::regclass 
            FROM pg_constraint 
            WHERE conrelid::regclass::text LIKE 'senaite_%'
            ORDER BY conrelid::regclass::text, conname;
        """)
        
        constraints = cursor.fetchall()
        
        foreign_keys = [c for c in constraints if c[1] == 'f']
        primary_keys = [c for c in constraints if c[1] == 'p']
        unique_constraints = [c for c in constraints if c[1] == 'u']
        check_constraints = [c for c in constraints if c[1] == 'c']
        
        logger.info(f"Database constraints summary:")
        logger.info(f"  ✓ Primary keys: {len(primary_keys)}")
        logger.info(f"  ✓ Foreign keys: {len(foreign_keys)}")
        logger.info(f"  ✓ Unique constraints: {len(unique_constraints)}")
        logger.info(f"  ✓ Check constraints: {len(check_constraints)}")
        
        return len(primary_keys) > 0 and len(foreign_keys) > 0
        
    except Exception as e:
        logger.error(f"Error verifying constraints: {str(e)}")
        return False

def verify_indexes(cursor):
    """Verify that performance indexes are created"""
    try:
        cursor.execute("""
            SELECT schemaname, tablename, indexname, indexdef 
            FROM pg_indexes 
            WHERE schemaname = 'public' AND tablename LIKE 'senaite_%'
            ORDER BY tablename, indexname;
        """)
        
        indexes = cursor.fetchall()
        
        # Group by table
        table_indexes = {}
        for schema, table, index, definition in indexes:
            if table not in table_indexes:
                table_indexes[table] = []
            table_indexes[table].append(index)
        
        logger.info(f"Database indexes summary:")
        total_indexes = 0
        for table, indexes in sorted(table_indexes.items()):
            logger.info(f"  ✓ {table}: {len(indexes)} indexes")
            total_indexes += len(indexes)
        
        logger.info(f"  ✓ Total indexes: {total_indexes}")
        
        return total_indexes > 50  # Should have many indexes
        
    except Exception as e:
        logger.error(f"Error verifying indexes: {str(e)}")
        return False

def verify_functions(cursor):
    """Verify that database functions are created"""
    try:
        cursor.execute("""
            SELECT proname, pronargs 
            FROM pg_proc 
            WHERE proname LIKE '%senaite%' OR proname LIKE '%update_updated_at%'
            ORDER BY proname;
        """)
        
        functions = cursor.fetchall()
        
        logger.info(f"Database functions summary:")
        for func_name, arg_count in functions:
            logger.info(f"  ✓ {func_name}({arg_count} args)")
        
        return len(functions) > 0
        
    except Exception as e:
        logger.error(f"Error verifying functions: {str(e)}")
        return False

def run_sample_queries(cursor):
    """Run some sample queries to verify functionality"""
    sample_queries = [
        ("Laboratory Information", "SELECT name, code, phone, email FROM senaite_laboratory;"),
        ("Available Departments", "SELECT name, code, description FROM senaite_departments WHERE is_active = true;"),
        ("User Roles", "SELECT name, description FROM senaite_roles ORDER BY name;"),
        ("Sample Types", "SELECT name, code, sample_matrix FROM senaite_sample_types WHERE is_active = true ORDER BY name;"),
        ("Analysis Services (first 5)", "SELECT name, code, unit, price FROM senaite_analysis_services WHERE is_active = true ORDER BY name LIMIT 5;"),
        ("System Settings", "SELECT key, value FROM senaite_settings WHERE is_public = true ORDER BY key;")
    ]
    
    logger.info("Running sample queries...")
    
    for query_name, query in sample_queries:
        try:
            cursor.execute(query)
            results = cursor.fetchall()
            logger.info(f"  ✓ {query_name}: {len(results)} results")
            
            # Show first few results for verification
            if results:
                for i, row in enumerate(results[:3]):
                    logger.info(f"    {i+1}. {row}")
                if len(results) > 3:
                    logger.info(f"    ... and {len(results) - 3} more")
            
        except Exception as e:
            logger.error(f"  ✗ {query_name}: Error - {str(e)}")

def main():
    """Main verification function"""
    logger.info("Starting SENAITE LIMS Database Verification")
    logger.info("=" * 50)
    
    # Get database connection
    conn = get_db_connection()
    if not conn:
        sys.exit(1)
    
    try:
        cursor = conn.cursor()
        
        # Run all verification checks
        checks_passed = 0
        total_checks = 5
        
        if verify_tables(cursor):
            checks_passed += 1
            
        if verify_initial_data(cursor):
            checks_passed += 1
            
        if verify_constraints(cursor):
            checks_passed += 1
            
        if verify_indexes(cursor):
            checks_passed += 1
            
        if verify_functions(cursor):
            checks_passed += 1
        
        logger.info("\n" + "=" * 50)
        
        # Run sample queries
        run_sample_queries(cursor)
        
        logger.info("\n" + "=" * 50)
        logger.info("VERIFICATION SUMMARY")
        logger.info("=" * 50)
        
        if checks_passed == total_checks:
            logger.info("✓ ALL CHECKS PASSED!")
            logger.info("✓ SENAITE LIMS database is properly set up and ready to use")
            logger.info("✓ All tables, constraints, indexes, and initial data are in place")
        else:
            logger.warning(f"⚠ {checks_passed} out of {total_checks} checks passed")
            logger.warning("Some issues were found. Please review the log for details.")
            
            if checks_passed >= 3:
                logger.info("The database is mostly functional but may need some attention.")
            else:
                logger.error("The database setup appears incomplete. Please re-run the setup script.")
    
    except Exception as e:
        logger.error(f"Unexpected error during verification: {str(e)}")
    
    finally:
        cursor.close()
        conn.close()
        logger.info("Verification completed - connection closed")

if __name__ == "__main__":
    main()