-- =====================================================
-- SENAITE LIMS Database Schema - Initial Data
-- =====================================================
-- Initial configuration data and seed values

-- =====================================================
-- SYSTEM CONFIGURATION
-- =====================================================

-- Laboratory information
INSERT INTO senaite_laboratory (id, name, code, address, phone, email, website, is_active) VALUES
(uuid_generate_v4(), 'SENAITE LIMS Laboratory', 'SENAITE_LAB', '123 Science Way, Research City, RC 12345', '+1-555-123-4567', 'info@senaite-lab.com', 'https://senaite-lab.com', true);

-- Get the laboratory ID for department references
DO $$
DECLARE
    lab_id UUID;
BEGIN
    SELECT id INTO lab_id FROM senaite_laboratory WHERE code = 'SENAITE_LAB';
    
    -- Departments
    INSERT INTO senaite_departments (id, laboratory_id, name, code, description, is_active) VALUES
    (uuid_generate_v4(), lab_id, 'Chemistry', 'CHEM', 'Chemical analysis and testing', true),
    (uuid_generate_v4(), lab_id, 'Microbiology', 'MICRO', 'Microbiological testing and cultures', true),
    (uuid_generate_v4(), lab_id, 'Hematology', 'HEMA', 'Blood and blood component analysis', true),
    (uuid_generate_v4(), lab_id, 'Pathology', 'PATH', 'Histopathology and cytology', true),
    (uuid_generate_v4(), lab_id, 'Quality Control', 'QC', 'Quality control and assurance', true),
    (uuid_generate_v4(), lab_id, 'Sample Management', 'SAMPLE', 'Sample reception and management', true);
END $$;

-- System settings
INSERT INTO senaite_settings (key, value, description, category, is_public) VALUES
('lab_name', '"SENAITE LIMS Laboratory"', 'Laboratory name for reports and displays', 'general', true),
('lab_code', '"SENAITE_LAB"', 'Laboratory code identifier', 'general', true),
('default_currency', '"USD"', 'Default currency for pricing', 'financial', true),
('default_timezone', '"UTC"', 'Default system timezone', 'general', true),
('default_language', '"en"', 'Default system language', 'general', true),
('sample_id_format', '"S{year:4d}{month:02d}{day:02d}{counter:04d}"', 'Sample ID generation format', 'sample', false),
('analysis_id_format', '"A{year:4d}{month:02d}{day:02d}{counter:04d}"', 'Analysis ID generation format', 'analysis', false),
('client_id_format', '"C{counter:06d}"', 'Client ID generation format', 'client', false),
('default_sample_retention_days', '2555', 'Default sample retention period in days (7 years)', 'sample', false),
('enable_audit_trail', 'true', 'Enable comprehensive audit trail', 'security', false),
('session_timeout_minutes', '480', 'User session timeout in minutes (8 hours)', 'security', false),
('password_min_length', '8', 'Minimum password length', 'security', false),
('password_require_uppercase', 'true', 'Require uppercase letters in passwords', 'security', false),
('password_require_lowercase', 'true', 'Require lowercase letters in passwords', 'security', false),
('password_require_numbers', 'true', 'Require numbers in passwords', 'security', false),
('password_require_symbols', 'false', 'Require symbols in passwords', 'security', false),
('max_failed_login_attempts', '5', 'Maximum failed login attempts before lockout', 'security', false),
('account_lockout_duration_minutes', '30', 'Account lockout duration in minutes', 'security', false);

-- =====================================================
-- USER ROLES AND PERMISSIONS
-- =====================================================

-- Default roles
INSERT INTO senaite_roles (id, name, description, permissions) VALUES
(uuid_generate_v4(), 'Administrator', 'Full system administrator with all permissions', '{
    "can_manage_users": true,
    "can_manage_clients": true,
    "can_manage_samples": true,
    "can_manage_analyses": true,
    "can_manage_instruments": true,
    "can_manage_methods": true,
    "can_manage_workflows": true,
    "can_view_reports": true,
    "can_generate_reports": true,
    "can_manage_settings": true,
    "can_view_audit_logs": true,
    "can_manage_departments": true,
    "can_approve_results": true,
    "can_manage_roles": true
}'::jsonb),

(uuid_generate_v4(), 'Laboratory Manager', 'Laboratory manager with operational permissions', '{
    "can_manage_clients": true,
    "can_manage_samples": true,
    "can_manage_analyses": true,
    "can_manage_instruments": true,
    "can_manage_methods": true,
    "can_view_reports": true,
    "can_generate_reports": true,
    "can_approve_results": true,
    "can_manage_departments": true,
    "can_view_audit_logs": true
}'::jsonb),

(uuid_generate_v4(), 'Senior Analyst', 'Senior analyst with result approval permissions', '{
    "can_manage_samples": true,
    "can_manage_analyses": true,
    "can_view_reports": true,
    "can_generate_reports": true,
    "can_approve_results": true,
    "can_manage_instruments": false
}'::jsonb),

(uuid_generate_v4(), 'Analyst', 'Laboratory analyst with testing permissions', '{
    "can_manage_samples": true,
    "can_manage_analyses": true,
    "can_view_reports": true,
    "can_generate_reports": false,
    "can_approve_results": false,
    "can_manage_instruments": false
}'::jsonb),

(uuid_generate_v4(), 'Sample Manager', 'Sample reception and management', '{
    "can_manage_samples": true,
    "can_manage_analyses": false,
    "can_view_reports": true,
    "can_generate_reports": false,
    "can_approve_results": false,
    "can_manage_instruments": false
}'::jsonb),

(uuid_generate_v4(), 'Client', 'Client with limited view permissions', '{
    "can_manage_samples": false,
    "can_manage_analyses": false,
    "can_view_reports": true,
    "can_generate_reports": false,
    "can_approve_results": false,
    "can_manage_instruments": false
}'::jsonb),

(uuid_generate_v4(), 'Quality Control', 'Quality control specialist', '{
    "can_manage_samples": true,
    "can_manage_analyses": true,
    "can_view_reports": true,
    "can_generate_reports": true,
    "can_approve_results": true,
    "can_manage_instruments": true,
    "can_view_audit_logs": true
}'::jsonb);

-- =====================================================
-- SAMPLE TYPES AND CONTAINERS
-- =====================================================

-- Sample types
INSERT INTO senaite_sample_types (id, name, code, description, sample_matrix, preservation_requirements, storage_conditions, retention_period_days, is_active) VALUES
(uuid_generate_v4(), 'Whole Blood', 'WB', 'Whole blood sample', 'Blood', 'EDTA anticoagulant', 'Refrigerated 2-8°C', 30, true),
(uuid_generate_v4(), 'Serum', 'SER', 'Serum sample', 'Blood', 'Allow to clot, then centrifuge', 'Refrigerated 2-8°C', 30, true),
(uuid_generate_v4(), 'Plasma', 'PLA', 'Plasma sample', 'Blood', 'Anticoagulant, centrifuge immediately', 'Frozen -20°C', 180, true),
(uuid_generate_v4(), 'Urine', 'UR', 'Urine sample', 'Urine', 'Refrigerate immediately', 'Refrigerated 2-8°C', 7, true),
(uuid_generate_v4(), 'Stool', 'ST', 'Stool sample', 'Feces', 'Refrigerate immediately', 'Refrigerated 2-8°C', 7, true),
(uuid_generate_v4(), 'Tissue', 'TIS', 'Tissue sample', 'Tissue', 'Formalin fixation', 'Room temperature', 2555, true),
(uuid_generate_v4(), 'Swab', 'SW', 'Swab sample', 'Various', 'Transport medium', 'Room temperature', 7, true),
(uuid_generate_v4(), 'Water', 'H2O', 'Water sample', 'Water', 'Sterile container', 'Refrigerated 2-8°C', 30, true),
(uuid_generate_v4(), 'Soil', 'SOIL', 'Soil sample', 'Soil', 'Dry storage', 'Room temperature', 365, true),
(uuid_generate_v4(), 'Food', 'FOOD', 'Food sample', 'Food', 'Refrigerate immediately', 'Refrigerated 2-8°C', 14, true);

-- Sample containers
INSERT INTO senaite_sample_containers (id, name, code, description, capacity_ml, material, preservation_method, is_active) VALUES
(uuid_generate_v4(), 'EDTA Tube', 'EDTA', 'Lavender top tube with EDTA', 5.0, 'Plastic', 'EDTA anticoagulant', true),
(uuid_generate_v4(), 'Serum Tube', 'SST', 'Gold top serum separator tube', 8.5, 'Glass', 'Clot activator', true),
(uuid_generate_v4(), 'Heparin Tube', 'LH', 'Green top tube with lithium heparin', 4.0, 'Plastic', 'Lithium heparin', true),
(uuid_generate_v4(), 'Citrate Tube', 'CIT', 'Blue top tube with sodium citrate', 2.7, 'Plastic', 'Sodium citrate', true),
(uuid_generate_v4(), 'Fluoride Tube', 'FLU', 'Gray top tube with fluoride', 2.0, 'Plastic', 'Sodium fluoride', true),
(uuid_generate_v4(), 'Urine Container', 'UC', 'Sterile urine collection container', 120.0, 'Plastic', 'Sterile', true),
(uuid_generate_v4(), 'Stool Container', 'SC', 'Stool collection container', 60.0, 'Plastic', 'Preservative-free', true),
(uuid_generate_v4(), 'Swab Transport', 'STM', 'Swab in transport medium', 1.0, 'Plastic', 'Transport medium', true),
(uuid_generate_v4(), 'Sterile Bottle', 'SB', 'Sterile sample bottle', 250.0, 'Glass', 'Sterile', true),
(uuid_generate_v4(), 'Tissue Cassette', 'TC', 'Histology tissue cassette', 10.0, 'Plastic', 'Formalin', true);

-- =====================================================
-- ANALYSIS CATEGORIES AND SERVICES
-- =====================================================

-- Get department IDs
DO $$
DECLARE
    chem_dept_id UUID;
    micro_dept_id UUID;
    hema_dept_id UUID;
    path_dept_id UUID;
BEGIN
    SELECT id INTO chem_dept_id FROM senaite_departments WHERE code = 'CHEM';
    SELECT id INTO micro_dept_id FROM senaite_departments WHERE code = 'MICRO';
    SELECT id INTO hema_dept_id FROM senaite_departments WHERE code = 'HEMA';
    SELECT id INTO path_dept_id FROM senaite_departments WHERE code = 'PATH';
    
    -- Analysis categories
    INSERT INTO senaite_analysis_categories (id, name, code, description, department_id, is_active) VALUES
    (uuid_generate_v4(), 'Clinical Chemistry', 'CLIN_CHEM', 'Clinical chemistry analyses', chem_dept_id, true),
    (uuid_generate_v4(), 'Hematology', 'HEMA', 'Blood cell counts and morphology', hema_dept_id, true),
    (uuid_generate_v4(), 'Microbiology', 'MICRO', 'Bacterial and viral testing', micro_dept_id, true),
    (uuid_generate_v4(), 'Immunology', 'IMMUNO', 'Immune system testing', chem_dept_id, true),
    (uuid_generate_v4(), 'Pathology', 'PATH', 'Tissue examination', path_dept_id, true),
    (uuid_generate_v4(), 'Toxicology', 'TOX', 'Drug and toxin testing', chem_dept_id, true),
    (uuid_generate_v4(), 'Molecular Biology', 'MOLBIO', 'DNA/RNA testing', micro_dept_id, true),
    (uuid_generate_v4(), 'Endocrinology', 'ENDO', 'Hormone testing', chem_dept_id, true);
END $$;

-- Analysis services (sample set)
DO $$
DECLARE
    clin_chem_cat_id UUID;
    hema_cat_id UUID;
    micro_cat_id UUID;
    immuno_cat_id UUID;
BEGIN
    SELECT id INTO clin_chem_cat_id FROM senaite_analysis_categories WHERE code = 'CLIN_CHEM';
    SELECT id INTO hema_cat_id FROM senaite_analysis_categories WHERE code = 'HEMA';
    SELECT id INTO micro_cat_id FROM senaite_analysis_categories WHERE code = 'MICRO';
    SELECT id INTO immuno_cat_id FROM senaite_analysis_categories WHERE code = 'IMMUNO';
    
    -- Clinical Chemistry
    INSERT INTO senaite_analysis_services (id, name, code, description, category_id, method_name, price, unit, turnaround_time_hours, is_active) VALUES
    (uuid_generate_v4(), 'Glucose', 'GLU', 'Blood glucose measurement', clin_chem_cat_id, 'Enzymatic', 15.00, 'mg/dL', 2, true),
    (uuid_generate_v4(), 'Cholesterol Total', 'CHOL', 'Total cholesterol measurement', clin_chem_cat_id, 'Enzymatic', 20.00, 'mg/dL', 2, true),
    (uuid_generate_v4(), 'Triglycerides', 'TRIG', 'Triglyceride measurement', clin_chem_cat_id, 'Enzymatic', 18.00, 'mg/dL', 2, true),
    (uuid_generate_v4(), 'HDL Cholesterol', 'HDL', 'HDL cholesterol measurement', clin_chem_cat_id, 'Direct', 25.00, 'mg/dL', 2, true),
    (uuid_generate_v4(), 'LDL Cholesterol', 'LDL', 'LDL cholesterol measurement', clin_chem_cat_id, 'Calculated', 25.00, 'mg/dL', 2, true),
    (uuid_generate_v4(), 'Creatinine', 'CREA', 'Creatinine measurement', clin_chem_cat_id, 'Jaffe', 15.00, 'mg/dL', 2, true),
    (uuid_generate_v4(), 'Blood Urea Nitrogen', 'BUN', 'BUN measurement', clin_chem_cat_id, 'Enzymatic', 15.00, 'mg/dL', 2, true),
    (uuid_generate_v4(), 'Alanine Aminotransferase', 'ALT', 'ALT enzyme measurement', clin_chem_cat_id, 'Enzymatic', 20.00, 'U/L', 2, true),
    (uuid_generate_v4(), 'Aspartate Aminotransferase', 'AST', 'AST enzyme measurement', clin_chem_cat_id, 'Enzymatic', 20.00, 'U/L', 2, true),
    
    -- Hematology
    (uuid_generate_v4(), 'Complete Blood Count', 'CBC', 'Complete blood count with differential', hema_cat_id, 'Flow Cytometry', 35.00, 'cells/μL', 1, true),
    (uuid_generate_v4(), 'Hemoglobin', 'HGB', 'Hemoglobin measurement', hema_cat_id, 'Spectrophotometry', 12.00, 'g/dL', 1, true),
    (uuid_generate_v4(), 'Hematocrit', 'HCT', 'Hematocrit measurement', hema_cat_id, 'Centrifugation', 10.00, '%', 1, true),
    (uuid_generate_v4(), 'Platelet Count', 'PLT', 'Platelet count', hema_cat_id, 'Flow Cytometry', 15.00, 'cells/μL', 1, true),
    (uuid_generate_v4(), 'White Blood Cell Count', 'WBC', 'White blood cell count', hema_cat_id, 'Flow Cytometry', 15.00, 'cells/μL', 1, true),
    
    -- Microbiology
    (uuid_generate_v4(), 'Bacterial Culture', 'CULT', 'Bacterial culture and identification', micro_cat_id, 'Culture', 45.00, 'CFU/mL', 48, true),
    (uuid_generate_v4(), 'Antibiotic Sensitivity', 'AST_MIC', 'Antibiotic sensitivity testing', micro_cat_id, 'Disk Diffusion', 35.00, 'mm', 24, true),
    (uuid_generate_v4(), 'Gram Stain', 'GRAM', 'Gram stain microscopy', micro_cat_id, 'Microscopy', 15.00, 'visual', 1, true),
    (uuid_generate_v4(), 'Strep A Rapid', 'STREP_A', 'Streptococcus A rapid test', micro_cat_id, 'Immunoassay', 25.00, 'positive/negative', 1, true),
    
    -- Immunology
    (uuid_generate_v4(), 'C-Reactive Protein', 'CRP', 'C-reactive protein', immuno_cat_id, 'Immunoturbidimetry', 20.00, 'mg/L', 2, true),
    (uuid_generate_v4(), 'Rheumatoid Factor', 'RF', 'Rheumatoid factor', immuno_cat_id, 'Immunoturbidimetry', 30.00, 'IU/mL', 2, true),
    (uuid_generate_v4(), 'Hepatitis B Surface Antigen', 'HBsAg', 'Hepatitis B surface antigen', immuno_cat_id, 'ELISA', 40.00, 'positive/negative', 4, true);
END $$;

-- =====================================================
-- INSTRUMENT TYPES AND INSTRUMENTS
-- =====================================================

-- Instrument types
INSERT INTO senaite_instrument_types (id, name, code, description, manufacturer, is_active) VALUES
(uuid_generate_v4(), 'Clinical Chemistry Analyzer', 'CHEM_ANALYZER', 'Automated clinical chemistry analyzer', 'Various', true),
(uuid_generate_v4(), 'Hematology Analyzer', 'HEMA_ANALYZER', 'Automated hematology analyzer', 'Various', true),
(uuid_generate_v4(), 'Microscope', 'MICROSCOPE', 'Light microscope for morphology', 'Various', true),
(uuid_generate_v4(), 'Centrifuge', 'CENTRIFUGE', 'Laboratory centrifuge', 'Various', true),
(uuid_generate_v4(), 'Incubator', 'INCUBATOR', 'Laboratory incubator', 'Various', true),
(uuid_generate_v4(), 'Spectrophotometer', 'SPECTRO', 'UV/Visible spectrophotometer', 'Various', true),
(uuid_generate_v4(), 'PCR Machine', 'PCR', 'Polymerase chain reaction machine', 'Various', true),
(uuid_generate_v4(), 'ELISA Reader', 'ELISA', 'Enzyme-linked immunosorbent assay reader', 'Various', true);

-- Sample instruments
DO $$
DECLARE
    chem_analyzer_type_id UUID;
    hema_analyzer_type_id UUID;
    microscope_type_id UUID;
    centrifuge_type_id UUID;
    chem_dept_id UUID;
    hema_dept_id UUID;
    micro_dept_id UUID;
BEGIN
    SELECT id INTO chem_analyzer_type_id FROM senaite_instrument_types WHERE code = 'CHEM_ANALYZER';
    SELECT id INTO hema_analyzer_type_id FROM senaite_instrument_types WHERE code = 'HEMA_ANALYZER';
    SELECT id INTO microscope_type_id FROM senaite_instrument_types WHERE code = 'MICROSCOPE';
    SELECT id INTO centrifuge_type_id FROM senaite_instrument_types WHERE code = 'CENTRIFUGE';
    SELECT id INTO chem_dept_id FROM senaite_departments WHERE code = 'CHEM';
    SELECT id INTO hema_dept_id FROM senaite_departments WHERE code = 'HEMA';
    SELECT id INTO micro_dept_id FROM senaite_departments WHERE code = 'MICRO';
    
    INSERT INTO senaite_instruments (id, name, code, instrument_type_id, manufacturer, model, serial_number, department_id, status, next_calibration_date, is_active) VALUES
    (uuid_generate_v4(), 'Chemistry Analyzer 1', 'CHEM_001', chem_analyzer_type_id, 'Beckman Coulter', 'AU5800', 'BC12345', chem_dept_id, 'operational', CURRENT_DATE + INTERVAL '30 days', true),
    (uuid_generate_v4(), 'Hematology Analyzer 1', 'HEMA_001', hema_analyzer_type_id, 'Sysmex', 'XN-1000', 'SY67890', hema_dept_id, 'operational', CURRENT_DATE + INTERVAL '30 days', true),
    (uuid_generate_v4(), 'Microscope 1', 'MICRO_001', microscope_type_id, 'Olympus', 'CX23', 'OL11111', micro_dept_id, 'operational', CURRENT_DATE + INTERVAL '90 days', true),
    (uuid_generate_v4(), 'Centrifuge 1', 'CENT_001', centrifuge_type_id, 'Eppendorf', '5804R', 'EP22222', chem_dept_id, 'operational', CURRENT_DATE + INTERVAL '90 days', true);
END $$;

-- =====================================================
-- CLIENT TYPES AND SAMPLE CLIENTS
-- =====================================================

-- Client types
INSERT INTO senaite_client_types (id, name, code, description, is_active) VALUES
(uuid_generate_v4(), 'Hospital', 'HOSP', 'Hospital and medical center clients', true),
(uuid_generate_v4(), 'Clinic', 'CLIN', 'Medical clinic clients', true),
(uuid_generate_v4(), 'Physician Office', 'PHYS', 'Private physician office clients', true),
(uuid_generate_v4(), 'Research Institution', 'RESEARCH', 'Research and academic clients', true),
(uuid_generate_v4(), 'Pharmaceutical', 'PHARMA', 'Pharmaceutical company clients', true),
(uuid_generate_v4(), 'Environmental', 'ENV', 'Environmental testing clients', true),
(uuid_generate_v4(), 'Industrial', 'IND', 'Industrial and manufacturing clients', true),
(uuid_generate_v4(), 'Government', 'GOV', 'Government agency clients', true);

-- Sample clients
DO $$
DECLARE
    hosp_type_id UUID;
    clin_type_id UUID;
    research_type_id UUID;
BEGIN
    SELECT id INTO hosp_type_id FROM senaite_client_types WHERE code = 'HOSP';
    SELECT id INTO clin_type_id FROM senaite_client_types WHERE code = 'CLIN';
    SELECT id INTO research_type_id FROM senaite_client_types WHERE code = 'RESEARCH';
    
    INSERT INTO senaite_clients (id, client_id, name, client_type_id, address, city, state_province, postal_code, country, phone, email, account_status, is_active) VALUES
    (uuid_generate_v4(), 'C000001', 'General Hospital', hosp_type_id, '123 Medical Center Dr', 'Healthcare City', 'HC', '12345', 'USA', '+1-555-123-4567', 'lab@generalhospital.com', 'active', true),
    (uuid_generate_v4(), 'C000002', 'Family Health Clinic', clin_type_id, '456 Wellness Ave', 'Clinic Town', 'CT', '67890', 'USA', '+1-555-234-5678', 'orders@familyhealth.com', 'active', true),
    (uuid_generate_v4(), 'C000003', 'University Research Lab', research_type_id, '789 Research Blvd', 'University City', 'UC', '11111', 'USA', '+1-555-345-6789', 'research@university.edu', 'active', true);
END $$;

-- Contact types
INSERT INTO senaite_contact_types (id, name, code, description, is_active) VALUES
(uuid_generate_v4(), 'Primary Contact', 'PRIMARY', 'Primary contact for the client', true),
(uuid_generate_v4(), 'Billing Contact', 'BILLING', 'Billing and financial contact', true),
(uuid_generate_v4(), 'Technical Contact', 'TECHNICAL', 'Technical and scientific contact', true),
(uuid_generate_v4(), 'Laboratory Manager', 'LAB_MGR', 'Laboratory manager contact', true),
(uuid_generate_v4(), 'Physician', 'PHYSICIAN', 'Ordering physician contact', true);

-- =====================================================
-- WORKFLOW DEFINITIONS
-- =====================================================

-- Workflow types
INSERT INTO senaite_workflow_types (id, name, code, description, is_active) VALUES
(uuid_generate_v4(), 'Sample Workflow', 'SAMPLE', 'Sample processing workflow', true),
(uuid_generate_v4(), 'Analysis Workflow', 'ANALYSIS', 'Analysis execution workflow', true),
(uuid_generate_v4(), 'Instrument Workflow', 'INSTRUMENT', 'Instrument maintenance workflow', true),
(uuid_generate_v4(), 'Quality Control Workflow', 'QC', 'Quality control workflow', true);

-- Sample workflow
DO $$
DECLARE
    sample_workflow_type_id UUID;
    sample_workflow_id UUID;
    received_state_id UUID;
    registered_state_id UUID;
    sampled_state_id UUID;
    analyzed_state_id UUID;
    reported_state_id UUID;
    archived_state_id UUID;
BEGIN
    SELECT id INTO sample_workflow_type_id FROM senaite_workflow_types WHERE code = 'SAMPLE';
    
    -- Create sample workflow
    INSERT INTO senaite_workflows (id, workflow_type_id, name, code, description, initial_state, is_active, is_default) VALUES
    (uuid_generate_v4(), sample_workflow_type_id, 'Standard Sample Workflow', 'STANDARD_SAMPLE', 'Standard sample processing workflow', 'sample_received', true, true)
    RETURNING id INTO sample_workflow_id;
    
    -- Create workflow states
    INSERT INTO senaite_workflow_states (id, workflow_id, name, code, description, is_initial, is_final, display_name, color) VALUES
    (uuid_generate_v4(), sample_workflow_id, 'Sample Received', 'sample_received', 'Sample has been received', true, false, 'Received', 'blue'),
    (uuid_generate_v4(), sample_workflow_id, 'Sample Registered', 'sample_registered', 'Sample has been registered in system', false, false, 'Registered', 'cyan'),
    (uuid_generate_v4(), sample_workflow_id, 'Sample Prepared', 'sample_prepared', 'Sample has been prepared for analysis', false, false, 'Prepared', 'yellow'),
    (uuid_generate_v4(), sample_workflow_id, 'Analysis Complete', 'analysis_complete', 'All analyses have been completed', false, false, 'Analyzed', 'orange'),
    (uuid_generate_v4(), sample_workflow_id, 'Results Reported', 'results_reported', 'Results have been reported', false, false, 'Reported', 'green'),
    (uuid_generate_v4(), sample_workflow_id, 'Sample Archived', 'sample_archived', 'Sample has been archived', false, true, 'Archived', 'gray');
    
    -- Get state IDs for transitions
    SELECT id INTO received_state_id FROM senaite_workflow_states WHERE workflow_id = sample_workflow_id AND code = 'sample_received';
    SELECT id INTO registered_state_id FROM senaite_workflow_states WHERE workflow_id = sample_workflow_id AND code = 'sample_registered';
    SELECT id INTO sampled_state_id FROM senaite_workflow_states WHERE workflow_id = sample_workflow_id AND code = 'sample_prepared';
    SELECT id INTO analyzed_state_id FROM senaite_workflow_states WHERE workflow_id = sample_workflow_id AND code = 'analysis_complete';
    SELECT id INTO reported_state_id FROM senaite_workflow_states WHERE workflow_id = sample_workflow_id AND code = 'results_reported';
    SELECT id INTO archived_state_id FROM senaite_workflow_states WHERE workflow_id = sample_workflow_id AND code = 'sample_archived';
    
    -- Create workflow transitions
    INSERT INTO senaite_workflow_transitions (id, workflow_id, from_state_id, to_state_id, name, code, description, display_name, button_text) VALUES
    (uuid_generate_v4(), sample_workflow_id, received_state_id, registered_state_id, 'Register Sample', 'register', 'Register sample in system', 'Register', 'Register'),
    (uuid_generate_v4(), sample_workflow_id, registered_state_id, sampled_state_id, 'Prepare Sample', 'prepare', 'Prepare sample for analysis', 'Prepare', 'Prepare'),
    (uuid_generate_v4(), sample_workflow_id, sampled_state_id, analyzed_state_id, 'Complete Analysis', 'analyze', 'Complete all analyses', 'Analyze', 'Complete'),
    (uuid_generate_v4(), sample_workflow_id, analyzed_state_id, reported_state_id, 'Report Results', 'report', 'Report analysis results', 'Report', 'Report'),
    (uuid_generate_v4(), sample_workflow_id, reported_state_id, archived_state_id, 'Archive Sample', 'archive', 'Archive completed sample', 'Archive', 'Archive');
END $$;

-- =====================================================
-- AUDIT EVENT TYPES
-- =====================================================

-- Audit event types
INSERT INTO senaite_audit_event_types (id, name, code, description, category, severity, is_active) VALUES
(uuid_generate_v4(), 'User Login', 'USER_LOGIN', 'User successfully logged in', 'security', 'info', true),
(uuid_generate_v4(), 'User Logout', 'USER_LOGOUT', 'User logged out', 'security', 'info', true),
(uuid_generate_v4(), 'Failed Login', 'FAILED_LOGIN', 'Failed login attempt', 'security', 'warning', true),
(uuid_generate_v4(), 'Account Locked', 'ACCOUNT_LOCKED', 'User account locked due to failed attempts', 'security', 'warning', true),
(uuid_generate_v4(), 'Password Changed', 'PASSWORD_CHANGED', 'User password changed', 'security', 'info', true),
(uuid_generate_v4(), 'Sample Created', 'SAMPLE_CREATED', 'New sample created', 'data_change', 'info', true),
(uuid_generate_v4(), 'Sample Updated', 'SAMPLE_UPDATED', 'Sample information updated', 'data_change', 'info', true),
(uuid_generate_v4(), 'Sample Deleted', 'SAMPLE_DELETED', 'Sample deleted', 'data_change', 'warning', true),
(uuid_generate_v4(), 'Analysis Created', 'ANALYSIS_CREATED', 'New analysis created', 'data_change', 'info', true),
(uuid_generate_v4(), 'Analysis Updated', 'ANALYSIS_UPDATED', 'Analysis information updated', 'data_change', 'info', true),
(uuid_generate_v4(), 'Result Entered', 'RESULT_ENTERED', 'Analysis result entered', 'data_change', 'info', true),
(uuid_generate_v4(), 'Result Approved', 'RESULT_APPROVED', 'Analysis result approved', 'data_change', 'info', true),
(uuid_generate_v4(), 'Client Created', 'CLIENT_CREATED', 'New client created', 'data_change', 'info', true),
(uuid_generate_v4(), 'Client Updated', 'CLIENT_UPDATED', 'Client information updated', 'data_change', 'info', true),
(uuid_generate_v4(), 'Report Generated', 'REPORT_GENERATED', 'Report generated', 'system', 'info', true),
(uuid_generate_v4(), 'System Backup', 'SYSTEM_BACKUP', 'System backup completed', 'system', 'info', true),
(uuid_generate_v4(), 'System Error', 'SYSTEM_ERROR', 'System error occurred', 'system', 'error', true);

-- =====================================================
-- NOTIFICATION TYPES
-- =====================================================

-- Notification types
INSERT INTO senaite_notification_types (id, name, code, description, category, is_active) VALUES
(uuid_generate_v4(), 'Sample Received', 'SAMPLE_RECEIVED', 'Notification when sample is received', 'sample', true),
(uuid_generate_v4(), 'Analysis Assigned', 'ANALYSIS_ASSIGNED', 'Notification when analysis is assigned', 'analysis', true),
(uuid_generate_v4(), 'Analysis Completed', 'ANALYSIS_COMPLETED', 'Notification when analysis is completed', 'analysis', true),
(uuid_generate_v4(), 'Results Available', 'RESULTS_AVAILABLE', 'Notification when results are available', 'results', true),
(uuid_generate_v4(), 'Overdue Analysis', 'OVERDUE_ANALYSIS', 'Notification for overdue analysis', 'analysis', true),
(uuid_generate_v4(), 'Instrument Maintenance Due', 'INSTRUMENT_MAINTENANCE', 'Notification for instrument maintenance', 'instrument', true),
(uuid_generate_v4(), 'Calibration Due', 'CALIBRATION_DUE', 'Notification for instrument calibration', 'instrument', true),
(uuid_generate_v4(), 'System Alert', 'SYSTEM_ALERT', 'System alert notification', 'system', true),
(uuid_generate_v4(), 'Quality Control Alert', 'QC_ALERT', 'Quality control alert', 'quality', true);

-- =====================================================
-- TASK TYPES
-- =====================================================

-- Task types
INSERT INTO senaite_task_types (id, name, code, description, category, is_active) VALUES
(uuid_generate_v4(), 'Sample Processing', 'SAMPLE_PROCESS', 'Sample processing task', 'sample', true),
(uuid_generate_v4(), 'Analysis Execution', 'ANALYSIS_EXEC', 'Analysis execution task', 'analysis', true),
(uuid_generate_v4(), 'Result Review', 'RESULT_REVIEW', 'Result review and approval task', 'quality', true),
(uuid_generate_v4(), 'Instrument Maintenance', 'INSTRUMENT_MAINT', 'Instrument maintenance task', 'instrument', true),
(uuid_generate_v4(), 'Calibration', 'CALIBRATION', 'Instrument calibration task', 'instrument', true),
(uuid_generate_v4(), 'Quality Control', 'QC_CHECK', 'Quality control check task', 'quality', true),
(uuid_generate_v4(), 'Report Generation', 'REPORT_GEN', 'Report generation task', 'reporting', true),
(uuid_generate_v4(), 'Client Communication', 'CLIENT_COMM', 'Client communication task', 'communication', true),
(uuid_generate_v4(), 'Training', 'TRAINING', 'Training and education task', 'education', true),
(uuid_generate_v4(), 'Administrative', 'ADMIN', 'Administrative task', 'administration', true);

-- =====================================================
-- SUMMARY
-- =====================================================

-- Summary comment
DO $$
BEGIN
    RAISE NOTICE 'Initial data setup completed successfully!';
    RAISE NOTICE 'Created:';
    RAISE NOTICE '- 1 Laboratory with 6 departments';
    RAISE NOTICE '- 7 User roles with permissions';
    RAISE NOTICE '- 10 Sample types and 10 container types';
    RAISE NOTICE '- 8 Analysis categories and 21 analysis services';
    RAISE NOTICE '- 8 Instrument types and 4 sample instruments';
    RAISE NOTICE '- 8 Client types and 3 sample clients';
    RAISE NOTICE '- 5 Contact types';
    RAISE NOTICE '- 1 Sample workflow with 6 states and 5 transitions';
    RAISE NOTICE '- 17 Audit event types';
    RAISE NOTICE '- 9 Notification types';
    RAISE NOTICE '- 10 Task types';
    RAISE NOTICE '- 15 System configuration settings';
END $$;