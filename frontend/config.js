// Configuration for SENAITE LIMS Frontend Wrapper
const CONFIG = {
    // Supabase configuration - using Vite environment variables
    SUPABASE_URL: import.meta.env.VITE_SUPABASE_URL,
    SUPABASE_ANON_KEY: import.meta.env.VITE_SUPABASE_ANON_KEY,
    
    // SENAITE backend URL
    SENAITE_URL: import.meta.env.VITE_SENAITE_URL || 'http://localhost:8080',
    
    // Authentication redirect URLs
    REDIRECT_URL: `${window.location.origin}/frontend/auth-callback.html`,
    PRODUCTION_URL: import.meta.env.VITE_PRODUCTION_URL || 'https://lims.gateshub.company',
    
    // Azure AD scopes
    AZURE_SCOPES: 'email profile openid'
}