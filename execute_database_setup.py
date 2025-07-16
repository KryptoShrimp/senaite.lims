#!/usr/bin/env python3
"""
SENAITE LIMS Database Setup Script

This script executes the SQL files in the correct order to set up the SENAITE LIMS database schema in Supabase.

Requirements:
- Install psycopg2-binary: pip install psycopg2-binary
- Or install pg8000: pip install pg8000

Usage:
    python execute_database_setup.py

Connection Details:
- Host: db.hlegzvytcoqdvoqqqmaa.supabase.co
- Database: postgres
- Port: 5432
- User: postgres
- Password: axf-xdh6KAH0xbz2jbq
"""

import os
import sys
import logging
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('database_setup.log'),
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

# SQL files to execute in order
SQL_FILES = [
    '01_create_user.sql',
    '02_core_tables.sql',
    '03_laboratory_tables.sql',
    '04_client_tables.sql',
    '05_workflow_tables.sql',
    '06_audit_reporting_tables.sql',
    '07_performance_indexes.sql',
    '08_initial_data.sql'
]

def get_db_connection():
    """Get database connection using available PostgreSQL library"""
    try:
        import psycopg2
        conn = psycopg2.connect(**DB_CONFIG)
        logger.info("Connected using psycopg2")
        return conn, 'psycopg2'
    except ImportError:
        try:
            import pg8000
            conn = pg8000.connect(**DB_CONFIG)
            logger.info("Connected using pg8000")
            return conn, 'pg8000'
        except ImportError:
            logger.error("Neither psycopg2 nor pg8000 is installed. Please install one of them:")
            logger.error("  pip install psycopg2-binary")
            logger.error("  or")
            logger.error("  pip install pg8000")
            return None, None

def execute_sql_file(cursor, file_path, db_type):
    """Execute SQL file content"""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            sql_content = file.read()
        
        logger.info(f"Executing {file_path.name}...")
        
        if db_type == 'psycopg2':
            cursor.execute(sql_content)
        else:  # pg8000
            # pg8000 doesn't support executing multiple statements at once
            # Split by semicolon and execute individually
            statements = [stmt.strip() for stmt in sql_content.split(';') if stmt.strip()]
            for stmt in statements:
                if stmt:
                    cursor.execute(stmt)
        
        logger.info(f"Successfully executed {file_path.name}")
        return True
        
    except Exception as e:
        logger.error(f"Error executing {file_path.name}: {str(e)}")
        return False

def verify_table_creation(cursor):
    """Verify that tables were created successfully"""
    try:
        cursor.execute("""
            SELECT schemaname, tablename, tableowner 
            FROM pg_tables 
            WHERE schemaname = 'public' AND tablename LIKE 'senaite_%'
            ORDER BY tablename;
        """)
        
        tables = cursor.fetchall()
        logger.info(f"Found {len(tables)} SENAITE tables:")
        
        for table in tables:
            logger.info(f"  - {table[1]} (owner: {table[2]})")
        
        return len(tables) > 0
        
    except Exception as e:
        logger.error(f"Error verifying table creation: {str(e)}")
        return False

def get_table_counts(cursor):
    """Get record counts for key tables"""
    try:
        tables_to_check = [
            'senaite_users',
            'senaite_roles',
            'senaite_laboratory',
            'senaite_departments',
            'senaite_sample_types',
            'senaite_analysis_services',
            'senaite_clients',
            'senaite_workflows',
            'senaite_settings'
        ]
        
        logger.info("Table record counts:")
        for table in tables_to_check:
            try:
                cursor.execute(f"SELECT COUNT(*) FROM {table};")
                count = cursor.fetchone()[0]
                logger.info(f"  - {table}: {count} records")
            except Exception as e:
                logger.warning(f"  - {table}: Error getting count - {str(e)}")
        
    except Exception as e:
        logger.error(f"Error getting table counts: {str(e)}")

def main():
    """Main execution function"""
    logger.info("Starting SENAITE LIMS Database Setup")
    logger.info("=" * 50)
    
    # Get database connection
    conn, db_type = get_db_connection()
    if not conn:
        sys.exit(1)
    
    current_dir = Path(__file__).parent
    success_count = 0
    
    try:
        cursor = conn.cursor()
        
        # Execute each SQL file in order
        for sql_file in SQL_FILES:
            file_path = current_dir / sql_file
            
            if not file_path.exists():
                logger.error(f"SQL file not found: {file_path}")
                continue
            
            if execute_sql_file(cursor, file_path, db_type):
                success_count += 1
                conn.commit()
                logger.info(f"Committed changes for {sql_file}")
            else:
                logger.error(f"Failed to execute {sql_file}")
                conn.rollback()
                break
        
        # Verify table creation
        if success_count == len(SQL_FILES):
            logger.info("\nVerifying table creation...")
            if verify_table_creation(cursor):
                logger.info("✓ Tables created successfully")
                
                # Get table counts
                get_table_counts(cursor)
                
                logger.info("\n" + "=" * 50)
                logger.info("SENAITE LIMS Database Setup Completed Successfully!")
                logger.info("=" * 50)
                logger.info(f"✓ Executed {success_count} out of {len(SQL_FILES)} SQL files")
                logger.info("✓ All database objects created")
                logger.info("✓ Initial data loaded")
                logger.info("\nYour SENAITE LIMS database is ready to use!")
                
            else:
                logger.error("✗ Table verification failed")
        else:
            logger.error(f"✗ Only {success_count} out of {len(SQL_FILES)} files executed successfully")
    
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        conn.rollback()
    
    finally:
        cursor.close()
        conn.close()
        logger.info("Database connection closed")

if __name__ == "__main__":
    main()