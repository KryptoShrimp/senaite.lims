-- =====================================================
-- SENAITE LIMS Database Schema - Core Tables
-- =====================================================
-- Core authentication, user management, and system tables

-- Enable UUID extension for primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- AUTHENTICATION AND USER MANAGEMENT
-- =====================================================

-- Users table for SENAITE authentication
CREATE TABLE senaite_users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255), -- For local auth, null for SSO
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    full_name VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    is_superuser BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP WITH TIME ZONE,
    
    -- Azure AD integration fields
    azure_object_id VARCHAR(255),
    azure_tenant_id VARCHAR(255),
    
    -- Additional user properties
    phone VARCHAR(50),
    department VARCHAR(255),
    job_title VARCHAR(255),
    signature TEXT,
    preferences JSONB DEFAULT '{}'::jsonb
);

-- User roles and groups
CREATE TABLE senaite_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User-role assignments
CREATE TABLE senaite_user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES senaite_users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES senaite_roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES senaite_users(id),
    UNIQUE(user_id, role_id)
);

-- User sessions for tracking
CREATE TABLE senaite_user_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES senaite_users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- =====================================================
-- SYSTEM CONFIGURATION
-- =====================================================

-- System settings and configuration
CREATE TABLE senaite_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(255) UNIQUE NOT NULL,
    value JSONB,
    description TEXT,
    category VARCHAR(100),
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Laboratory information
CREATE TABLE senaite_laboratory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    address TEXT,
    phone VARCHAR(50),
    email VARCHAR(255),
    website VARCHAR(255),
    logo_url TEXT,
    accreditation_info JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Departments within the laboratory
CREATE TABLE senaite_departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    laboratory_id UUID NOT NULL REFERENCES senaite_laboratory(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    description TEXT,
    manager_id UUID REFERENCES senaite_users(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(laboratory_id, code)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Users table indexes
CREATE INDEX idx_senaite_users_username ON senaite_users(username);
CREATE INDEX idx_senaite_users_email ON senaite_users(email);
CREATE INDEX idx_senaite_users_azure_object_id ON senaite_users(azure_object_id);
CREATE INDEX idx_senaite_users_is_active ON senaite_users(is_active);
CREATE INDEX idx_senaite_users_created_at ON senaite_users(created_at);

-- User roles indexes
CREATE INDEX idx_senaite_user_roles_user_id ON senaite_user_roles(user_id);
CREATE INDEX idx_senaite_user_roles_role_id ON senaite_user_roles(role_id);

-- Sessions indexes
CREATE INDEX idx_senaite_user_sessions_user_id ON senaite_user_sessions(user_id);
CREATE INDEX idx_senaite_user_sessions_token ON senaite_user_sessions(session_token);
CREATE INDEX idx_senaite_user_sessions_expires_at ON senaite_user_sessions(expires_at);

-- Settings indexes
CREATE INDEX idx_senaite_settings_key ON senaite_settings(key);
CREATE INDEX idx_senaite_settings_category ON senaite_settings(category);

-- Laboratory and departments indexes
CREATE INDEX idx_senaite_laboratory_code ON senaite_laboratory(code);
CREATE INDEX idx_senaite_departments_laboratory_id ON senaite_departments(laboratory_id);
CREATE INDEX idx_senaite_departments_code ON senaite_departments(code);

-- =====================================================
-- TRIGGERS FOR UPDATED_AT
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables with updated_at column
CREATE TRIGGER update_senaite_users_updated_at BEFORE UPDATE ON senaite_users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_settings_updated_at BEFORE UPDATE ON senaite_settings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_laboratory_updated_at BEFORE UPDATE ON senaite_laboratory 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_departments_updated_at BEFORE UPDATE ON senaite_departments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();