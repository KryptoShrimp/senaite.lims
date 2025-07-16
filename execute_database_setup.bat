@echo off
echo =====================================================
echo SENAITE LIMS Database Setup Script
echo =====================================================
echo.
echo This script will execute the SENAITE LIMS database schema
echo in your Supabase database.
echo.
echo Connection Details:
echo - Host: db.hlegzvytcoqdvoqqqmaa.supabase.co
echo - Database: postgres
echo - User: postgres
echo.
echo =====================================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://www.python.org/downloads/
    pause
    exit /b 1
)

echo Python found. Checking for required libraries...
echo.

REM Try to install required PostgreSQL library
echo Installing psycopg2-binary...
pip install psycopg2-binary >nul 2>&1
if %errorlevel% neq 0 (
    echo psycopg2-binary installation failed, trying pg8000...
    pip install pg8000 >nul 2>&1
    if %errorlevel% neq 0 (
        echo ERROR: Failed to install PostgreSQL library
        echo Please manually install one of the following:
        echo   pip install psycopg2-binary
        echo   pip install pg8000
        pause
        exit /b 1
    )
    echo pg8000 installed successfully
) else (
    echo psycopg2-binary installed successfully
)

echo.
echo =====================================================
echo Starting database setup...
echo =====================================================
echo.

REM Execute the Python script
python execute_database_setup.py

if %errorlevel% equ 0 (
    echo.
    echo =====================================================
    echo Database setup completed successfully!
    echo =====================================================
    echo.
    echo Your SENAITE LIMS database is now ready to use.
    echo Check the database_setup.log file for detailed information.
) else (
    echo.
    echo =====================================================
    echo Database setup failed!
    echo =====================================================
    echo.
    echo Please check the database_setup.log file for error details.
    echo You may need to run this script again or execute files manually.
)

echo.
echo Press any key to exit...
pause >nul