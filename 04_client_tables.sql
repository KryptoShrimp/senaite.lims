-- =====================================================
-- SENAITE LIMS Database Schema - Client Tables
-- =====================================================
-- Client management, contacts, and relationship tables

-- =====================================================
-- CLIENT MANAGEMENT
-- =====================================================

-- Client types and categories
CREATE TABLE senaite_client_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Main clients table
CREATE TABLE senaite_clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id VARCHAR(255) UNIQUE NOT NULL, -- Lab-generated client ID
    name VARCHAR(255) NOT NULL,
    client_type_id UUID NOT NULL REFERENCES senaite_client_types(id),
    
    -- Organization details
    legal_name VARCHAR(255),
    tax_id VARCHAR(100),
    registration_number VARCHAR(100),
    
    -- Contact information
    address TEXT,
    city VARCHAR(255),
    state_province VARCHAR(255),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(255),
    website VARCHAR(255),
    
    -- Business details
    industry VARCHAR(255),
    business_type VARCHAR(100), -- Corporation, LLC, Government, etc.
    
    -- Account information
    account_status VARCHAR(50) DEFAULT 'active', -- active, suspended, closed
    credit_limit NUMERIC(12,2),
    payment_terms VARCHAR(100),
    discount_percentage NUMERIC(5,2),
    
    -- Preferences
    preferred_language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    
    -- Billing information
    billing_address TEXT,
    billing_city VARCHAR(255),
    billing_state_province VARCHAR(255),
    billing_postal_code VARCHAR(20),
    billing_country VARCHAR(100),
    
    -- Additional information
    notes TEXT,
    special_instructions TEXT,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- JSON field for custom properties
    custom_properties JSONB DEFAULT '{}'::jsonb
);

-- =====================================================
-- CONTACTS AND RELATIONSHIPS
-- =====================================================

-- Contact types (Primary, Billing, Technical, etc.)
CREATE TABLE senaite_contact_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Individual contacts
CREATE TABLE senaite_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES senaite_clients(id) ON DELETE CASCADE,
    contact_type_id UUID NOT NULL REFERENCES senaite_contact_types(id),
    
    -- Personal information
    title VARCHAR(20), -- Mr., Ms., Dr., etc.
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    full_name VARCHAR(255),
    
    -- Professional information
    job_title VARCHAR(255),
    department VARCHAR(255),
    
    -- Contact details
    phone VARCHAR(50),
    mobile VARCHAR(50),
    email VARCHAR(255),
    
    -- Address (if different from client)
    address TEXT,
    city VARCHAR(255),
    state_province VARCHAR(255),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    
    -- Communication preferences
    preferred_contact_method VARCHAR(50), -- email, phone, mail
    receives_reports BOOLEAN DEFAULT false,
    receives_notifications BOOLEAN DEFAULT true,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_primary BOOLEAN DEFAULT false,
    
    -- Additional information
    notes TEXT,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PRICING AND CONTRACTS
-- =====================================================

-- Client-specific pricing
CREATE TABLE senaite_client_pricing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES senaite_clients(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES senaite_analysis_services(id) ON DELETE CASCADE,
    
    -- Pricing details
    price NUMERIC(10,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    discount_percentage NUMERIC(5,2),
    
    -- Validity
    effective_date DATE NOT NULL,
    expiry_date DATE,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(client_id, service_id, effective_date)
);

-- Service contracts
CREATE TABLE senaite_service_contracts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES senaite_clients(id) ON DELETE CASCADE,
    
    -- Contract details
    contract_number VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(255),
    description TEXT,
    
    -- Terms
    start_date DATE NOT NULL,
    end_date DATE,
    auto_renew BOOLEAN DEFAULT false,
    
    -- Pricing
    total_value NUMERIC(12,2),
    currency VARCHAR(10) DEFAULT 'USD',
    payment_schedule VARCHAR(100), -- Monthly, Quarterly, Annually
    
    -- Status
    status VARCHAR(50) DEFAULT 'active', -- draft, active, expired, cancelled
    
    -- Documentation
    contract_document_url TEXT,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Contract services (what's included in each contract)
CREATE TABLE senaite_contract_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    contract_id UUID NOT NULL REFERENCES senaite_service_contracts(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES senaite_analysis_services(id) ON DELETE CASCADE,
    
    -- Service terms
    price NUMERIC(10,2),
    included_quantity INTEGER, -- Number of tests included
    overage_price NUMERIC(10,2), -- Price for additional tests
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(contract_id, service_id)
);

-- =====================================================
-- SAMPLE RELATIONSHIPS
-- =====================================================

-- Add client reference to samples (update the foreign key)
ALTER TABLE senaite_samples 
    ADD CONSTRAINT fk_senaite_samples_client_id 
    FOREIGN KEY (client_id) REFERENCES senaite_clients(id);

-- Sample points/locations for clients
CREATE TABLE senaite_sample_points (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES senaite_clients(id) ON DELETE CASCADE,
    
    -- Location details
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50),
    description TEXT,
    
    -- Geographic information
    address TEXT,
    city VARCHAR(255),
    state_province VARCHAR(255),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    
    -- Coordinates
    latitude NUMERIC(10,6),
    longitude NUMERIC(10,6),
    
    -- Sample collection details
    sample_types UUID[], -- Array of sample type IDs
    collection_instructions TEXT,
    access_instructions TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(client_id, code)
);

-- =====================================================
-- BILLING AND INVOICING
-- =====================================================

-- Invoice headers
CREATE TABLE senaite_invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(255) UNIQUE NOT NULL,
    client_id UUID NOT NULL REFERENCES senaite_clients(id),
    
    -- Invoice details
    invoice_date DATE NOT NULL,
    due_date DATE,
    
    -- Amounts
    subtotal NUMERIC(12,2) NOT NULL,
    tax_amount NUMERIC(12,2) DEFAULT 0,
    discount_amount NUMERIC(12,2) DEFAULT 0,
    total_amount NUMERIC(12,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    
    -- Status
    status VARCHAR(50) DEFAULT 'draft', -- draft, sent, paid, overdue, cancelled
    
    -- Payment tracking
    payment_date DATE,
    payment_method VARCHAR(100),
    payment_reference VARCHAR(255),
    
    -- Additional information
    notes TEXT,
    terms_conditions TEXT,
    
    -- Tracking
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Invoice line items
CREATE TABLE senaite_invoice_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL REFERENCES senaite_invoices(id) ON DELETE CASCADE,
    analysis_id UUID REFERENCES senaite_analyses(id),
    
    -- Item details
    description TEXT NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    total_price NUMERIC(10,2) NOT NULL,
    
    -- Additional information
    service_date DATE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Client-related indexes
CREATE INDEX idx_senaite_clients_client_id ON senaite_clients(client_id);
CREATE INDEX idx_senaite_clients_name ON senaite_clients(name);
CREATE INDEX idx_senaite_clients_client_type_id ON senaite_clients(client_type_id);
CREATE INDEX idx_senaite_clients_account_status ON senaite_clients(account_status);

-- Contact-related indexes
CREATE INDEX idx_senaite_contacts_client_id ON senaite_contacts(client_id);
CREATE INDEX idx_senaite_contacts_contact_type_id ON senaite_contacts(contact_type_id);
CREATE INDEX idx_senaite_contacts_email ON senaite_contacts(email);
CREATE INDEX idx_senaite_contacts_full_name ON senaite_contacts(full_name);

-- Pricing-related indexes
CREATE INDEX idx_senaite_client_pricing_client_id ON senaite_client_pricing(client_id);
CREATE INDEX idx_senaite_client_pricing_service_id ON senaite_client_pricing(service_id);
CREATE INDEX idx_senaite_client_pricing_effective_date ON senaite_client_pricing(effective_date);

-- Contract-related indexes
CREATE INDEX idx_senaite_service_contracts_client_id ON senaite_service_contracts(client_id);
CREATE INDEX idx_senaite_service_contracts_contract_number ON senaite_service_contracts(contract_number);
CREATE INDEX idx_senaite_service_contracts_status ON senaite_service_contracts(status);

-- Sample point indexes
CREATE INDEX idx_senaite_sample_points_client_id ON senaite_sample_points(client_id);
CREATE INDEX idx_senaite_sample_points_code ON senaite_sample_points(code);

-- Invoice indexes
CREATE INDEX idx_senaite_invoices_invoice_number ON senaite_invoices(invoice_number);
CREATE INDEX idx_senaite_invoices_client_id ON senaite_invoices(client_id);
CREATE INDEX idx_senaite_invoices_invoice_date ON senaite_invoices(invoice_date);
CREATE INDEX idx_senaite_invoices_status ON senaite_invoices(status);
CREATE INDEX idx_senaite_invoice_items_invoice_id ON senaite_invoice_items(invoice_id);
CREATE INDEX idx_senaite_invoice_items_analysis_id ON senaite_invoice_items(analysis_id);

-- =====================================================
-- UPDATE TRIGGERS
-- =====================================================

-- Apply updated_at triggers
CREATE TRIGGER update_senaite_clients_updated_at BEFORE UPDATE ON senaite_clients 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_contacts_updated_at BEFORE UPDATE ON senaite_contacts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_client_pricing_updated_at BEFORE UPDATE ON senaite_client_pricing 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_service_contracts_updated_at BEFORE UPDATE ON senaite_service_contracts 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_sample_points_updated_at BEFORE UPDATE ON senaite_sample_points 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_senaite_invoices_updated_at BEFORE UPDATE ON senaite_invoices 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();