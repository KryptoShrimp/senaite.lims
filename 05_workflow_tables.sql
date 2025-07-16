-- =====================================================
-- SENAITE LIMS Database Schema - Workflow Tables
-- =====================================================
-- Workflow states, transitions, and process management

-- =====================================================
-- WORKFLOW DEFINITIONS
-- =====================================================

-- Workflow types (sample, analysis, instrument, etc.)
CREATE TABLE senaite_workflow_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Workflow definitions
CREATE TABLE senaite_workflows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_type_id UUID NOT NULL REFERENCES senaite_workflow_types(id),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    version VARCHAR(20) DEFAULT '1.0',
    
    -- Configuration
    initial_state VARCHAR(100) NOT NULL,
    configuration JSONB DEFAULT '{}'::jsonb,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Workflow states
CREATE TABLE senaite_workflow_states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES senaite_workflows(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- State properties
    is_initial BOOLEAN DEFAULT false,
    is_final BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    
    -- Display properties
    display_name VARCHAR(255),
    color VARCHAR(20), -- For UI display
    icon VARCHAR(100),
    
    -- Permissions and actions
    allowed_roles UUID[], -- Array of role IDs
    required_permissions TEXT[],
    
    -- Configuration
    configuration JSONB DEFAULT '{}'::jsonb,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(workflow_id, code)
);

-- Workflow transitions
CREATE TABLE senaite_workflow_transitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES senaite_workflows(id) ON DELETE CASCADE,
    from_state_id UUID NOT NULL REFERENCES senaite_workflow_states(id),
    to_state_id UUID NOT NULL REFERENCES senaite_workflow_states(id),
    
    -- Transition properties
    name VARCHAR(255) NOT NULL,
    code VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- Conditions
    condition_expression TEXT, -- Optional condition for transition
    required_fields TEXT[], -- Fields that must be filled
    
    -- Permissions
    allowed_roles UUID[], -- Array of role IDs
    required_permissions TEXT[],
    
    -- Actions
    pre_actions TEXT[], -- Actions to execute before transition
    post_actions TEXT[], -- Actions to execute after transition
    
    -- Display properties
    display_name VARCHAR(255),
    button_text VARCHAR(100),
    button_color VARCHAR(20),
    
    -- Configuration
    configuration JSONB DEFAULT '{}'::jsonb,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(workflow_id, code)
);

-- =====================================================
-- WORKFLOW INSTANCES
-- =====================================================

-- Workflow instances (tracks workflow state for each object)
CREATE TABLE senaite_workflow_instances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES senaite_workflows(id),
    object_type VARCHAR(100) NOT NULL, -- 'sample', 'analysis', 'instrument', etc.
    object_id UUID NOT NULL,
    
    -- Current state
    current_state_id UUID NOT NULL REFERENCES senaite_workflow_states(id),
    current_state_code VARCHAR(100) NOT NULL,
    
    -- Tracking
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Additional data
    context_data JSONB DEFAULT '{}'::jsonb,
    
    UNIQUE(object_type, object_id, workflow_id)
);

-- Workflow history (tracks all state changes)
CREATE TABLE senaite_workflow_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_instance_id UUID NOT NULL REFERENCES senaite_workflow_instances(id) ON DELETE CASCADE,
    transition_id UUID REFERENCES senaite_workflow_transitions(id),
    
    -- State change details
    from_state_id UUID REFERENCES senaite_workflow_states(id),
    to_state_id UUID NOT NULL REFERENCES senaite_workflow_states(id),
    from_state_code VARCHAR(100),
    to_state_code VARCHAR(100) NOT NULL,
    
    -- Action details
    action_type VARCHAR(100), -- 'transition', 'assignment', 'comment', etc.
    action_name VARCHAR(255),
    
    -- User information
    performed_by UUID REFERENCES senaite_users(id),
    performed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Additional information
    comments TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- TASK MANAGEMENT
-- =====================================================

-- Task types and categories
CREATE TABLE senaite_task_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tasks and assignments
CREATE TABLE senaite_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_type_id UUID NOT NULL REFERENCES senaite_task_types(id),
    
    -- Task details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    priority VARCHAR(50) DEFAULT 'medium', -- low, medium, high, critical
    
    -- Assignment
    assigned_to UUID REFERENCES senaite_users(id),
    assigned_by UUID REFERENCES senaite_users(id),
    assigned_at TIMESTAMP WITH TIME ZONE,
    
    -- Timing
    due_date TIMESTAMP WITH TIME ZONE,
    estimated_duration INTEGER, -- in minutes
    actual_duration INTEGER, -- in minutes
    
    -- Status
    status VARCHAR(50) DEFAULT 'pending', -- pending, in_progress, completed, cancelled
    
    -- Relationships
    related_object_type VARCHAR(100), -- 'sample', 'analysis', 'instrument', etc.
    related_object_id UUID,
    parent_task_id UUID REFERENCES senaite_tasks(id),
    
    -- Completion
    completed_at TIMESTAMP WITH TIME ZONE,
    completed_by UUID REFERENCES senaite_users(id),
    completion_notes TEXT,
    
    -- Additional information
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Task comments and updates
CREATE TABLE senaite_task_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES senaite_tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES senaite_users(id),
    
    -- Comment details
    comment TEXT NOT NULL,
    comment_type VARCHAR(50) DEFAULT 'comment', -- comment, status_update, assignment
    
    -- Attachments
    attachments JSONB DEFAULT '[]'::jsonb,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- NOTIFICATIONS AND ALERTS
-- =====================================================

-- Notification types
CREATE TABLE senaite_notification_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    category VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Notifications
CREATE TABLE senaite_notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_type_id UUID NOT NULL REFERENCES senaite_notification_types(id),
    
    -- Recipient
    recipient_id UUID NOT NULL REFERENCES senaite_users(id),
    
    -- Message details
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    priority VARCHAR(50) DEFAULT 'normal', -- low, normal, high, urgent
    
    -- Delivery
    delivery_method VARCHAR(50) DEFAULT 'in_app', -- in_app, email, sms
    sent_at TIMESTAMP WITH TIME ZONE,
    
    -- Status
    status VARCHAR(50) DEFAULT 'pending', -- pending, sent, delivered, failed
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    
    -- Relationships
    related_object_type VARCHAR(100),
    related_object_id UUID,
    
    -- Additional data
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- SCHEDULING AND CALENDAR
-- =====================================================

-- Scheduled events (maintenance, calibration, etc.)
CREATE TABLE senaite_scheduled_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Event details
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_type VARCHAR(100) NOT NULL, -- maintenance, calibration, training, etc.
    
    -- Timing
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    all_day BOOLEAN DEFAULT false,
    
    -- Recurrence
    is_recurring BOOLEAN DEFAULT false,
    recurrence_pattern VARCHAR(100), -- daily, weekly, monthly, yearly
    recurrence_interval INTEGER, -- every N days/weeks/months
    recurrence_end_date DATE,
    
    -- Assignment
    assigned_to UUID REFERENCES senaite_users(id),
    created_by UUID REFERENCES senaite_users(id),
    
    -- Relationships
    related_object_type VARCHAR(100),
    related_object_id UUID,
    
    -- Status
    status VARCHAR(50) DEFAULT 'scheduled', -- scheduled, in_progress, completed, cancelled
    
    -- Additional information
    location VARCHAR(255),
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Event attendees
CREATE TABLE senaite_event_attendees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES senaite_scheduled_events(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES senaite_users(id),
    
    -- Attendance details
    response VARCHAR(50) DEFAULT 'pending', -- pending, accepted, declined, tentative
    response_at TIMESTAMP WITH TIME ZONE,
    
    -- Actual attendance
    attended BOOLEAN,
    check_in_time TIMESTAMP WITH TIME ZONE,
    check_out_time TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(event_id, user_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Workflow-related indexes
CREATE INDEX idx_senaite_workflows_workflow_type_id ON senaite_workflows(workflow_type_id);
CREATE INDEX idx_senaite_workflows_code ON senaite_workflows(code);
CREATE INDEX idx_senaite_workflow_states_workflow_id ON senaite_workflow_states(workflow_id);
CREATE INDEX idx_senaite_workflow_transitions_workflow_id ON senaite_workflow_transitions(workflow_id);
CREATE INDEX idx_senaite_workflow_transitions_from_state_id ON senaite_workflow_transitions(from_state_id);
CREATE INDEX idx_senaite_workflow_transitions_to_state_id ON senaite_workflow_transitions(to_state_id);

-- Workflow instance indexes
CREATE INDEX idx_senaite_workflow_instances_workflow_id ON senaite_workflow_instances(workflow_id);
CREATE INDEX idx_senaite_workflow_instances_object_type ON senaite_workflow_instances(object_type);
CREATE INDEX idx_senaite_workflow_instances_object_id ON senaite_workflow_instances(object_id);
CREATE INDEX idx_senaite_workflow_instances_current_state_id ON senaite_workflow_instances(current_state_id);

-- Workflow history indexes
CREATE INDEX idx_senaite_workflow_history_workflow_instance_id ON senaite_workflow_history(workflow_instance_id);
CREATE INDEX idx_senaite_workflow_history_performed_by ON senaite_workflow_history(performed_by);
CREATE INDEX idx_senaite_workflow_history_performed_at ON senaite_workflow_history(performed_at);

-- Task-related indexes
CREATE INDEX idx_senaite_tasks_task_type_id ON senaite_tasks(task_type_id);
CREATE INDEX idx_senaite_tasks_assigned_to ON senaite_tasks(assigned_to);
CREATE INDEX idx_senaite_tasks_status ON senaite_tasks(status);
CREATE INDEX idx_senaite_tasks_due_date ON senaite_tasks(due_date);
CREATE INDEX idx_senaite_tasks_related_object ON senaite_tasks(related_object_type, related_object_id);

-- Notification indexes
CREATE INDEX idx_senaite_notifications_recipient_id ON senaite_notifications(recipient_id);
CREATE INDEX idx_senaite_notifications_status ON senaite_notifications(status);
CREATE INDEX idx_senaite_notifications_is_read ON senaite_notifications(is_read);
CREATE INDEX idx_senaite_notifications_created_at ON senaite_notifications(created_at);

-- Scheduled event indexes
CREATE INDEX idx_senaite_scheduled_events_start_time ON senaite_scheduled_events(start_time);
CREATE INDEX idx_senaite_scheduled_events_end_time ON senaite_scheduled_events(end_time);
CREATE INDEX idx_senaite_scheduled_events_assigned_to ON senaite_scheduled_events(assigned_to);
CREATE INDEX idx_senaite_scheduled_events_event_type ON senaite_scheduled_events(event_type);
CREATE INDEX idx_senaite_scheduled_events_status ON senaite_scheduled_events(status);

-- =====================================================
-- UPDATE TRIGGERS
-- =====================================================

-- Apply updated_at triggers
CREATE TRIGGER update_senaite_workflows_updated_at BEFORE UPDATE ON senaite_workflows 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_workflow_instances_updated_at BEFORE UPDATE ON senaite_workflow_instances 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_tasks_updated_at BEFORE UPDATE ON senaite_tasks 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_notifications_updated_at BEFORE UPDATE ON senaite_notifications 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_scheduled_events_updated_at BEFORE UPDATE ON senaite_scheduled_events 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();