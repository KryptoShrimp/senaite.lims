-- =====================================================
-- SENAITE LIMS Database Schema - Performance Indexes (FINAL)
-- =====================================================
-- Performance indexes with correct column names from actual schema

-- =====================================================
-- CREATE INDEXES WITH PROPER COLUMN NAMES
-- =====================================================

-- Core user table indexes
CREATE INDEX IF NOT EXISTS idx_senaite_users_email ON senaite_users(email);
CREATE INDEX IF NOT EXISTS idx_senaite_users_username ON senaite_users(username);
CREATE INDEX IF NOT EXISTS idx_senaite_users_active ON senaite_users(is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_users_created ON senaite_users(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_users_azure_id ON senaite_users(azure_object_id);

-- User roles table indexes
CREATE INDEX IF NOT EXISTS idx_senaite_user_roles_user ON senaite_user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_user_roles_role ON senaite_user_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_senaite_user_roles_assigned ON senaite_user_roles(assigned_at);

-- Sample management indexes (corrected column names)
CREATE INDEX IF NOT EXISTS idx_senaite_samples_client ON senaite_samples(client_id);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_type ON senaite_samples(sample_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_status ON senaite_samples(status);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_created ON senaite_samples(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_received ON senaite_samples(received_date);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_sampling ON senaite_samples(sampling_date);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_priority ON senaite_samples(priority);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_composite ON senaite_samples(client_id, status, created_at);

-- Analysis indexes
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_sample ON senaite_analyses(sample_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_service ON senaite_analyses(analysis_service_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_status ON senaite_analyses(status);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_analyst ON senaite_analyses(analyst_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_instrument ON senaite_analyses(instrument_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_created ON senaite_analyses(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_started ON senaite_analyses(started_at);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_completed ON senaite_analyses(completed_at);

-- Result indexes
CREATE INDEX IF NOT EXISTS idx_senaite_results_analysis ON senaite_results(analysis_id);
CREATE INDEX IF NOT EXISTS idx_senaite_results_created ON senaite_results(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_results_approved ON senaite_results(approved_at);
CREATE INDEX IF NOT EXISTS idx_senaite_results_analyst ON senaite_results(analyst_id);

-- Client management indexes
CREATE INDEX IF NOT EXISTS idx_senaite_clients_type ON senaite_clients(client_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_status ON senaite_clients(account_status);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_active ON senaite_clients(is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_created ON senaite_clients(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_contacts_client ON senaite_contacts(client_id);
CREATE INDEX IF NOT EXISTS idx_senaite_contacts_type ON senaite_contacts(contact_type_id);

-- Department indexes
CREATE INDEX IF NOT EXISTS idx_senaite_departments_lab ON senaite_departments(laboratory_id);
CREATE INDEX IF NOT EXISTS idx_senaite_departments_active ON senaite_departments(is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_departments_code ON senaite_departments(code);

-- Instrument management indexes
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_type ON senaite_instruments(instrument_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_department ON senaite_instruments(department_id);
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_status ON senaite_instruments(status);
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_calibration ON senaite_instruments(next_calibration_date);
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_active ON senaite_instruments(is_active);

-- Analysis service indexes
CREATE INDEX IF NOT EXISTS idx_senaite_analysis_services_category ON senaite_analysis_services(category_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analysis_services_active ON senaite_analysis_services(is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_analysis_services_code ON senaite_analysis_services(code);

-- Sample type and container indexes
CREATE INDEX IF NOT EXISTS idx_senaite_sample_types_active ON senaite_sample_types(is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_sample_types_code ON senaite_sample_types(code);
CREATE INDEX IF NOT EXISTS idx_senaite_sample_containers_active ON senaite_sample_containers(is_active);

-- Workflow indexes
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_instances_workflow ON senaite_workflow_instances(workflow_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_instances_object ON senaite_workflow_instances(object_type, object_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_instances_state ON senaite_workflow_instances(current_state_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_instances_created ON senaite_workflow_instances(created_at);

-- Task management indexes
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_type ON senaite_tasks(task_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_assignee ON senaite_tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_status ON senaite_tasks(status);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_priority ON senaite_tasks(priority);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_due_date ON senaite_tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_created ON senaite_tasks(created_at);

-- Audit trail indexes
CREATE INDEX IF NOT EXISTS idx_senaite_audit_logs_table ON senaite_audit_logs(table_name);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_logs_record ON senaite_audit_logs(record_id);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_logs_user ON senaite_audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_logs_event ON senaite_audit_logs(event_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_logs_created ON senaite_audit_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_logs_composite ON senaite_audit_logs(table_name, record_id, created_at);

-- Notification indexes
CREATE INDEX IF NOT EXISTS idx_senaite_notifications_user ON senaite_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_notifications_type ON senaite_notifications(notification_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_notifications_read ON senaite_notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_senaite_notifications_created ON senaite_notifications(created_at);

-- Document management indexes
CREATE INDEX IF NOT EXISTS idx_senaite_documents_object ON senaite_documents(object_type, object_id);
CREATE INDEX IF NOT EXISTS idx_senaite_documents_type ON senaite_documents(document_type);
CREATE INDEX IF NOT EXISTS idx_senaite_documents_created ON senaite_documents(created_at);

-- Reporting indexes
CREATE INDEX IF NOT EXISTS idx_senaite_reports_template ON senaite_reports(template_id);
CREATE INDEX IF NOT EXISTS idx_senaite_reports_user ON senaite_reports(generated_by);
CREATE INDEX IF NOT EXISTS idx_senaite_reports_created ON senaite_reports(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_reports_status ON senaite_reports(status);

-- Settings indexes
CREATE INDEX IF NOT EXISTS idx_senaite_settings_category ON senaite_settings(category);
CREATE INDEX IF NOT EXISTS idx_senaite_settings_public ON senaite_settings(is_public);

-- Laboratory indexes
CREATE INDEX IF NOT EXISTS idx_senaite_laboratory_active ON senaite_laboratory(is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_laboratory_code ON senaite_laboratory(code);

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

-- Function to get table sizes
CREATE OR REPLACE FUNCTION get_table_sizes() RETURNS TABLE(
    table_name TEXT,
    row_count BIGINT,
    size_pretty TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.tablename::TEXT,
        COALESCE(s.n_tup_ins - s.n_tup_del, 0) AS row_count,
        pg_size_pretty(pg_total_relation_size(t.schemaname||'.'||t.tablename)) AS size_pretty
    FROM pg_tables t
    LEFT JOIN pg_stat_user_tables s ON s.relname = t.tablename
    WHERE t.schemaname = 'public' 
    AND t.tablename LIKE 'senaite_%'
    ORDER BY pg_total_relation_size(t.schemaname||'.'||t.tablename) DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to verify schema setup
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
    
    SELECT 'Users'::TEXT, 'senaite user exists'::TEXT, 
           COUNT(*)::BIGINT, CASE WHEN COUNT(*) > 0 THEN 'OK' ELSE 'MISSING' END::TEXT
    FROM pg_user 
    WHERE usename = 'senaite';
END;
$$ LANGUAGE plpgsql;

-- Function to check for missing indexes
CREATE OR REPLACE FUNCTION check_missing_indexes() RETURNS TABLE(
    table_name TEXT,
    suggested_index TEXT,
    reason TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.tablename::TEXT,
        'CREATE INDEX idx_' || t.tablename || '_missing ON ' || t.tablename || '(column_name);'::TEXT,
        'Check if this column needs indexing'::TEXT
    FROM pg_tables t
    WHERE t.schemaname = 'public' 
    AND t.tablename LIKE 'senaite_%'
    AND NOT EXISTS (
        SELECT 1 FROM pg_indexes i 
        WHERE i.tablename = t.tablename 
        AND i.schemaname = 'public'
    );
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMPLETION MESSAGE
-- =====================================================

DO $$
DECLARE
    table_count INTEGER;
    index_count INTEGER;
BEGIN
    -- Count tables
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name LIKE 'senaite_%';
    
    -- Count indexes
    SELECT COUNT(*) INTO index_count 
    FROM pg_indexes 
    WHERE schemaname = 'public' AND tablename LIKE 'senaite_%';
    
    RAISE NOTICE '=== SENAITE LIMS Performance Indexes Created Successfully ===';
    RAISE NOTICE 'Tables: %', table_count;
    RAISE NOTICE 'Indexes: %', index_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Verification functions available:';
    RAISE NOTICE '- SELECT * FROM verify_senaite_schema();';
    RAISE NOTICE '- SELECT * FROM get_table_sizes();';
    RAISE NOTICE '- SELECT * FROM check_missing_indexes();';
    RAISE NOTICE '';
    RAISE NOTICE 'Database schema is ready for SENAITE LIMS development!';
END $$;