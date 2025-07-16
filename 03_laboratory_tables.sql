-- =====================================================
-- SENAITE LIMS Database Schema - Laboratory Tables
-- =====================================================
-- Laboratory management, samples, analyses, and instruments

-- =====================================================
-- SAMPLE MANAGEMENT
-- =====================================================

-- Sample types and categories
CREATE TABLE senaite_sample_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    sample_matrix VARCHAR(100), -- Blood, Urine, Water, etc.
    preservation_requirements TEXT,
    storage_conditions TEXT,
    retention_period_days INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Sample containers and collection methods
CREATE TABLE senaite_sample_containers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    capacity_ml NUMERIC,
    material VARCHAR(100),
    preservation_method VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Main samples table
CREATE TABLE senaite_samples (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sample_id VARCHAR(255) UNIQUE NOT NULL, -- Lab-generated ID
    client_sample_id VARCHAR(255), -- Client-provided ID
    sample_type_id UUID NOT NULL REFERENCES senaite_sample_types(id),
    container_id UUID REFERENCES senaite_sample_containers(id),
    client_id UUID NOT NULL, -- Will reference clients table
    department_id UUID NOT NULL REFERENCES senaite_departments(id),
    
    -- Collection information
    collected_at TIMESTAMP WITH TIME ZONE,
    collected_by VARCHAR(255),
    collection_location TEXT,
    
    -- Reception information
    received_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    received_by UUID REFERENCES senaite_users(id),
    
    -- Sample details
    priority VARCHAR(50) DEFAULT 'normal', -- high, normal, low
    temperature_at_receipt NUMERIC,
    volume_received NUMERIC,
    volume_units VARCHAR(20) DEFAULT 'ml',
    
    -- Status and workflow
    status VARCHAR(50) DEFAULT 'received', -- received, registered, sampled, analyzed, reported, archived
    workflow_state VARCHAR(50) DEFAULT 'sample_received',
    
    -- Additional metadata
    description TEXT,
    comments TEXT,
    storage_location VARCHAR(255),
    disposal_date DATE,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- JSON field for custom properties
    custom_properties JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- ANALYSIS AND TESTING
-- =====================================================

-- Analysis categories (Chemistry, Microbiology, etc.)
CREATE TABLE senaite_analysis_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    department_id UUID REFERENCES senaite_departments(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Analysis services/tests
CREATE TABLE senaite_analysis_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    category_id UUID NOT NULL REFERENCES senaite_analysis_categories(id),
    
    -- Method information
    method_name VARCHAR(255),
    method_description TEXT,
    
    -- Pricing
    price NUMERIC(10,2),
    
    -- Technical specifications
    unit VARCHAR(50),
    detection_limit NUMERIC,
    quantification_limit NUMERIC,
    measurement_uncertainty NUMERIC,
    
    -- Quality control
    duplicate_variance NUMERIC,
    qc_frequency INTEGER, -- Number of samples between QC checks
    
    -- Timing
    turnaround_time_hours INTEGER,
    max_turnaround_time_hours INTEGER,
    
    -- Accreditation
    accredited BOOLEAN DEFAULT false,
    accreditation_body VARCHAR(255),
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Individual analysis requests
CREATE TABLE senaite_analyses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    analysis_id VARCHAR(255) UNIQUE NOT NULL,
    sample_id UUID NOT NULL REFERENCES senaite_samples(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES senaite_analysis_services(id),
    
    -- Assignment
    assigned_to UUID REFERENCES senaite_users(id),
    assigned_at TIMESTAMP WITH TIME ZONE,
    
    -- Analysis execution
    started_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Results
    result_value NUMERIC,
    result_text TEXT,
    result_unit VARCHAR(50),
    result_options TEXT[], -- For multiple choice results
    
    -- Quality indicators
    detection_limit_exceeded BOOLEAN DEFAULT false,
    uncertainty NUMERIC,
    
    -- Status
    status VARCHAR(50) DEFAULT 'registered', -- registered, assigned, in_progress, completed, verified, published
    workflow_state VARCHAR(50) DEFAULT 'analysis_registered',
    
    -- Quality control
    qc_status VARCHAR(50), -- passed, failed, pending
    qc_comments TEXT,
    
    -- Validation
    validated_by UUID REFERENCES senaite_users(id),
    validated_at TIMESTAMP WITH TIME ZONE,
    
    -- Comments and notes
    comments TEXT,
    analyst_comments TEXT,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- JSON field for custom properties
    custom_properties JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- INSTRUMENTS AND EQUIPMENT
-- =====================================================

-- Instrument types and manufacturers
CREATE TABLE senaite_instrument_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    manufacturer VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Laboratory instruments
CREATE TABLE senaite_instruments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    instrument_type_id UUID NOT NULL REFERENCES senaite_instrument_types(id),
    
    -- Equipment details
    manufacturer VARCHAR(255),
    model VARCHAR(255),
    serial_number VARCHAR(255),
    asset_number VARCHAR(255),
    
    -- Location and assignment
    location VARCHAR(255),
    department_id UUID REFERENCES senaite_departments(id),
    responsible_user_id UUID REFERENCES senaite_users(id),
    
    -- Operational status
    status VARCHAR(50) DEFAULT 'operational', -- operational, maintenance, out_of_service, calibration
    
    -- Dates
    purchase_date DATE,
    installation_date DATE,
    last_calibration_date DATE,
    next_calibration_date DATE,
    warranty_expiry_date DATE,
    
    -- Maintenance
    maintenance_frequency_days INTEGER,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    
    -- Documentation
    manual_url TEXT,
    notes TEXT,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Instrument calibration records
CREATE TABLE senaite_instrument_calibrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    instrument_id UUID NOT NULL REFERENCES senaite_instruments(id) ON DELETE CASCADE,
    calibration_date DATE NOT NULL,
    calibrated_by UUID REFERENCES senaite_users(id),
    
    -- Calibration details
    calibration_type VARCHAR(100), -- routine, after_repair, verification
    reference_standard VARCHAR(255),
    calibration_points JSONB, -- Array of calibration points
    
    -- Results
    status VARCHAR(50) DEFAULT 'passed', -- passed, failed, conditional
    tolerance_met BOOLEAN DEFAULT true,
    
    -- Documentation
    certificate_number VARCHAR(255),
    certificate_url TEXT,
    comments TEXT,
    
    -- Next calibration
    next_calibration_date DATE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Instrument maintenance records
CREATE TABLE senaite_instrument_maintenance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    instrument_id UUID NOT NULL REFERENCES senaite_instruments(id) ON DELETE CASCADE,
    maintenance_date DATE NOT NULL,
    performed_by UUID REFERENCES senaite_users(id),
    
    -- Maintenance details
    maintenance_type VARCHAR(100), -- preventive, corrective, emergency
    description TEXT,
    parts_replaced TEXT[],
    
    -- Status
    status VARCHAR(50) DEFAULT 'completed', -- scheduled, in_progress, completed, cancelled
    
    -- Costs
    cost NUMERIC(10,2),
    vendor VARCHAR(255),
    
    -- Documentation
    work_order_number VARCHAR(255),
    invoice_number VARCHAR(255),
    
    -- Next maintenance
    next_maintenance_date DATE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- METHODS AND PROCEDURES
-- =====================================================

-- Analytical methods
CREATE TABLE senaite_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    version VARCHAR(50),
    description TEXT,
    
    -- Method classification
    method_type VARCHAR(100), -- Standard, Custom, Modified
    standard_reference VARCHAR(255), -- ISO, ASTM, etc.
    
    -- Technical details
    procedure TEXT,
    sample_preparation TEXT,
    equipment_required TEXT[],
    reagents_required TEXT[],
    
    -- Quality parameters
    precision NUMERIC,
    accuracy NUMERIC,
    detection_limit NUMERIC,
    quantification_limit NUMERIC,
    
    -- Documentation
    sop_document_url TEXT,
    validation_report_url TEXT,
    
    -- Status
    status VARCHAR(50) DEFAULT 'draft', -- draft, validated, active, retired
    
    -- Approval
    approved_by UUID REFERENCES senaite_users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    
    -- Dates
    effective_date DATE,
    review_date DATE,
    expiry_date DATE,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Link analysis services to methods
CREATE TABLE senaite_service_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID NOT NULL REFERENCES senaite_analysis_services(id) ON DELETE CASCADE,
    method_id UUID NOT NULL REFERENCES senaite_methods(id) ON DELETE CASCADE,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(service_id, method_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Sample-related indexes
CREATE INDEX idx_senaite_samples_sample_id ON senaite_samples(sample_id);
CREATE INDEX idx_senaite_samples_client_sample_id ON senaite_samples(client_sample_id);
CREATE INDEX idx_senaite_samples_sample_type_id ON senaite_samples(sample_type_id);
CREATE INDEX idx_senaite_samples_client_id ON senaite_samples(client_id);
CREATE INDEX idx_senaite_samples_status ON senaite_samples(status);
CREATE INDEX idx_senaite_samples_received_at ON senaite_samples(received_at);
CREATE INDEX idx_senaite_samples_workflow_state ON senaite_samples(workflow_state);

-- Analysis-related indexes
CREATE INDEX idx_senaite_analyses_analysis_id ON senaite_analyses(analysis_id);
CREATE INDEX idx_senaite_analyses_sample_id ON senaite_analyses(sample_id);
CREATE INDEX idx_senaite_analyses_service_id ON senaite_analyses(service_id);
CREATE INDEX idx_senaite_analyses_assigned_to ON senaite_analyses(assigned_to);
CREATE INDEX idx_senaite_analyses_status ON senaite_analyses(status);
CREATE INDEX idx_senaite_analyses_workflow_state ON senaite_analyses(workflow_state);

-- Instrument-related indexes
CREATE INDEX idx_senaite_instruments_code ON senaite_instruments(code);
CREATE INDEX idx_senaite_instruments_type_id ON senaite_instruments(instrument_type_id);
CREATE INDEX idx_senaite_instruments_status ON senaite_instruments(status);
CREATE INDEX idx_senaite_instruments_department_id ON senaite_instruments(department_id);

-- Method-related indexes
CREATE INDEX idx_senaite_methods_code ON senaite_methods(code);
CREATE INDEX idx_senaite_methods_status ON senaite_methods(status);
CREATE INDEX idx_senaite_service_methods_service_id ON senaite_service_methods(service_id);
CREATE INDEX idx_senaite_service_methods_method_id ON senaite_service_methods(method_id);

-- =====================================================
-- UPDATE TRIGGERS
-- =====================================================

-- Apply updated_at triggers
CREATE TRIGGER update_senaite_sample_types_updated_at BEFORE UPDATE ON senaite_sample_types 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_samples_updated_at BEFORE UPDATE ON senaite_samples 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_analysis_services_updated_at BEFORE UPDATE ON senaite_analysis_services 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_analyses_updated_at BEFORE UPDATE ON senaite_analyses 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_instruments_updated_at BEFORE UPDATE ON senaite_instruments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_methods_updated_at BEFORE UPDATE ON senaite_methods 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();