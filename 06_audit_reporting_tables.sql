-- =====================================================
-- SENAITE LIMS Database Schema - Audit Trail and Reporting
-- =====================================================
-- Audit trails, logging, reports, and compliance tracking

-- =====================================================
-- AUDIT TRAIL SYSTEM
-- =====================================================

-- Audit event types
CREATE TABLE senaite_audit_event_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(100), -- security, data_change, system, compliance
    severity VARCHAR(50) DEFAULT 'info', -- debug, info, warning, error, critical
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Main audit log table
CREATE TABLE senaite_audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type_id UUID NOT NULL REFERENCES senaite_audit_event_types(id),
    
    -- Event details
    event_name VARCHAR(255) NOT NULL,
    event_description TEXT,
    event_category VARCHAR(100),
    severity VARCHAR(50) DEFAULT 'info',
    
    -- User and session information
    user_id UUID REFERENCES senaite_users(id),
    username VARCHAR(255),
    session_id VARCHAR(255),
    
    -- System information
    ip_address INET,
    user_agent TEXT,
    hostname VARCHAR(255),
    
    -- Object information
    object_type VARCHAR(100), -- 'sample', 'analysis', 'user', etc.
    object_id UUID,
    object_name VARCHAR(255),
    
    -- Change details
    action VARCHAR(100), -- create, update, delete, login, logout, etc.
    old_values JSONB,
    new_values JSONB,
    changed_fields TEXT[],
    
    -- Additional context
    context_data JSONB DEFAULT '{}'::jsonb,
    
    -- Timestamp
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Compliance flags
    is_regulatory BOOLEAN DEFAULT false,
    retention_period_years INTEGER DEFAULT 7
);

-- Data change history (detailed field-level tracking)
CREATE TABLE senaite_data_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    audit_log_id UUID NOT NULL REFERENCES senaite_audit_log(id) ON DELETE CASCADE,
    
    -- Object details
    object_type VARCHAR(100) NOT NULL,
    object_id UUID NOT NULL,
    
    -- Field change details
    field_name VARCHAR(255) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    data_type VARCHAR(50), -- string, number, boolean, date, json
    
    -- Change metadata
    change_type VARCHAR(50), -- insert, update, delete
    change_reason TEXT,
    
    -- User information
    changed_by UUID REFERENCES senaite_users(id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Version control
    version_number INTEGER DEFAULT 1,
    is_current BOOLEAN DEFAULT true
);

-- =====================================================
-- SYSTEM LOGGING
-- =====================================================

-- System event types
CREATE TABLE senaite_system_event_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(100), -- application, database, security, performance
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- System logs
CREATE TABLE senaite_system_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type_id UUID NOT NULL REFERENCES senaite_system_event_types(id),
    
    -- Log details
    level VARCHAR(20) NOT NULL, -- DEBUG, INFO, WARNING, ERROR, CRITICAL
    message TEXT NOT NULL,
    logger_name VARCHAR(255),
    module_name VARCHAR(255),
    function_name VARCHAR(255),
    line_number INTEGER,
    
    -- System information
    hostname VARCHAR(255),
    process_id INTEGER,
    thread_id VARCHAR(50),
    
    -- Error details (if applicable)
    exception_type VARCHAR(255),
    exception_message TEXT,
    stack_trace TEXT,
    
    -- Additional context
    context_data JSONB DEFAULT '{}'::jsonb,
    
    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Retention
    retention_days INTEGER DEFAULT 90
);

-- =====================================================
-- REPORTING SYSTEM
-- =====================================================

-- Report categories
CREATE TABLE senaite_report_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES senaite_report_categories(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Report templates
CREATE TABLE senaite_report_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES senaite_report_categories(id),
    
    -- Template details
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    version VARCHAR(20) DEFAULT '1.0',
    
    -- Template content
    template_content TEXT, -- HTML/template content
    stylesheet TEXT, -- CSS styles
    header_content TEXT,
    footer_content TEXT,
    
    -- Configuration
    parameters JSONB DEFAULT '{}'::jsonb,
    default_format VARCHAR(50) DEFAULT 'pdf', -- pdf, html, excel, csv
    
    -- Permissions
    allowed_roles UUID[],
    
    -- Status
    status VARCHAR(50) DEFAULT 'draft', -- draft, active, retired
    
    -- Tracking
    created_by UUID REFERENCES senaite_users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Generated reports
CREATE TABLE senaite_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_id UUID NOT NULL REFERENCES senaite_report_templates(id),
    
    -- Report details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Generation details
    generated_by UUID NOT NULL REFERENCES senaite_users(id),
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Parameters used
    parameters JSONB DEFAULT '{}'::jsonb,
    
    -- Output details
    format VARCHAR(50) NOT NULL, -- pdf, html, excel, csv
    file_path TEXT,
    file_size INTEGER,
    
    -- Status
    status VARCHAR(50) DEFAULT 'generating', -- generating, completed, failed
    
    -- Related objects
    related_object_type VARCHAR(100),
    related_object_ids UUID[],
    
    -- Sharing and delivery
    shared_with UUID[], -- Array of user IDs
    email_recipients TEXT[],
    
    -- Retention
    expires_at TIMESTAMP WITH TIME ZONE,
    
    -- Error handling
    error_message TEXT,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Report access log
CREATE TABLE senaite_report_access_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_id UUID NOT NULL REFERENCES senaite_reports(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES senaite_users(id),
    
    -- Access details
    access_type VARCHAR(50) NOT NULL, -- view, download, print, share
    ip_address INET,
    user_agent TEXT,
    
    -- Timestamp
    accessed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- COMPLIANCE AND REGULATORY
-- =====================================================

-- Regulatory frameworks
CREATE TABLE senaite_regulatory_frameworks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    version VARCHAR(50),
    
    -- Framework details
    issuing_body VARCHAR(255),
    effective_date DATE,
    
    -- Requirements
    requirements JSONB DEFAULT '{}'::jsonb,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Compliance records
CREATE TABLE senaite_compliance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    framework_id UUID NOT NULL REFERENCES senaite_regulatory_frameworks(id),
    
    -- Compliance details
    requirement_id VARCHAR(255) NOT NULL,
    requirement_description TEXT,
    
    -- Object being assessed
    object_type VARCHAR(100) NOT NULL,
    object_id UUID NOT NULL,
    
    -- Assessment
    compliance_status VARCHAR(50) NOT NULL, -- compliant, non_compliant, partially_compliant, not_applicable
    assessment_date DATE NOT NULL,
    assessed_by UUID NOT NULL REFERENCES senaite_users(id),
    
    -- Details
    evidence TEXT,
    corrective_actions TEXT,
    
    -- Follow-up
    next_assessment_date DATE,
    
    -- Documentation
    supporting_documents TEXT[],
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- DOCUMENT MANAGEMENT
-- =====================================================

-- Document types
CREATE TABLE senaite_document_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(100), -- sop, form, certificate, report, etc.
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Document repository
CREATE TABLE senaite_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_type_id UUID NOT NULL REFERENCES senaite_document_types(id),
    
    -- Document details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    document_number VARCHAR(255),
    version VARCHAR(50) DEFAULT '1.0',
    
    -- File information
    filename VARCHAR(255),
    file_path TEXT,
    file_size INTEGER,
    mime_type VARCHAR(100),
    checksum VARCHAR(255),
    
    -- Metadata
    author VARCHAR(255),
    keywords TEXT[],
    language VARCHAR(10) DEFAULT 'en',
    
    -- Status
    status VARCHAR(50) DEFAULT 'draft', -- draft, review, approved, archived
    
    -- Approval workflow
    approved_by UUID REFERENCES senaite_users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    
    -- Relationships
    related_object_type VARCHAR(100),
    related_object_id UUID,
    parent_document_id UUID REFERENCES senaite_documents(id),
    
    -- Dates
    effective_date DATE,
    expiry_date DATE,
    
    -- Access control
    access_level VARCHAR(50) DEFAULT 'public', -- public, restricted, confidential
    allowed_roles UUID[],
    
    -- Tracking
    created_by UUID REFERENCES senaite_users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Document access log
CREATE TABLE senaite_document_access_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES senaite_documents(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES senaite_users(id),
    
    -- Access details
    access_type VARCHAR(50) NOT NULL, -- view, download, print, edit
    ip_address INET,
    user_agent TEXT,
    
    -- Timestamp
    accessed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PERFORMANCE MONITORING
-- =====================================================

-- Performance metrics
CREATE TABLE senaite_performance_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Metric details
    metric_name VARCHAR(255) NOT NULL,
    metric_type VARCHAR(100) NOT NULL, -- counter, gauge, histogram, timer
    category VARCHAR(100), -- database, api, workflow, user_activity
    
    -- Values
    value NUMERIC NOT NULL,
    unit VARCHAR(50),
    
    -- Dimensions
    dimensions JSONB DEFAULT '{}'::jsonb,
    
    -- Timestamp
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Retention
    retention_days INTEGER DEFAULT 30
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Audit log indexes
CREATE INDEX idx_senaite_audit_log_event_type_id ON senaite_audit_log(event_type_id);
CREATE INDEX idx_senaite_audit_log_user_id ON senaite_audit_log(user_id);
CREATE INDEX idx_senaite_audit_log_object_type ON senaite_audit_log(object_type);
CREATE INDEX idx_senaite_audit_log_object_id ON senaite_audit_log(object_id);
CREATE INDEX idx_senaite_audit_log_action ON senaite_audit_log(action);
CREATE INDEX idx_senaite_audit_log_occurred_at ON senaite_audit_log(occurred_at);
CREATE INDEX idx_senaite_audit_log_is_regulatory ON senaite_audit_log(is_regulatory);

-- Data history indexes
CREATE INDEX idx_senaite_data_history_audit_log_id ON senaite_data_history(audit_log_id);
CREATE INDEX idx_senaite_data_history_object_type ON senaite_data_history(object_type);
CREATE INDEX idx_senaite_data_history_object_id ON senaite_data_history(object_id);
CREATE INDEX idx_senaite_data_history_field_name ON senaite_data_history(field_name);
CREATE INDEX idx_senaite_data_history_changed_by ON senaite_data_history(changed_by);
CREATE INDEX idx_senaite_data_history_changed_at ON senaite_data_history(changed_at);

-- System logs indexes
CREATE INDEX idx_senaite_system_logs_event_type_id ON senaite_system_logs(event_type_id);
CREATE INDEX idx_senaite_system_logs_level ON senaite_system_logs(level);
CREATE INDEX idx_senaite_system_logs_created_at ON senaite_system_logs(created_at);
CREATE INDEX idx_senaite_system_logs_hostname ON senaite_system_logs(hostname);

-- Report indexes
CREATE INDEX idx_senaite_reports_template_id ON senaite_reports(template_id);
CREATE INDEX idx_senaite_reports_generated_by ON senaite_reports(generated_by);
CREATE INDEX idx_senaite_reports_generated_at ON senaite_reports(generated_at);
CREATE INDEX idx_senaite_reports_status ON senaite_reports(status);
CREATE INDEX idx_senaite_reports_related_object ON senaite_reports(related_object_type);

-- Compliance indexes
CREATE INDEX idx_senaite_compliance_records_framework_id ON senaite_compliance_records(framework_id);
CREATE INDEX idx_senaite_compliance_records_object_type ON senaite_compliance_records(object_type);
CREATE INDEX idx_senaite_compliance_records_object_id ON senaite_compliance_records(object_id);
CREATE INDEX idx_senaite_compliance_records_compliance_status ON senaite_compliance_records(compliance_status);
CREATE INDEX idx_senaite_compliance_records_assessment_date ON senaite_compliance_records(assessment_date);

-- Document indexes
CREATE INDEX idx_senaite_documents_document_type_id ON senaite_documents(document_type_id);
CREATE INDEX idx_senaite_documents_document_number ON senaite_documents(document_number);
CREATE INDEX idx_senaite_documents_status ON senaite_documents(status);
CREATE INDEX idx_senaite_documents_created_by ON senaite_documents(created_by);
CREATE INDEX idx_senaite_documents_effective_date ON senaite_documents(effective_date);

-- Performance metrics indexes
CREATE INDEX idx_senaite_performance_metrics_metric_name ON senaite_performance_metrics(metric_name);
CREATE INDEX idx_senaite_performance_metrics_metric_type ON senaite_performance_metrics(metric_type);
CREATE INDEX idx_senaite_performance_metrics_category ON senaite_performance_metrics(category);
CREATE INDEX idx_senaite_performance_metrics_recorded_at ON senaite_performance_metrics(recorded_at);

-- =====================================================
-- UPDATE TRIGGERS
-- =====================================================

-- Apply updated_at triggers
CREATE TRIGGER update_senaite_report_templates_updated_at BEFORE UPDATE ON senaite_report_templates 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_reports_updated_at BEFORE UPDATE ON senaite_reports 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_compliance_records_updated_at BEFORE UPDATE ON senaite_compliance_records 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_documents_updated_at BEFORE UPDATE ON senaite_documents 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- DATA RETENTION POLICIES
-- =====================================================

-- Function to clean up old log entries
CREATE OR REPLACE FUNCTION cleanup_old_logs() RETURNS void AS $$
BEGIN
    -- Clean up audit logs older than retention period
    DELETE FROM senaite_audit_log 
    WHERE occurred_at < CURRENT_TIMESTAMP - INTERVAL '1 year' * retention_period_years;
    
    -- Clean up system logs older than retention period
    DELETE FROM senaite_system_logs 
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '1 day' * retention_days;
    
    -- Clean up performance metrics older than retention period
    DELETE FROM senaite_performance_metrics 
    WHERE recorded_at < CURRENT_TIMESTAMP - INTERVAL '1 day' * retention_days;
    
    -- Clean up expired reports
    DELETE FROM senaite_reports 
    WHERE expires_at IS NOT NULL AND expires_at < CURRENT_TIMESTAMP;
    
END;
$$ LANGUAGE plpgsql;