// Supabase configuration from config file
const SUPABASE_URL = CONFIG.SUPABASE_URL
const SUPABASE_ANON_KEY = CONFIG.SUPABASE_ANON_KEY

// Initialize Supabase client
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// DOM elements
const loginContainer = document.getElementById('loginContainer')
const loginButton = document.getElementById('loginButton')
const loading = document.getElementById('loading')
const error = document.getElementById('error')
const appFrame = document.getElementById('appFrame')

// SENAITE backend URL from config file
const SENAITE_URL = CONFIG.SENAITE_URL

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
        
        const { data, error: authError } = await supabase.auth.signInWithOAuth({
            provider: 'azure',
            options: {
                scopes: CONFIG.AZURE_SCOPES,
                redirectTo: CONFIG.REDIRECT_URL
            }
        })
        
        if (authError) {
            throw authError
        }
        
    } catch (err) {
        console.error('Login failed:', err)
        showError('Login failed. Please try again.')
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
    }
}

// Create or update user in senaite_users table
async function createOrUpdateUser(user) {
    try {
        const userData = {
            auth_user_id: user.id,
            email: user.email,
            full_name: user.user_metadata?.full_name || user.email,
            azure_id: user.user_metadata?.sub || user.user_metadata?.provider_id,
            department: user.user_metadata?.department || null,
            role: 'user', // Default role
            is_active: true,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
        }

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
    if (event === 'SIGNED_IN' && session?.user) {
        currentUser = session.user
        
        // Create or update user in database
        const dbUser = await createOrUpdateUser(session.user)
        if (dbUser) {
            console.log('User synchronized to database:', dbUser)
        }
        
        showApp()
    } else if (event === 'SIGNED_OUT') {
        currentUser = null
        showLogin()
    }
})

// Add logout button to app frame (injected into SENAITE)
function addLogoutButton() {
    const logoutBtn = document.createElement('button')
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
    logoutBtn.onclick = handleLogout
    
    document.body.appendChild(logoutBtn)
}

// Initialize app
document.addEventListener('DOMContentLoaded', () => {
    loginButton.addEventListener('click', handleLogin)
    checkAuth()
    
    // Add logout button when app loads
    setTimeout(addLogoutButton, 2000)
})