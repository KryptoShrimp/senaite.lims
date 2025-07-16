#!/bin/bash

# SSL Certificate Setup Script for SENAITE LIMS

set -e

if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: DOMAIN_NAME environment variable is not set"
    exit 1
fi

if [ -z "$EMAIL" ]; then
    echo "Error: EMAIL environment variable is not set"
    exit 1
fi

echo "Setting up SSL certificates for domain: $DOMAIN_NAME"

# Create initial certificate
docker run --rm \
    -v $(pwd)/certbot-data:/var/www/certbot \
    -v $(pwd)/certbot-ssl:/etc/letsencrypt \
    certbot/certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN_NAME

echo "SSL certificates have been created successfully!"
echo "You can now start the production environment with:"
echo "docker-compose -f docker-compose.production.yml up -d"