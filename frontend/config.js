// Configuration for SENAITE LIMS Frontend Wrapper
// This configuration system works in browsers without build tools
//
// Auth model: this site no longer runs its own login. Access is granted by the
// Gates Hub SSO session (shared cookie on .gateshub.company) plus the
// has_module_access() entitlement managed in the gateshub.company admin portal.

// Get configuration from URL parameters, localStorage, or defaults
function getConfig() {
    const urlParams = new URLSearchParams(window.location.search);
    // v3 storage key: v1 stored the retired per-app Supabase auth credentials,
    // v2 stored localhost SENAITE_URLs from the laptop-hosted era — neither may
    // override the hosted-backend settings below for returning visitors.
    const stored = localStorage.getItem('senaite-config-v3');
    const storedConfig = stored ? JSON.parse(stored) : {};

    // Detect if we're on Vercel
    const isVercel = window.location.hostname.includes('vercel.app');
    const isLocalhost = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';

    return {
        // Gates Hub Supabase project (gates-onboarding) — the SSO identity and
        // module-entitlement source of truth. The anon key is public by design.
        HUB_SUPABASE_URL: urlParams.get('hub_supabase_url') ||
                          storedConfig.HUB_SUPABASE_URL ||
                          'https://mlibfbsewnnssmivtpty.supabase.co',

        HUB_SUPABASE_ANON_KEY: urlParams.get('hub_supabase_key') ||
                               storedConfig.HUB_SUPABASE_ANON_KEY ||
                               'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1saWJmYnNld25uc3NtaXZ0cHR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIxNjk4MDIsImV4cCI6MjA2Nzc0NTgwMn0.b_-Gv4Xmzt9pIpJgSbHLrBANhGs2_sv551GjXYVjGME',

        // Module key in the hub's modules catalog / module_access table.
        MODULE_KEY: storedConfig.MODULE_KEY || 'lims',

        // Where to send users who have no hub session (or no LIMS access).
        HUB_PORTAL_URL: storedConfig.HUB_PORTAL_URL || 'https://gateshub.company/portal',

        // SENAITE backend — hosted on the Gates VPS behind nginx + TLS.
        SENAITE_URL: urlParams.get('senaite_url') ||
                     storedConfig.SENAITE_URL ||
                     'https://senaite.gateshub.company',

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

        // Environment detection
        IS_VERCEL: isVercel,
        IS_LOCALHOST: isLocalhost,
        IS_PRODUCTION: !isLocalhost && !isVercel
    };
}

// Get the current configuration
const CONFIG = getConfig();

// Build base URL based on current configuration
CONFIG.BASE_URL = `${CONFIG.PROTOCOL}//${CONFIG.DOMAIN}${CONFIG.PORT}`;

// Save configuration to localStorage for persistence
function saveConfig() {
    localStorage.setItem('senaite-config-v3', JSON.stringify(CONFIG));
}

// Function to update configuration dynamically
function updateConfig(newConfig) {
    Object.assign(CONFIG, newConfig);

    // Rebuild URLs if domain/protocol changed
    if (newConfig.DOMAIN || newConfig.PROTOCOL || newConfig.PORT) {
        CONFIG.BASE_URL = `${CONFIG.PROTOCOL}//${CONFIG.DOMAIN}${CONFIG.PORT}`;
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
