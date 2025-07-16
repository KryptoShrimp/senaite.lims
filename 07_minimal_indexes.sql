-- =====================================================
-- SENAITE LIMS - MINIMAL PERFORMANCE INDEXES
-- =====================================================
-- Only essential indexes with verified column names

-- User table indexes
CREATE INDEX IF NOT EXISTS idx_senaite_users_email ON senaite_users(email);
CREATE INDEX IF NOT EXISTS idx_senaite_users_active ON senaite_users(is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_users_created ON senaite_users(created_at);

-- User roles indexes
CREATE INDEX IF NOT EXISTS idx_senaite_user_roles_user ON senaite_user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_user_roles_role ON senaite_user_roles(role_id);

-- Sample indexes (only verified columns)
CREATE INDEX IF NOT EXISTS idx_senaite_samples_client ON senaite_samples(client_id);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_type ON senaite_samples(sample_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_status ON senaite_samples(status);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_created ON senaite_samples(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_received_at ON senaite_samples(received_at);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_priority ON senaite_samples(priority);

-- Analysis indexes
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_sample ON senaite_analyses(sample_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_service ON senaite_analyses(analysis_service_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_status ON senaite_analyses(status);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_created ON senaite_analyses(created_at);

-- Client indexes
CREATE INDEX IF NOT EXISTS idx_senaite_clients_active ON senaite_clients(is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_created ON senaite_clients(created_at);

-- Department indexes
CREATE INDEX IF NOT EXISTS idx_senaite_departments_active ON senaite_departments(is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_departments_lab ON senaite_departments(laboratory_id);

-- Settings indexes
CREATE INDEX IF NOT EXISTS idx_senaite_settings_category ON senaite_settings(category);

-- Laboratory indexes
CREATE INDEX IF NOT EXISTS idx_senaite_laboratory_active ON senaite_laboratory(is_active);

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

-- Simple verification function
CREATE OR REPLACE FUNCTION verify_senaite_schema() RETURNS TABLE(
    category TEXT,
    count_value BIGINT,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 'Tables'::TEXT, 
           COUNT(*)::BIGINT, 
           'OK'::TEXT
    FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name LIKE 'senaite_%'
    
    UNION ALL
    
    SELECT 'Indexes'::TEXT, 
           COUNT(*)::BIGINT, 
           'OK'::TEXT
    FROM pg_indexes 
    WHERE schemaname = 'public' AND tablename LIKE 'senaite_%'
    
    UNION ALL
    
    SELECT 'Senaite User'::TEXT, 
           COUNT(*)::BIGINT, 
           CASE WHEN COUNT(*) > 0 THEN 'OK' ELSE 'MISSING' END::TEXT
    FROM pg_user 
    WHERE usename = 'senaite';
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
    
    RAISE NOTICE '=== SENAITE LIMS Minimal Indexes Created ===';
    RAISE NOTICE 'Tables: %', table_count;
    RAISE NOTICE 'Indexes: %', index_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Run: SELECT * FROM verify_senaite_schema();';
    RAISE NOTICE '';
    RAISE NOTICE 'Database ready for development!';
END $$;