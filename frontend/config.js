// Configuration for SENAITE LIMS Frontend Wrapper
// This configuration system works in browsers without build tools

// Get configuration from URL parameters, localStorage, or defaults
function getConfig() {
    const urlParams = new URLSearchParams(window.location.search);
    const stored = localStorage.getItem('senaite-config');
    const storedConfig = stored ? JSON.parse(stored) : {};
    
    // Detect if we're on Vercel
    const isVercel = window.location.hostname.includes('vercel.app');
    const isLocalhost = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
    
    return {
        // Supabase configuration
        SUPABASE_URL: urlParams.get('supabase_url') || 
                      storedConfig.SUPABASE_URL || 
                      'https://hlegzvytcoqdvoqqqmaa.supabase.co',
        
        SUPABASE_ANON_KEY: urlParams.get('supabase_key') || 
                           storedConfig.SUPABASE_ANON_KEY || 
                           'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsZWd6dnl0Y29xZHZvcXFxbWFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2ODU4NDIsImV4cCI6MjA2ODI2MTg0Mn0.DEgfEuTfrnmqEb9rfu0GXEqXSyypKaBiPC-QwJRI5kI',
        
        // SENAITE backend URL - adjust based on environment
        SENAITE_URL: urlParams.get('senaite_url') || 
                     storedConfig.SENAITE_URL || 
                     (isVercel ? 'https://lims.gateshub.company' : 'http://localhost:8080'),
        
        // Domain configuration
        DOMAIN: urlParams.get('domain') || 
                storedConfig.DOMAIN || 
                window.location.hostname,
        
        // Protocol (http/https)
        PROTOCOL: urlParams.get('protocol') || 
                  storedConfig.PROTOCOL || 
                  window.location.protocol,
        
        // Port for development
        PORT: urlParams.get('port') || 
              storedConfig.PORT || 
              (window.location.port && !isVercel ? `:${window.location.port}` : ''),
        
        // Azure AD scopes - Supabase requires 'email' scope specifically
        AZURE_SCOPES: urlParams.get('azure_scopes') || 
                      storedConfig.AZURE_SCOPES || 
                      'email',
        
        // Environment detection
        IS_VERCEL: isVercel,
        IS_LOCALHOST: isLocalhost,
        IS_PRODUCTION: !isLocalhost && !isVercel
    };
}

// Get the current configuration
const CONFIG = getConfig();

// Build redirect URLs based on current configuration
CONFIG.BASE_URL = `${CONFIG.PROTOCOL}//${CONFIG.DOMAIN}${CONFIG.PORT}`;
CONFIG.REDIRECT_URL = `${CONFIG.BASE_URL}/frontend/auth-callback.html`;
CONFIG.SUCCESS_URL = `${CONFIG.BASE_URL}/frontend/auth-success.html`;
CONFIG.LOGIN_URL = `${CONFIG.BASE_URL}/frontend/index.html`;

// Save configuration to localStorage for persistence
function saveConfig() {
    localStorage.setItem('senaite-config', JSON.stringify(CONFIG));
}

// Function to update configuration dynamically
function updateConfig(newConfig) {
    Object.assign(CONFIG, newConfig);
    
    // Rebuild URLs if domain/protocol changed
    if (newConfig.DOMAIN || newConfig.PROTOCOL || newConfig.PORT) {
        CONFIG.BASE_URL = `${CONFIG.PROTOCOL}//${CONFIG.DOMAIN}${CONFIG.PORT}`;
        CONFIG.REDIRECT_URL = `${CONFIG.BASE_URL}/frontend/auth-callback.html`;
        CONFIG.SUCCESS_URL = `${CONFIG.BASE_URL}/frontend/auth-success.html`;
        CONFIG.LOGIN_URL = `${CONFIG.BASE_URL}/frontend/index.html`;
    }
    
    saveConfig();
}

// Export for global use
window.SENAITE_CONFIG = CONFIG;
window.updateSenaiteConfig = updateConfig;

// Log configuration for debugging (remove in production)
console.log('SENAITE Configuration:', CONFIG);
console.log('Environment:', {
    isVercel: CONFIG.IS_VERCEL,
    isLocalhost: CONFIG.IS_LOCALHOST,
    isProduction: CONFIG.IS_PRODUCTION
});

// Auto-save configuration on load
saveConfig();