// SENAITE LIMS wrapper — Gates Hub SSO gate.
//
// This app has no login of its own anymore. It reads the Gates Hub Supabase
// session from the shared .gateshub.company auth cookie (set when the user
// signs into gateshub.company with CU SSO) and checks the LIMS entitlement
// granted in the hub's admin portal (module_access / has_module_access()).
//
// Fail-closed: any error, missing session, or missing grant → no app.
// Note: this is a UX/policy gate. The hard security wall for the LIMS itself
// remains the SENAITE backend's own authentication.

import { createBrowserClient } from 'https://cdn.jsdelivr.net/npm/@supabase/ssr@0/+esm'

const CONFIG = window.SENAITE_CONFIG

// Hub client — reads the SSO session cookie shared across *.gateshub.company.
const hub = createBrowserClient(CONFIG.HUB_SUPABASE_URL, CONFIG.HUB_SUPABASE_ANON_KEY)

// DOM elements
const checking = document.getElementById('checking')
const denied = document.getElementById('denied')
const deniedMessage = document.getElementById('deniedMessage')
const appFrame = document.getElementById('appFrame')

function showApp() {
    checking.style.display = 'none'
    denied.style.display = 'none'
    appFrame.style.display = 'block'
    appFrame.src = CONFIG.SENAITE_URL
}

function showDenied(message) {
    checking.style.display = 'none'
    appFrame.style.display = 'none'
    deniedMessage.textContent = message
    denied.style.display = 'block'
}

function redirectToPortal() {
    window.location.replace(CONFIG.HUB_PORTAL_URL)
}

async function gate() {
    try {
        // Validates the token against the hub auth server (not just local state).
        const { data: { user }, error: userError } = await hub.auth.getUser()

        if (userError || !user) {
            // No hub SSO session on this browser — sign in at the portal first.
            redirectToPortal()
            return
        }

        const { data: allowed, error: rpcError } = await hub.rpc('has_module_access', {
            p_user: user.id,
            p_module: CONFIG.MODULE_KEY
        })

        if (rpcError) {
            console.error('Entitlement check failed:', rpcError)
            showDenied('Could not verify your LIMS access. Please try again, or contact a Gates Hub admin.')
            return
        }

        if (allowed === true) {
            showApp()
        } else {
            showDenied('Your Gates Hub account does not have LIMS access. Ask a Gates Hub admin to grant it in the admin portal.')
        }
    } catch (err) {
        console.error('Access check failed:', err)
        showDenied('Could not verify your LIMS access. Please try again, or contact a Gates Hub admin.')
    }
}

gate()
