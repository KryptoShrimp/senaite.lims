// Get configuration from centralized config
// CONFIG is already declared in config.js, so we'll use window.SENAITE_CONFIG directly

// Initialize Supabase client with centralized config
const supabase = window.supabase.createClient(window.SENAITE_CONFIG.SUPABASE_URL, window.SENAITE_CONFIG.SUPABASE_ANON_KEY)

// DOM elements
const loginContainer = document.getElementById('loginContainer')
const loginButton = document.getElementById('loginButton')
const loading = document.getElementById('loading')
const error = document.getElementById('error')
const appFrame = document.getElementById('appFrame')

// SENAITE backend URL from centralized config
const SENAITE_URL = window.SENAITE_CONFIG.SENAITE_URL

// Authentication state
let currentUser = null

// Check if user is already authenticated
async function checkAuth() {
    try {
        const { data: { user } } = await supabase.auth.getUser()
        if (user) {
            currentUser = user
            showApp()
        }
    } catch (err) {
        console.error('Auth check failed:', err)
        showError('Authentication check failed. Please refresh the page.')
    }
}

// Show login form
function showLogin() {
    loginContainer.style.display = 'block'
    appFrame.style.display = 'none'
    loading.style.display = 'none'
    error.style.display = 'none'
}

// Show SENAITE app
function showApp() {
    loginContainer.style.display = 'none'
    appFrame.style.display = 'block'
    appFrame.src = SENAITE_URL
}

// Show error message
function showError(message) {
    error.textContent = message
    error.style.display = 'block'
    loading.style.display = 'none'
    loginButton.disabled = false
}

// Handle Azure AD login
async function handleLogin() {
    try {
        loginButton.disabled = true
        loading.style.display = 'block'
        error.style.display = 'none'
        
        console.log('Starting Azure AD login...')
        console.log('Config check:', {
            SUPABASE_URL: window.SENAITE_CONFIG.SUPABASE_URL,
            SUPABASE_ANON_KEY: window.SENAITE_CONFIG.SUPABASE_ANON_KEY ? 'Present' : 'Missing',
            REDIRECT_URL: window.SENAITE_CONFIG.REDIRECT_URL,
            AZURE_SCOPES: window.SENAITE_CONFIG.AZURE_SCOPES
        })
        
        // Test Supabase connection first
        const { data: { user } } = await supabase.auth.getUser()
        console.log('Supabase connection test:', user ? 'Connected' : 'Not authenticated')
        
        console.log('Attempting login with redirect URL:', window.SENAITE_CONFIG.REDIRECT_URL)
        
        const { data, error: authError } = await supabase.auth.signInWithOAuth({
            provider: 'azure',
            options: {
                scopes: window.SENAITE_CONFIG.AZURE_SCOPES,
                redirectTo: window.SENAITE_CONFIG.REDIRECT_URL
            }
        })
        
        console.log('OAuth response:', { data, error: authError })
        
        if (authError) {
            throw authError
        }
        
        // Note: The actual redirect happens automatically
        // The user will be redirected to Azure AD, then back to our callback
        
    } catch (err) {
        console.error('Login failed:', err)
        console.error('Error details:', {
            message: err.message,
            stack: err.stack,
            name: err.name
        })
        showError(`Login failed: ${err.message}. Please try again.`)
    }
}

// Handle logout
async function handleLogout() {
    try {
        const { error } = await supabase.auth.signOut()
        if (error) throw error
        
        currentUser = null
        showLogin()
    } catch (err) {
        console.error('Logout failed:', err)
        showError('Logout failed. Please try again.')
    }
}

// Create or update user in senaite_users table
async function createOrUpdateUser(user) {
    try {
        // Extract username from email
        const username = user.email.split('@')[0];
        
        const userData = {
            auth_user_id: user.id,
            username: username,
            email: user.email,
            full_name: user.user_metadata?.full_name || user.user_metadata?.name || user.email,
            first_name: user.user_metadata?.given_name || user.user_metadata?.first_name || '',
            last_name: user.user_metadata?.family_name || user.user_metadata?.last_name || '',
            azure_object_id: user.user_metadata?.sub || user.user_metadata?.oid || user.user_metadata?.provider_id,
            azure_tenant_id: user.user_metadata?.tid || user.user_metadata?.tenant_id,
            department: user.user_metadata?.department || null,
            job_title: user.user_metadata?.job_title || null,
            is_active: true,
            updated_at: new Date().toISOString()
        }

        console.log('Creating/updating user with data:', userData)

        // Try to insert, if conflict then update
        const { data, error } = await supabase
            .from('senaite_users')
            .upsert(userData, { 
                onConflict: 'auth_user_id',
                ignoreDuplicates: false 
            })
            .select()

        if (error) {
            console.error('Error creating/updating user:', error)
            return null
        }

        console.log('User created/updated:', data)
        return data[0]
    } catch (err) {
        console.error('Error in createOrUpdateUser:', err)
        return null
    }
}

// Listen for auth state changes
supabase.auth.onAuthStateChange(async (event, session) => {
    console.log('Auth state changed:', event, session?.user?.email)
    
    if (event === 'SIGNED_IN' && session?.user) {
        currentUser = session.user
        
        // Create or update user in database
        const dbUser = await createOrUpdateUser(session.user)
        if (dbUser) {
            console.log('User synchronized to database:', dbUser)
        } else {
            console.warn('Failed to sync user to database')
        }
        
        showApp()
    } else if (event === 'SIGNED_OUT') {
        currentUser = null
        showLogin()
    } else if (event === 'TOKEN_REFRESHED') {
        console.log('Token refreshed')
    }
})

// Add logout button to app frame (injected into SENAITE)
function addLogoutButton() {
    // Remove existing logout button if it exists
    const existingBtn = document.getElementById('senaite-logout-btn')
    if (existingBtn) {
        existingBtn.remove()
    }
    
    const logoutBtn = document.createElement('button')
    logoutBtn.id = 'senaite-logout-btn'
    logoutBtn.textContent = 'Logout'
    logoutBtn.style.position = 'fixed'
    logoutBtn.style.top = '10px'
    logoutBtn.style.right = '10px'
    logoutBtn.style.zIndex = '9999'
    logoutBtn.style.backgroundColor = '#dc3545'
    logoutBtn.style.color = 'white'
    logoutBtn.style.border = 'none'
    logoutBtn.style.padding = '8px 16px'
    logoutBtn.style.borderRadius = '4px'
    logoutBtn.style.cursor = 'pointer'
    logoutBtn.style.fontSize = '14px'
    logoutBtn.style.fontFamily = 'Arial, sans-serif'
    logoutBtn.onclick = handleLogout
    
    document.body.appendChild(logoutBtn)
}

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    console.log('App initializing with config:', window.SENAITE_CONFIG)
    
    // Verify configuration
    if (!window.SENAITE_CONFIG.SUPABASE_URL || !window.SENAITE_CONFIG.SUPABASE_ANON_KEY) {
        showError('Configuration error: Missing Supabase credentials')
        return
    }
    
    loginButton.addEventListener('click', handleLogin)
    checkAuth()
    
    // Add logout button when app loads
    setTimeout(addLogoutButton, 2000)
})

// Handle configuration updates
window.addEventListener('storage', (e) => {
    if (e.key === 'senaite-config') {
        console.log('Configuration updated, reloading page...')
        window.location.reload()
    }
})