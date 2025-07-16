#!/bin/bash
set -e

# Source the original entrypoint
source /docker-entrypoint.sh

# Additional setup for Azure AD
if [ "$1" = "start" ]; then
    echo "Configuring Azure AD OIDC..."
    
    # Wait for PostgreSQL to be ready
    if [ ! -z "$RELSTORAGE_DSN" ]; then
        echo "Waiting for PostgreSQL..."
        until psql "$RELSTORAGE_DSN" -c '\q' 2>/dev/null; do
            >&2 echo "PostgreSQL is unavailable - sleeping"
            sleep 1
        done
        >&2 echo "PostgreSQL is up"
    fi
fi

# Execute the original command
exec "$@"