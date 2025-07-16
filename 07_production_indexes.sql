-- =====================================================
-- SENAITE LIMS Database Schema - Production Performance Indexes
-- =====================================================
-- Comprehensive indexing strategy for production performance
-- Based on detailed schema analysis and LIMS workflow patterns

-- =====================================================
-- CORE SYSTEM INDEXES
-- =====================================================

-- User Management Indexes
CREATE INDEX IF NOT EXISTS idx_senaite_users_email ON senaite_users(email);
CREATE INDEX IF NOT EXISTS idx_senaite_users_username ON senaite_users(username);
CREATE INDEX IF NOT EXISTS idx_senaite_users_active ON senaite_users(is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_users_created ON senaite_users(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_users_last_login ON senaite_users(last_login);
CREATE INDEX IF NOT EXISTS idx_senaite_users_azure_id ON senaite_users(azure_object_id);
CREATE INDEX IF NOT EXISTS idx_senaite_users_active_dept ON senaite_users(is_active, department);
CREATE INDEX IF NOT EXISTS idx_senaite_users_superuser_active ON senaite_users(is_superuser, is_active);

-- Role Management Indexes
CREATE INDEX IF NOT EXISTS idx_senaite_roles_name ON senaite_roles(name);
CREATE INDEX IF NOT EXISTS idx_senaite_user_roles_user ON senaite_user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_user_roles_role ON senaite_user_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_senaite_user_roles_assigned ON senaite_user_roles(assigned_at);
CREATE INDEX IF NOT EXISTS idx_senaite_user_roles_assigned_by ON senaite_user_roles(assigned_by);

-- Session Management Indexes
CREATE INDEX IF NOT EXISTS idx_senaite_sessions_user ON senaite_user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_sessions_token ON senaite_user_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_senaite_sessions_expires ON senaite_user_sessions(expires_at);
CREATE INDEX IF NOT EXISTS idx_senaite_sessions_active_expires ON senaite_user_sessions(is_active, expires_at);
CREATE INDEX IF NOT EXISTS idx_senaite_sessions_ip ON senaite_user_sessions(ip_address);

-- System Configuration Indexes
CREATE INDEX IF NOT EXISTS idx_senaite_settings_key ON senaite_settings(key);
CREATE INDEX IF NOT EXISTS idx_senaite_settings_category ON senaite_settings(category);
CREATE INDEX IF NOT EXISTS idx_senaite_settings_category_public ON senaite_settings(category, is_public);

-- Laboratory Structure Indexes
CREATE INDEX IF NOT EXISTS idx_senaite_laboratory_code ON senaite_laboratory(code);
CREATE INDEX IF NOT EXISTS idx_senaite_laboratory_active ON senaite_laboratory(is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_laboratory_name ON senaite_laboratory(name);

CREATE INDEX IF NOT EXISTS idx_senaite_departments_lab ON senaite_departments(laboratory_id);
CREATE INDEX IF NOT EXISTS idx_senaite_departments_code ON senaite_departments(code);
CREATE INDEX IF NOT EXISTS idx_senaite_departments_manager ON senaite_departments(manager_id);
CREATE INDEX IF NOT EXISTS idx_senaite_departments_lab_active ON senaite_departments(laboratory_id, is_active);

-- =====================================================
-- SAMPLE MANAGEMENT INDEXES
-- =====================================================

-- Sample Type and Container Indexes
CREATE INDEX IF NOT EXISTS idx_senaite_sample_types_code ON senaite_sample_types(code);
CREATE INDEX IF NOT EXISTS idx_senaite_sample_types_active_matrix ON senaite_sample_types(is_active, sample_matrix);
CREATE INDEX IF NOT EXISTS idx_senaite_sample_containers_code ON senaite_sample_containers(code);
CREATE INDEX IF NOT EXISTS idx_senaite_sample_containers_active ON senaite_sample_containers(is_active);

-- Sample Core Indexes (using verified column names)
CREATE INDEX IF NOT EXISTS idx_senaite_samples_sample_id ON senaite_samples(sample_id);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_client_sample_id ON senaite_samples(client_sample_id);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_client ON senaite_samples(client_id);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_type ON senaite_samples(sample_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_department ON senaite_samples(department_id);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_status ON senaite_samples(status);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_workflow_state ON senaite_samples(workflow_state);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_priority ON senaite_samples(priority);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_created ON senaite_samples(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_received_at ON senaite_samples(received_at);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_received_by ON senaite_samples(received_by);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_collected_at ON senaite_samples(collected_at);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_disposal_date ON senaite_samples(disposal_date);

-- Sample Composite Indexes for Complex Queries
CREATE INDEX IF NOT EXISTS idx_senaite_samples_client_status_created ON senaite_samples(client_id, status, created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_status_priority ON senaite_samples(status, priority);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_client_received ON senaite_samples(client_id, received_at);
CREATE INDEX IF NOT EXISTS idx_senaite_samples_dept_status ON senaite_samples(department_id, status);

-- =====================================================
-- ANALYSIS WORKFLOW INDEXES
-- =====================================================

-- Analysis Categories and Services
CREATE INDEX IF NOT EXISTS idx_senaite_analysis_categories_code ON senaite_analysis_categories(code);
CREATE INDEX IF NOT EXISTS idx_senaite_analysis_categories_dept ON senaite_analysis_categories(department_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analysis_categories_active ON senaite_analysis_categories(is_active);

CREATE INDEX IF NOT EXISTS idx_senaite_analysis_services_code ON senaite_analysis_services(code);
CREATE INDEX IF NOT EXISTS idx_senaite_analysis_services_category ON senaite_analysis_services(category_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analysis_services_active_accredited ON senaite_analysis_services(is_active, accredited);
CREATE INDEX IF NOT EXISTS idx_senaite_analysis_services_turnaround ON senaite_analysis_services(turnaround_time_hours);

-- Analysis Core Indexes
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_analysis_id ON senaite_analyses(analysis_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_sample ON senaite_analyses(sample_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_service ON senaite_analyses(service_id);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_status ON senaite_analyses(status);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_workflow_state ON senaite_analyses(workflow_state);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_assigned_to ON senaite_analyses(assigned_to);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_validated_by ON senaite_analyses(validated_by);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_created ON senaite_analyses(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_assigned_at ON senaite_analyses(assigned_at);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_started_at ON senaite_analyses(started_at);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_completed_at ON senaite_analyses(completed_at);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_validated_at ON senaite_analyses(validated_at);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_qc_status ON senaite_analyses(qc_status);

-- Analysis Composite Indexes for Workload Management
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_status_assigned ON senaite_analyses(status, assigned_to);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_sample_status ON senaite_analyses(sample_id, status);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_assigned_status ON senaite_analyses(assigned_to, status);
CREATE INDEX IF NOT EXISTS idx_senaite_analyses_service_status ON senaite_analyses(service_id, status);

-- Analysis Results Indexes
CREATE INDEX IF NOT EXISTS idx_senaite_results_analysis ON senaite_results(analysis_id);
CREATE INDEX IF NOT EXISTS idx_senaite_results_analyst ON senaite_results(analyst_id);
CREATE INDEX IF NOT EXISTS idx_senaite_results_created ON senaite_results(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_results_approved ON senaite_results(approved_at);

-- =====================================================
-- INSTRUMENT MANAGEMENT INDEXES
-- =====================================================

-- Instrument Types and Core Indexes
CREATE INDEX IF NOT EXISTS idx_senaite_instrument_types_code ON senaite_instrument_types(code);
CREATE INDEX IF NOT EXISTS idx_senaite_instrument_types_manufacturer ON senaite_instrument_types(manufacturer);

CREATE INDEX IF NOT EXISTS idx_senaite_instruments_code ON senaite_instruments(code);
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_type ON senaite_instruments(instrument_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_department ON senaite_instruments(department_id);
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_status ON senaite_instruments(status);
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_responsible ON senaite_instruments(responsible_user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_next_calibration ON senaite_instruments(next_calibration_date);
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_next_maintenance ON senaite_instruments(next_maintenance_date);
CREATE INDEX IF NOT EXISTS idx_senaite_instruments_status_dept ON senaite_instruments(status, department_id);

-- Instrument Calibration and Maintenance
CREATE INDEX IF NOT EXISTS idx_senaite_calibrations_instrument ON senaite_instrument_calibrations(instrument_id);
CREATE INDEX IF NOT EXISTS idx_senaite_calibrations_date ON senaite_instrument_calibrations(calibration_date);
CREATE INDEX IF NOT EXISTS idx_senaite_calibrations_next_date ON senaite_instrument_calibrations(next_calibration_date);
CREATE INDEX IF NOT EXISTS idx_senaite_calibrations_by ON senaite_instrument_calibrations(calibrated_by);
CREATE INDEX IF NOT EXISTS idx_senaite_calibrations_status ON senaite_instrument_calibrations(status);

CREATE INDEX IF NOT EXISTS idx_senaite_maintenance_instrument ON senaite_instrument_maintenance(instrument_id);
CREATE INDEX IF NOT EXISTS idx_senaite_maintenance_date ON senaite_instrument_maintenance(maintenance_date);
CREATE INDEX IF NOT EXISTS idx_senaite_maintenance_next_date ON senaite_instrument_maintenance(next_maintenance_date);
CREATE INDEX IF NOT EXISTS idx_senaite_maintenance_by ON senaite_instrument_maintenance(performed_by);
CREATE INDEX IF NOT EXISTS idx_senaite_maintenance_status ON senaite_instrument_maintenance(status);

-- Method Management
CREATE INDEX IF NOT EXISTS idx_senaite_methods_code ON senaite_methods(code);
CREATE INDEX IF NOT EXISTS idx_senaite_methods_status ON senaite_methods(status);
CREATE INDEX IF NOT EXISTS idx_senaite_methods_status_effective ON senaite_methods(status, effective_date);
CREATE INDEX IF NOT EXISTS idx_senaite_methods_approved_by ON senaite_methods(approved_by);
CREATE INDEX IF NOT EXISTS idx_senaite_methods_expiry ON senaite_methods(expiry_date);
CREATE INDEX IF NOT EXISTS idx_senaite_methods_standard ON senaite_methods(standard_reference);

CREATE INDEX IF NOT EXISTS idx_senaite_service_methods_service ON senaite_service_methods(service_id);
CREATE INDEX IF NOT EXISTS idx_senaite_service_methods_method ON senaite_service_methods(method_id);
CREATE INDEX IF NOT EXISTS idx_senaite_service_methods_primary ON senaite_service_methods(service_id, is_primary);

-- =====================================================
-- CLIENT MANAGEMENT INDEXES
-- =====================================================

-- Client Types and Core Client Indexes
CREATE INDEX IF NOT EXISTS idx_senaite_client_types_code ON senaite_client_types(code);
CREATE INDEX IF NOT EXISTS idx_senaite_client_types_active ON senaite_client_types(is_active);

CREATE INDEX IF NOT EXISTS idx_senaite_clients_client_id ON senaite_clients(client_id);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_name ON senaite_clients(name);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_type ON senaite_clients(client_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_account_status ON senaite_clients(account_status);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_email ON senaite_clients(email);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_tax_id ON senaite_clients(tax_id);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_country ON senaite_clients(country);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_created ON senaite_clients(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_clients_status_type ON senaite_clients(account_status, client_type_id);

-- Contact Management
CREATE INDEX IF NOT EXISTS idx_senaite_contact_types_code ON senaite_contact_types(code);

CREATE INDEX IF NOT EXISTS idx_senaite_contacts_client ON senaite_contacts(client_id);
CREATE INDEX IF NOT EXISTS idx_senaite_contacts_type ON senaite_contacts(contact_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_contacts_email ON senaite_contacts(email);
CREATE INDEX IF NOT EXISTS idx_senaite_contacts_full_name ON senaite_contacts(full_name);
CREATE INDEX IF NOT EXISTS idx_senaite_contacts_phone ON senaite_contacts(phone);
CREATE INDEX IF NOT EXISTS idx_senaite_contacts_client_primary ON senaite_contacts(client_id, is_primary);
CREATE INDEX IF NOT EXISTS idx_senaite_contacts_active_reports ON senaite_contacts(is_active, receives_reports);

-- Pricing and Contracts
CREATE INDEX IF NOT EXISTS idx_senaite_pricing_client ON senaite_client_pricing(client_id);
CREATE INDEX IF NOT EXISTS idx_senaite_pricing_service ON senaite_client_pricing(service_id);
CREATE INDEX IF NOT EXISTS idx_senaite_pricing_effective ON senaite_client_pricing(effective_date);
CREATE INDEX IF NOT EXISTS idx_senaite_pricing_expiry ON senaite_client_pricing(expiry_date);
CREATE INDEX IF NOT EXISTS idx_senaite_pricing_lookup ON senaite_client_pricing(client_id, service_id, effective_date);

CREATE INDEX IF NOT EXISTS idx_senaite_contracts_client ON senaite_service_contracts(client_id);
CREATE INDEX IF NOT EXISTS idx_senaite_contracts_number ON senaite_service_contracts(contract_number);
CREATE INDEX IF NOT EXISTS idx_senaite_contracts_status ON senaite_service_contracts(status);
CREATE INDEX IF NOT EXISTS idx_senaite_contracts_dates ON senaite_service_contracts(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_senaite_contracts_end_date ON senaite_service_contracts(end_date);

CREATE INDEX IF NOT EXISTS idx_senaite_contract_services_contract ON senaite_contract_services(contract_id);
CREATE INDEX IF NOT EXISTS idx_senaite_contract_services_service ON senaite_contract_services(service_id);

-- Sample Points and Geography
CREATE INDEX IF NOT EXISTS idx_senaite_sample_points_client ON senaite_sample_points(client_id);
CREATE INDEX IF NOT EXISTS idx_senaite_sample_points_code ON senaite_sample_points(code);
CREATE INDEX IF NOT EXISTS idx_senaite_sample_points_client_active ON senaite_sample_points(client_id, is_active);
CREATE INDEX IF NOT EXISTS idx_senaite_sample_points_location ON senaite_sample_points(latitude, longitude);

-- Invoice Management
CREATE INDEX IF NOT EXISTS idx_senaite_invoices_number ON senaite_invoices(invoice_number);
CREATE INDEX IF NOT EXISTS idx_senaite_invoices_client ON senaite_invoices(client_id);
CREATE INDEX IF NOT EXISTS idx_senaite_invoices_date ON senaite_invoices(invoice_date);
CREATE INDEX IF NOT EXISTS idx_senaite_invoices_status ON senaite_invoices(status);
CREATE INDEX IF NOT EXISTS idx_senaite_invoices_due_date ON senaite_invoices(due_date);
CREATE INDEX IF NOT EXISTS idx_senaite_invoices_payment_date ON senaite_invoices(payment_date);
CREATE INDEX IF NOT EXISTS idx_senaite_invoices_status_due ON senaite_invoices(status, due_date);

CREATE INDEX IF NOT EXISTS idx_senaite_invoice_items_invoice ON senaite_invoice_items(invoice_id);
CREATE INDEX IF NOT EXISTS idx_senaite_invoice_items_analysis ON senaite_invoice_items(analysis_id);
CREATE INDEX IF NOT EXISTS idx_senaite_invoice_items_service_date ON senaite_invoice_items(service_date);

-- =====================================================
-- WORKFLOW MANAGEMENT INDEXES
-- =====================================================

-- Workflow Core Indexes
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_types_code ON senaite_workflow_types(code);

CREATE INDEX IF NOT EXISTS idx_senaite_workflows_type ON senaite_workflows(workflow_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflows_code ON senaite_workflows(code);
CREATE INDEX IF NOT EXISTS idx_senaite_workflows_active_default ON senaite_workflows(is_active, is_default);

CREATE INDEX IF NOT EXISTS idx_senaite_workflow_states_workflow ON senaite_workflow_states(workflow_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_states_initial ON senaite_workflow_states(workflow_id, is_initial);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_states_final ON senaite_workflow_states(workflow_id, is_final);

CREATE INDEX IF NOT EXISTS idx_senaite_workflow_transitions_workflow ON senaite_workflow_transitions(workflow_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_transitions_from ON senaite_workflow_transitions(from_state_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_transitions_to ON senaite_workflow_transitions(to_state_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_transitions_from_active ON senaite_workflow_transitions(from_state_id, is_active);

-- Workflow Instances and History
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_instances_workflow ON senaite_workflow_instances(workflow_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_instances_object ON senaite_workflow_instances(object_type, object_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_instances_state ON senaite_workflow_instances(current_state_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_instances_started ON senaite_workflow_instances(started_at);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_instances_state_object ON senaite_workflow_instances(current_state_id, object_type);

CREATE INDEX IF NOT EXISTS idx_senaite_workflow_history_instance ON senaite_workflow_history(workflow_instance_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_history_performed_by ON senaite_workflow_history(performed_by);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_history_performed_at ON senaite_workflow_history(performed_at);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_history_to_state ON senaite_workflow_history(to_state_id);
CREATE INDEX IF NOT EXISTS idx_senaite_workflow_history_audit ON senaite_workflow_history(performed_at, action_type);

-- Task Management
CREATE INDEX IF NOT EXISTS idx_senaite_task_types_code ON senaite_task_types(code);
CREATE INDEX IF NOT EXISTS idx_senaite_task_types_category ON senaite_task_types(category);

CREATE INDEX IF NOT EXISTS idx_senaite_tasks_type ON senaite_tasks(task_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_assigned_to ON senaite_tasks(assigned_to);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_assigned_by ON senaite_tasks(assigned_by);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_status ON senaite_tasks(status);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_priority ON senaite_tasks(priority);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_due_date ON senaite_tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_completed_by ON senaite_tasks(completed_by);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_parent ON senaite_tasks(parent_task_id);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_related_object ON senaite_tasks(related_object_type, related_object_id);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_status_priority ON senaite_tasks(status, priority);
CREATE INDEX IF NOT EXISTS idx_senaite_tasks_assigned_status ON senaite_tasks(assigned_to, status);

CREATE INDEX IF NOT EXISTS idx_senaite_task_comments_task ON senaite_task_comments(task_id);
CREATE INDEX IF NOT EXISTS idx_senaite_task_comments_user ON senaite_task_comments(user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_task_comments_created ON senaite_task_comments(created_at);

-- Notification Management
CREATE INDEX IF NOT EXISTS idx_senaite_notification_types_code ON senaite_notification_types(code);
CREATE INDEX IF NOT EXISTS idx_senaite_notification_types_category ON senaite_notification_types(category);

CREATE INDEX IF NOT EXISTS idx_senaite_notifications_type ON senaite_notifications(notification_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_notifications_recipient ON senaite_notifications(recipient_id);
CREATE INDEX IF NOT EXISTS idx_senaite_notifications_status ON senaite_notifications(status);
CREATE INDEX IF NOT EXISTS idx_senaite_notifications_is_read ON senaite_notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_senaite_notifications_created ON senaite_notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_notifications_sent_at ON senaite_notifications(sent_at);
CREATE INDEX IF NOT EXISTS idx_senaite_notifications_recipient_read ON senaite_notifications(recipient_id, is_read);
CREATE INDEX IF NOT EXISTS idx_senaite_notifications_status_delivery ON senaite_notifications(status, delivery_method);

-- Scheduled Events and Calendar
CREATE INDEX IF NOT EXISTS idx_senaite_events_start_time ON senaite_scheduled_events(start_time);
CREATE INDEX IF NOT EXISTS idx_senaite_events_end_time ON senaite_scheduled_events(end_time);
CREATE INDEX IF NOT EXISTS idx_senaite_events_assigned_to ON senaite_scheduled_events(assigned_to);
CREATE INDEX IF NOT EXISTS idx_senaite_events_type ON senaite_scheduled_events(event_type);
CREATE INDEX IF NOT EXISTS idx_senaite_events_status ON senaite_scheduled_events(status);
CREATE INDEX IF NOT EXISTS idx_senaite_events_recurring ON senaite_scheduled_events(is_recurring);
CREATE INDEX IF NOT EXISTS idx_senaite_events_time_range ON senaite_scheduled_events(start_time, end_time);
CREATE INDEX IF NOT EXISTS idx_senaite_events_assigned_status ON senaite_scheduled_events(assigned_to, status);

CREATE INDEX IF NOT EXISTS idx_senaite_event_attendees_event ON senaite_event_attendees(event_id);
CREATE INDEX IF NOT EXISTS idx_senaite_event_attendees_user ON senaite_event_attendees(user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_event_attendees_response ON senaite_event_attendees(response);

-- =====================================================
-- AUDIT AND COMPLIANCE INDEXES
-- =====================================================

-- Audit Event Types and Logs
CREATE INDEX IF NOT EXISTS idx_senaite_audit_event_types_code ON senaite_audit_event_types(code);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_event_types_category ON senaite_audit_event_types(category);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_event_types_severity ON senaite_audit_event_types(severity);

CREATE INDEX IF NOT EXISTS idx_senaite_audit_log_event_type ON senaite_audit_log(event_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_log_user ON senaite_audit_log(user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_log_object ON senaite_audit_log(object_type, object_id);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_log_action ON senaite_audit_log(action);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_log_occurred ON senaite_audit_log(occurred_at);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_log_regulatory ON senaite_audit_log(is_regulatory);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_log_session ON senaite_audit_log(session_id);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_log_ip ON senaite_audit_log(ip_address);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_log_severity_time ON senaite_audit_log(occurred_at, severity);
CREATE INDEX IF NOT EXISTS idx_senaite_audit_log_object_history ON senaite_audit_log(object_type, object_id, occurred_at);

-- Data History Tracking
CREATE INDEX IF NOT EXISTS idx_senaite_data_history_audit ON senaite_data_history(audit_log_id);
CREATE INDEX IF NOT EXISTS idx_senaite_data_history_object ON senaite_data_history(object_type, object_id);
CREATE INDEX IF NOT EXISTS idx_senaite_data_history_field ON senaite_data_history(field_name);
CREATE INDEX IF NOT EXISTS idx_senaite_data_history_changed_by ON senaite_data_history(changed_by);
CREATE INDEX IF NOT EXISTS idx_senaite_data_history_changed_at ON senaite_data_history(changed_at);
CREATE INDEX IF NOT EXISTS idx_senaite_data_history_field_history ON senaite_data_history(object_type, object_id, field_name);
CREATE INDEX IF NOT EXISTS idx_senaite_data_history_current_version ON senaite_data_history(is_current, version_number);

-- System Logging
CREATE INDEX IF NOT EXISTS idx_senaite_system_event_types_code ON senaite_system_event_types(code);
CREATE INDEX IF NOT EXISTS idx_senaite_system_event_types_category ON senaite_system_event_types(category);

CREATE INDEX IF NOT EXISTS idx_senaite_system_logs_event_type ON senaite_system_logs(event_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_system_logs_level ON senaite_system_logs(level);
CREATE INDEX IF NOT EXISTS idx_senaite_system_logs_created ON senaite_system_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_senaite_system_logs_hostname ON senaite_system_logs(hostname);
CREATE INDEX IF NOT EXISTS idx_senaite_system_logs_exception ON senaite_system_logs(exception_type);
CREATE INDEX IF NOT EXISTS idx_senaite_system_logs_level_time ON senaite_system_logs(level, created_at);

-- =====================================================
-- REPORTING AND DOCUMENT MANAGEMENT INDEXES
-- =====================================================

-- Report Categories and Templates
CREATE INDEX IF NOT EXISTS idx_senaite_report_categories_code ON senaite_report_categories(code);
CREATE INDEX IF NOT EXISTS idx_senaite_report_categories_parent ON senaite_report_categories(parent_id);

CREATE INDEX IF NOT EXISTS idx_senaite_report_templates_code ON senaite_report_templates(code);
CREATE INDEX IF NOT EXISTS idx_senaite_report_templates_category ON senaite_report_templates(category_id);
CREATE INDEX IF NOT EXISTS idx_senaite_report_templates_status ON senaite_report_templates(status);
CREATE INDEX IF NOT EXISTS idx_senaite_report_templates_created_by ON senaite_report_templates(created_by);

-- Report Generation and Access
CREATE INDEX IF NOT EXISTS idx_senaite_reports_template ON senaite_reports(template_id);
CREATE INDEX IF NOT EXISTS idx_senaite_reports_generated_by ON senaite_reports(generated_by);
CREATE INDEX IF NOT EXISTS idx_senaite_reports_generated_at ON senaite_reports(generated_at);
CREATE INDEX IF NOT EXISTS idx_senaite_reports_status ON senaite_reports(status);
CREATE INDEX IF NOT EXISTS idx_senaite_reports_related_object ON senaite_reports(related_object_type);
CREATE INDEX IF NOT EXISTS idx_senaite_reports_expires_at ON senaite_reports(expires_at);
CREATE INDEX IF NOT EXISTS idx_senaite_reports_status_generated ON senaite_reports(status, generated_at);

CREATE INDEX IF NOT EXISTS idx_senaite_report_access_report ON senaite_report_access_log(report_id);
CREATE INDEX IF NOT EXISTS idx_senaite_report_access_user ON senaite_report_access_log(user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_report_access_accessed_at ON senaite_report_access_log(accessed_at);

-- Regulatory Compliance
CREATE INDEX IF NOT EXISTS idx_senaite_regulatory_frameworks_code ON senaite_regulatory_frameworks(code);
CREATE INDEX IF NOT EXISTS idx_senaite_regulatory_frameworks_active ON senaite_regulatory_frameworks(is_active);

CREATE INDEX IF NOT EXISTS idx_senaite_compliance_records_framework ON senaite_compliance_records(framework_id);
CREATE INDEX IF NOT EXISTS idx_senaite_compliance_records_object ON senaite_compliance_records(object_type, object_id);
CREATE INDEX IF NOT EXISTS idx_senaite_compliance_records_status ON senaite_compliance_records(compliance_status);
CREATE INDEX IF NOT EXISTS idx_senaite_compliance_records_assessment ON senaite_compliance_records(assessment_date);
CREATE INDEX IF NOT EXISTS idx_senaite_compliance_records_assessed_by ON senaite_compliance_records(assessed_by);
CREATE INDEX IF NOT EXISTS idx_senaite_compliance_records_next_assessment ON senaite_compliance_records(next_assessment_date);
CREATE INDEX IF NOT EXISTS idx_senaite_compliance_records_compliance_tracking ON senaite_compliance_records(object_type, object_id, compliance_status);

-- Document Management
CREATE INDEX IF NOT EXISTS idx_senaite_document_types_code ON senaite_document_types(code);
CREATE INDEX IF NOT EXISTS idx_senaite_document_types_category ON senaite_document_types(category);

CREATE INDEX IF NOT EXISTS idx_senaite_documents_type ON senaite_documents(document_type_id);
CREATE INDEX IF NOT EXISTS idx_senaite_documents_number ON senaite_documents(document_number);
CREATE INDEX IF NOT EXISTS idx_senaite_documents_status ON senaite_documents(status);
CREATE INDEX IF NOT EXISTS idx_senaite_documents_created_by ON senaite_documents(created_by);
CREATE INDEX IF NOT EXISTS idx_senaite_documents_effective_date ON senaite_documents(effective_date);
CREATE INDEX IF NOT EXISTS idx_senaite_documents_expiry_date ON senaite_documents(expiry_date);
CREATE INDEX IF NOT EXISTS idx_senaite_documents_approved_by ON senaite_documents(approved_by);
CREATE INDEX IF NOT EXISTS idx_senaite_documents_parent ON senaite_documents(parent_document_id);
CREATE INDEX IF NOT EXISTS idx_senaite_documents_active_expiry ON senaite_documents(status, expiry_date);

CREATE INDEX IF NOT EXISTS idx_senaite_document_access_document ON senaite_document_access_log(document_id);
CREATE INDEX IF NOT EXISTS idx_senaite_document_access_user ON senaite_document_access_log(user_id);
CREATE INDEX IF NOT EXISTS idx_senaite_document_access_accessed_at ON senaite_document_access_log(accessed_at);

-- Performance Metrics
CREATE INDEX IF NOT EXISTS idx_senaite_performance_metrics_name ON senaite_performance_metrics(metric_name);
CREATE INDEX IF NOT EXISTS idx_senaite_performance_metrics_type ON senaite_performance_metrics(metric_type);
CREATE INDEX IF NOT EXISTS idx_senaite_performance_metrics_category ON senaite_performance_metrics(category);
CREATE INDEX IF NOT EXISTS idx_senaite_performance_metrics_recorded ON senaite_performance_metrics(recorded_at);
CREATE INDEX IF NOT EXISTS idx_senaite_performance_metrics_time_series ON senaite_performance_metrics(metric_name, recorded_at);
CREATE INDEX IF NOT EXISTS idx_senaite_performance_metrics_analysis ON senaite_performance_metrics(category, metric_type);

-- =====================================================
-- UTILITY FUNCTIONS FOR PRODUCTION MONITORING
-- =====================================================

-- Enhanced schema verification function
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
    
    SELECT 'Database User'::TEXT, 'senaite user'::TEXT, 
           COUNT(*)::BIGINT, 
           CASE WHEN COUNT(*) > 0 THEN 'OK' ELSE 'MISSING' END::TEXT
    FROM pg_user 
    WHERE usename = 'senaite'
    
    UNION ALL
    
    SELECT 'Core Tables'::TEXT, 'Essential Tables'::TEXT,
           COUNT(*)::BIGINT,
           CASE WHEN COUNT(*) >= 10 THEN 'OK' ELSE 'INCOMPLETE' END::TEXT
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('senaite_users', 'senaite_samples', 'senaite_analyses', 
                      'senaite_clients', 'senaite_laboratory', 'senaite_departments',
                      'senaite_instruments', 'senaite_audit_log', 'senaite_workflows',
                      'senaite_reports');
END;
$$ LANGUAGE plpgsql;

-- Enhanced table size analysis
CREATE OR REPLACE FUNCTION get_table_sizes() RETURNS TABLE(
    table_name TEXT,
    row_count BIGINT,
    size_pretty TEXT,
    index_size_pretty TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.tablename::TEXT,
        COALESCE(s.n_tup_ins - s.n_tup_del, 0) AS row_count,
        pg_size_pretty(pg_total_relation_size(t.schemaname||'.'||t.tablename)) AS size_pretty,
        pg_size_pretty(pg_indexes_size(t.schemaname||'.'||t.tablename)) AS index_size_pretty
    FROM pg_tables t
    LEFT JOIN pg_stat_user_tables s ON s.relname = t.tablename
    WHERE t.schemaname = 'public' 
    AND t.tablename LIKE 'senaite_%'
    ORDER BY pg_total_relation_size(t.schemaname||'.'||t.tablename) DESC;
END;
$$ LANGUAGE plpgsql;

-- Index usage analysis function
CREATE OR REPLACE FUNCTION get_index_usage() RETURNS TABLE(
    table_name TEXT,
    index_name TEXT,
    index_scans BIGINT,
    index_tup_read BIGINT,
    index_tup_fetch BIGINT,
    usage_ratio NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.relname::TEXT,
        s.indexrelname::TEXT,
        s.idx_scan,
        s.idx_tup_read,
        s.idx_tup_fetch,
        CASE 
            WHEN (s.idx_scan + t.seq_scan) > 0 
            THEN ROUND((s.idx_scan::NUMERIC / (s.idx_scan + t.seq_scan)) * 100, 2)
            ELSE 0
        END as usage_ratio
    FROM pg_stat_user_indexes s
    JOIN pg_stat_user_tables t ON s.relid = t.relid
    WHERE s.relname LIKE 'senaite_%'
    ORDER BY s.idx_scan DESC;
END;
$$ LANGUAGE plpgsql;

-- Performance monitoring function
CREATE OR REPLACE FUNCTION get_query_performance() RETURNS TABLE(
    table_name TEXT,
    seq_scans BIGINT,
    seq_tup_read BIGINT,
    idx_scans BIGINT,
    idx_tup_fetch BIGINT,
    n_tup_ins BIGINT,
    n_tup_upd BIGINT,
    n_tup_del BIGINT,
    index_effectiveness NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.relname::TEXT,
        s.seq_scan,
        s.seq_tup_read,
        s.idx_scan,
        s.idx_tup_fetch,
        s.n_tup_ins,
        s.n_tup_upd,
        s.n_tup_del,
        CASE 
            WHEN (s.seq_scan + s.idx_scan) > 0 
            THEN ROUND((s.idx_scan::NUMERIC / (s.seq_scan + s.idx_scan)) * 100, 2)
            ELSE 0
        END as index_effectiveness
    FROM pg_stat_user_tables s
    WHERE s.relname LIKE 'senaite_%'
    ORDER BY s.seq_scan DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMPLETION AND VERIFICATION
-- =====================================================

DO $$
DECLARE
    table_count INTEGER;
    index_count INTEGER;
    function_count INTEGER;
BEGIN
    -- Count tables
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' AND table_name LIKE 'senaite_%';
    
    -- Count indexes
    SELECT COUNT(*) INTO index_count 
    FROM pg_indexes 
    WHERE schemaname = 'public' AND tablename LIKE 'senaite_%';
    
    -- Count utility functions
    SELECT COUNT(*) INTO function_count
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'public' 
    AND p.proname LIKE '%senaite%';
    
    RAISE NOTICE '=== SENAITE LIMS Production Indexes Created Successfully ===';
    RAISE NOTICE '';
    RAISE NOTICE 'Database Statistics:';
    RAISE NOTICE '  Tables: %', table_count;
    RAISE NOTICE '  Indexes: %', index_count;
    RAISE NOTICE '  Utility Functions: %', function_count;
    RAISE NOTICE '';
    RAISE NOTICE 'Production Monitoring Functions:';
    RAISE NOTICE '  SELECT * FROM verify_senaite_schema();';
    RAISE NOTICE '  SELECT * FROM get_table_sizes();';
    RAISE NOTICE '  SELECT * FROM get_index_usage();';
    RAISE NOTICE '  SELECT * FROM get_query_performance();';
    RAISE NOTICE '';
    RAISE NOTICE 'Index Coverage:';
    RAISE NOTICE '  ✓ Core system operations (users, sessions, settings)';
    RAISE NOTICE '  ✓ Sample management workflow';
    RAISE NOTICE '  ✓ Analysis and result tracking';
    RAISE NOTICE '  ✓ Instrument management and calibration';
    RAISE NOTICE '  ✓ Client and contact management';
    RAISE NOTICE '  ✓ Workflow and task management';
    RAISE NOTICE '  ✓ Audit trail and compliance';
    RAISE NOTICE '  ✓ Reporting and document management';
    RAISE NOTICE '  ✓ Performance monitoring';
    RAISE NOTICE '';
    RAISE NOTICE 'Database is optimized for production LIMS workloads!';
    RAISE NOTICE 'Run verification functions to monitor performance.';
END $$;