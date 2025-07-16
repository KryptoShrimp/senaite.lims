-- =====================================================
-- SENAITE LIMS Database Schema - Performance Indexes & Constraints
-- =====================================================
-- Additional indexes, constraints, and performance optimizations

-- =====================================================
-- COMPOSITE INDEXES FOR COMMON QUERIES
-- =====================================================

-- Samples: Common query patterns
CREATE INDEX idx_senaite_samples_client_status ON senaite_samples(client_id, status);
CREATE INDEX idx_senaite_samples_type_received ON senaite_samples(sample_type_id, received_at);
CREATE INDEX idx_senaite_samples_dept_workflow ON senaite_samples(department_id, workflow_state);
CREATE INDEX idx_senaite_samples_received_status ON senaite_samples(received_at, status);
CREATE INDEX idx_senaite_samples_priority_received ON senaite_samples(priority, received_at);

-- Analyses: Common query patterns
CREATE INDEX idx_senaite_analyses_sample_status ON senaite_analyses(sample_id, status);
CREATE INDEX idx_senaite_analyses_service_status ON senaite_analyses(service_id, status);
CREATE INDEX idx_senaite_analyses_assigned_status ON senaite_analyses(assigned_to, status);
CREATE INDEX idx_senaite_analyses_completed_validated ON senaite_analyses(completed_at, validated_at);
CREATE INDEX idx_senaite_analyses_workflow_assigned ON senaite_analyses(workflow_state, assigned_to);

-- Clients: Common query patterns
CREATE INDEX idx_senaite_clients_type_status ON senaite_clients(client_type_id, account_status);
CREATE INDEX idx_senaite_clients_name_status ON senaite_clients(name, account_status);

-- Contacts: Common query patterns
CREATE INDEX idx_senaite_contacts_client_type ON senaite_contacts(client_id, contact_type_id);
CREATE INDEX idx_senaite_contacts_client_active ON senaite_contacts(client_id, is_active);
CREATE INDEX idx_senaite_contacts_email_active ON senaite_contacts(email, is_active);

-- Instruments: Common query patterns
CREATE INDEX idx_senaite_instruments_dept_status ON senaite_instruments(department_id, status);
CREATE INDEX idx_senaite_instruments_type_status ON senaite_instruments(instrument_type_id, status);
CREATE INDEX idx_senaite_instruments_next_calibration ON senaite_instruments(next_calibration_date, status);
CREATE INDEX idx_senaite_instruments_next_maintenance ON senaite_instruments(next_maintenance_date, status);

-- Workflow instances: Common query patterns
CREATE INDEX idx_senaite_workflow_instances_object_workflow ON senaite_workflow_instances(object_type, object_id, workflow_id);
CREATE INDEX idx_senaite_workflow_instances_state_updated ON senaite_workflow_instances(current_state_code, updated_at);

-- Tasks: Common query patterns
CREATE INDEX idx_senaite_tasks_assigned_status ON senaite_tasks(assigned_to, status);
CREATE INDEX idx_senaite_tasks_due_status ON senaite_tasks(due_date, status);
CREATE INDEX idx_senaite_tasks_priority_status ON senaite_tasks(priority, status);
CREATE INDEX idx_senaite_tasks_related_object ON senaite_tasks(related_object_type, related_object_id);

-- Audit log: Common query patterns
CREATE INDEX idx_senaite_audit_log_user_occurred ON senaite_audit_log(user_id, occurred_at);
CREATE INDEX idx_senaite_audit_log_object_occurred ON senaite_audit_log(object_type, object_id, occurred_at);
CREATE INDEX idx_senaite_audit_log_action_occurred ON senaite_audit_log(action, occurred_at);
CREATE INDEX idx_senaite_audit_log_regulatory_occurred ON senaite_audit_log(is_regulatory, occurred_at);

-- Reports: Common query patterns
CREATE INDEX idx_senaite_reports_user_generated ON senaite_reports(generated_by, generated_at);
CREATE INDEX idx_senaite_reports_template_generated ON senaite_reports(template_id, generated_at);
CREATE INDEX idx_senaite_reports_related_type ON senaite_reports(related_object_type, generated_at);

-- =====================================================
-- PARTIAL INDEXES FOR FILTERED QUERIES
-- =====================================================

-- Active records only
CREATE INDEX idx_senaite_samples_active ON senaite_samples(received_at) WHERE status != 'archived';
CREATE INDEX idx_senaite_analyses_active ON senaite_analyses(created_at) WHERE status != 'cancelled';
CREATE INDEX idx_senaite_clients_active ON senaite_clients(name) WHERE account_status = 'active';
CREATE INDEX idx_senaite_contacts_active ON senaite_contacts(client_id) WHERE is_active = true;
CREATE INDEX idx_senaite_instruments_active ON senaite_instruments(department_id) WHERE is_active = true;
CREATE INDEX idx_senaite_tasks_pending ON senaite_tasks(due_date) WHERE status IN ('pending', 'in_progress');

-- Overdue items
CREATE INDEX idx_senaite_tasks_overdue ON senaite_tasks(assigned_to, due_date) 
    WHERE due_date < CURRENT_TIMESTAMP AND status IN ('pending', 'in_progress');

-- Recent activities
CREATE INDEX idx_senaite_audit_log_recent ON senaite_audit_log(occurred_at, user_id) 
    WHERE occurred_at > CURRENT_TIMESTAMP - INTERVAL '30 days';

-- Unread notifications
CREATE INDEX idx_senaite_notifications_unread ON senaite_notifications(recipient_id, created_at) 
    WHERE is_read = false;

-- =====================================================
-- FUNCTIONAL INDEXES
-- =====================================================

-- Case-insensitive searches
CREATE INDEX idx_senaite_clients_name_lower ON senaite_clients(LOWER(name));
CREATE INDEX idx_senaite_contacts_email_lower ON senaite_contacts(LOWER(email));
CREATE INDEX idx_senaite_users_username_lower ON senaite_users(LOWER(username));
CREATE INDEX idx_senaite_users_email_lower ON senaite_users(LOWER(email));

-- Date extractions for reporting
CREATE INDEX idx_senaite_samples_received_date ON senaite_samples(DATE(received_at));
CREATE INDEX idx_senaite_analyses_completed_date ON senaite_analyses(DATE(completed_at));
CREATE INDEX idx_senaite_audit_log_occurred_date ON senaite_audit_log(DATE(occurred_at));

-- JSON field indexes for custom properties
CREATE INDEX idx_senaite_samples_custom_properties ON senaite_samples USING GIN(custom_properties);
CREATE INDEX idx_senaite_analyses_custom_properties ON senaite_analyses USING GIN(custom_properties);
CREATE INDEX idx_senaite_clients_custom_properties ON senaite_clients USING GIN(custom_properties);

-- =====================================================
-- CONSTRAINTS AND DATA INTEGRITY
-- =====================================================

-- Email format validation
ALTER TABLE senaite_users ADD CONSTRAINT chk_senaite_users_email_format 
    CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

ALTER TABLE senaite_contacts ADD CONSTRAINT chk_senaite_contacts_email_format 
    CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

ALTER TABLE senaite_clients ADD CONSTRAINT chk_senaite_clients_email_format 
    CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Positive numeric constraints
ALTER TABLE senaite_analysis_services ADD CONSTRAINT chk_senaite_analysis_services_price_positive 
    CHECK (price IS NULL OR price >= 0);

ALTER TABLE senaite_client_pricing ADD CONSTRAINT chk_senaite_client_pricing_price_positive 
    CHECK (price >= 0);

ALTER TABLE senaite_instruments ADD CONSTRAINT chk_senaite_instruments_capacity_positive 
    CHECK (true); -- Placeholder - add specific numeric constraints as needed

-- Date range constraints
ALTER TABLE senaite_samples ADD CONSTRAINT chk_senaite_samples_date_order 
    CHECK (collected_at IS NULL OR received_at IS NULL OR collected_at <= received_at);

ALTER TABLE senaite_analyses ADD CONSTRAINT chk_senaite_analyses_date_order 
    CHECK (started_at IS NULL OR completed_at IS NULL OR started_at <= completed_at);

ALTER TABLE senaite_service_contracts ADD CONSTRAINT chk_senaite_service_contracts_date_order 
    CHECK (start_date <= end_date);

-- Status value constraints
ALTER TABLE senaite_samples ADD CONSTRAINT chk_senaite_samples_status_valid 
    CHECK (status IN ('received', 'registered', 'sampled', 'analyzed', 'reported', 'archived'));

ALTER TABLE senaite_analyses ADD CONSTRAINT chk_senaite_analyses_status_valid 
    CHECK (status IN ('registered', 'assigned', 'in_progress', 'completed', 'verified', 'published'));

ALTER TABLE senaite_clients ADD CONSTRAINT chk_senaite_clients_account_status_valid 
    CHECK (account_status IN ('active', 'suspended', 'closed'));

ALTER TABLE senaite_instruments ADD CONSTRAINT chk_senaite_instruments_status_valid 
    CHECK (status IN ('operational', 'maintenance', 'out_of_service', 'calibration'));

-- Priority value constraints
ALTER TABLE senaite_samples ADD CONSTRAINT chk_senaite_samples_priority_valid 
    CHECK (priority IN ('low', 'normal', 'high', 'urgent'));

ALTER TABLE senaite_tasks ADD CONSTRAINT chk_senaite_tasks_priority_valid 
    CHECK (priority IN ('low', 'medium', 'high', 'critical'));

ALTER TABLE senaite_notifications ADD CONSTRAINT chk_senaite_notifications_priority_valid 
    CHECK (priority IN ('low', 'normal', 'high', 'urgent'));

-- Percentage constraints
ALTER TABLE senaite_clients ADD CONSTRAINT chk_senaite_clients_discount_percentage_valid 
    CHECK (discount_percentage IS NULL OR (discount_percentage >= 0 AND discount_percentage <= 100));

ALTER TABLE senaite_client_pricing ADD CONSTRAINT chk_senaite_client_pricing_discount_percentage_valid 
    CHECK (discount_percentage IS NULL OR (discount_percentage >= 0 AND discount_percentage <= 100));

-- =====================================================
-- UNIQUE CONSTRAINTS
-- =====================================================

-- Ensure unique active primary contacts per client
CREATE UNIQUE INDEX idx_senaite_contacts_unique_primary_per_client 
    ON senaite_contacts(client_id) 
    WHERE is_primary = true AND is_active = true;

-- Ensure unique active workflow instances per object
CREATE UNIQUE INDEX idx_senaite_workflow_instances_unique_active 
    ON senaite_workflow_instances(object_type, object_id, workflow_id);

-- Ensure unique active default workflows per type
CREATE UNIQUE INDEX idx_senaite_workflows_unique_default_per_type 
    ON senaite_workflows(workflow_type_id) 
    WHERE is_default = true AND is_active = true;

-- =====================================================
-- FOREIGN KEY CONSTRAINTS (Additional)
-- =====================================================

-- Ensure data consistency for related objects
ALTER TABLE senaite_workflow_instances 
    ADD CONSTRAINT chk_senaite_workflow_instances_object_exists 
    CHECK (
        (object_type = 'sample' AND object_id IS NOT NULL) OR
        (object_type = 'analysis' AND object_id IS NOT NULL) OR
        (object_type = 'instrument' AND object_id IS NOT NULL) OR
        (object_type = 'client' AND object_id IS NOT NULL) OR
        (object_type = 'user' AND object_id IS NOT NULL)
    );

-- =====================================================
-- PERFORMANCE OPTIMIZATION FUNCTIONS
-- =====================================================

-- Function to update table statistics
CREATE OR REPLACE FUNCTION update_table_statistics() RETURNS void AS $$
DECLARE
    table_name TEXT;
BEGIN
    -- Update statistics for all SENAITE tables
    FOR table_name IN 
        SELECT tablename FROM pg_tables 
        WHERE schemaname = 'public' AND tablename LIKE 'senaite_%'
    LOOP
        EXECUTE 'ANALYZE ' || table_name;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to get table sizes for monitoring
CREATE OR REPLACE FUNCTION get_table_sizes() RETURNS TABLE(
    table_name TEXT,
    row_count BIGINT,
    total_size TEXT,
    table_size TEXT,
    index_size TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.tablename::TEXT,
        s.n_tup_ins - s.n_tup_del AS row_count,
        pg_size_pretty(pg_total_relation_size(c.oid)) AS total_size,
        pg_size_pretty(pg_relation_size(c.oid)) AS table_size,
        pg_size_pretty(pg_total_relation_size(c.oid) - pg_relation_size(c.oid)) AS index_size
    FROM pg_tables t
    JOIN pg_class c ON c.relname = t.tablename
    JOIN pg_stat_user_tables s ON s.relname = t.tablename
    WHERE t.schemaname = 'public' AND t.tablename LIKE 'senaite_%'
    ORDER BY pg_total_relation_size(c.oid) DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- MAINTENANCE FUNCTIONS
-- =====================================================

-- Function to reindex all SENAITE tables
CREATE OR REPLACE FUNCTION reindex_senaite_tables() RETURNS void AS $$
DECLARE
    table_name TEXT;
BEGIN
    FOR table_name IN 
        SELECT tablename FROM pg_tables 
        WHERE schemaname = 'public' AND tablename LIKE 'senaite_%'
    LOOP
        EXECUTE 'REINDEX TABLE ' || table_name;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to vacuum analyze all SENAITE tables
CREATE OR REPLACE FUNCTION vacuum_analyze_senaite_tables() RETURNS void AS $$
DECLARE
    table_name TEXT;
BEGIN
    FOR table_name IN 
        SELECT tablename FROM pg_tables 
        WHERE schemaname = 'public' AND tablename LIKE 'senaite_%'
    LOOP
        EXECUTE 'VACUUM ANALYZE ' || table_name;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- QUERY OPTIMIZATION VIEWS
-- =====================================================

-- View for common sample queries
CREATE VIEW v_senaite_samples_summary AS
SELECT 
    s.id,
    s.sample_id,
    s.client_sample_id,
    s.status,
    s.priority,
    s.received_at,
    s.workflow_state,
    st.name AS sample_type_name,
    c.name AS client_name,
    d.name AS department_name,
    COUNT(a.id) AS analysis_count,
    COUNT(CASE WHEN a.status = 'completed' THEN 1 END) AS completed_analyses,
    COUNT(CASE WHEN a.status IN ('registered', 'assigned', 'in_progress') THEN 1 END) AS pending_analyses
FROM senaite_samples s
LEFT JOIN senaite_sample_types st ON s.sample_type_id = st.id
LEFT JOIN senaite_clients c ON s.client_id = c.id
LEFT JOIN senaite_departments d ON s.department_id = d.id
LEFT JOIN senaite_analyses a ON s.id = a.sample_id
GROUP BY s.id, s.sample_id, s.client_sample_id, s.status, s.priority, 
         s.received_at, s.workflow_state, st.name, c.name, d.name;

-- View for analysis workload
CREATE VIEW v_senaite_analysis_workload AS
SELECT 
    u.id AS user_id,
    u.username,
    u.full_name,
    COUNT(a.id) AS total_assigned,
    COUNT(CASE WHEN a.status = 'assigned' THEN 1 END) AS pending_analyses,
    COUNT(CASE WHEN a.status = 'in_progress' THEN 1 END) AS in_progress_analyses,
    COUNT(CASE WHEN a.status = 'completed' THEN 1 END) AS completed_analyses,
    AVG(CASE WHEN a.completed_at IS NOT NULL THEN 
        EXTRACT(EPOCH FROM (a.completed_at - a.started_at))/3600 END) AS avg_completion_hours
FROM senaite_users u
LEFT JOIN senaite_analyses a ON u.id = a.assigned_to
WHERE u.is_active = true
GROUP BY u.id, u.username, u.full_name;

-- View for client activity
CREATE VIEW v_senaite_client_activity AS
SELECT 
    c.id,
    c.client_id,
    c.name,
    c.account_status,
    COUNT(s.id) AS total_samples,
    COUNT(CASE WHEN s.received_at > CURRENT_TIMESTAMP - INTERVAL '30 days' THEN 1 END) AS recent_samples,
    COUNT(a.id) AS total_analyses,
    COUNT(CASE WHEN a.created_at > CURRENT_TIMESTAMP - INTERVAL '30 days' THEN 1 END) AS recent_analyses,
    MAX(s.received_at) AS last_sample_date
FROM senaite_clients c
LEFT JOIN senaite_samples s ON c.id = s.client_id
LEFT JOIN senaite_analyses a ON s.id = a.sample_id
GROUP BY c.id, c.client_id, c.name, c.account_status;

-- =====================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================

COMMENT ON TABLE senaite_users IS 'Core user authentication and profile information';
COMMENT ON TABLE senaite_samples IS 'Laboratory samples with collection and receipt information';
COMMENT ON TABLE senaite_analyses IS 'Individual analysis requests and results';
COMMENT ON TABLE senaite_clients IS 'Client organizations and contact information';
COMMENT ON TABLE senaite_instruments IS 'Laboratory instruments and equipment';
COMMENT ON TABLE senaite_workflow_instances IS 'Workflow state tracking for objects';
COMMENT ON TABLE senaite_audit_log IS 'Comprehensive audit trail for all system activities';
COMMENT ON TABLE senaite_reports IS 'Generated reports and documents';

-- Index usage comments
COMMENT ON INDEX idx_senaite_samples_client_status IS 'Optimizes client sample status queries';
COMMENT ON INDEX idx_senaite_analyses_sample_status IS 'Optimizes sample analysis status queries';
COMMENT ON INDEX idx_senaite_audit_log_user_occurred IS 'Optimizes user activity audit queries';

-- View comments
COMMENT ON VIEW v_senaite_samples_summary IS 'Comprehensive sample overview with analysis counts';
COMMENT ON VIEW v_senaite_analysis_workload IS 'Analyst workload and performance metrics';
COMMENT ON VIEW v_senaite_client_activity IS 'Client activity and engagement metrics';