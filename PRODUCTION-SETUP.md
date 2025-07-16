# SENAITE LIMS Production Setup

This guide walks you through setting up SENAITE LIMS in production with:
- Azure AD Single Sign-On (SSO)
- Supabase PostgreSQL backend
- NGINX reverse proxy with SSL/TLS
- Docker containerization

## Prerequisites

1. **Domain name** pointing to your server
2. **Supabase account** with PostgreSQL database
3. **Azure AD tenant** with app registration
4. **Docker and Docker Compose** installed
5. **Server** with ports 80 and 443 open

## Setup Steps

### 1. Configure Environment Variables

Copy the example environment file:
```bash
cp .env.example .env
```

Edit `.env` with your actual values:
- `DOMAIN_NAME`: Your domain (e.g., lims.yourcompany.com)
- `SUPABASE_*`: Your Supabase database credentials
- `AZURE_*`: Your Azure AD app registration details

### 2. Set up Supabase Database

1. Create a new project in Supabase
2. Go to Settings > Database
3. Copy the connection details to your `.env` file
4. Create a dedicated database user for SENAITE:
   ```sql
   CREATE USER senaite WITH PASSWORD 'your-secure-password';
   GRANT ALL PRIVILEGES ON DATABASE postgres TO senaite;
   ```

### 3. Configure Azure AD

1. Go to Azure Portal > Azure Active Directory > App registrations
2. Create a new app registration:
   - Name: "SENAITE LIMS"
   - Redirect URI: `https://your-domain.com/senaite/acl_users/oidc/callback`
3. Note the Application (client) ID and Directory (tenant) ID
4. Generate a client secret under "Certificates & secrets"
5. Add these values to your `.env` file

### 4. DNS Configuration

Point your domain to your server's IP address:
```
A record: lims.yourcompany.com -> YOUR_SERVER_IP
```

### 5. Initial SSL Certificate Setup

Run the SSL setup script:
```bash
chmod +x setup-ssl.sh
EMAIL=your-email@company.com DOMAIN_NAME=lims.yourcompany.com ./setup-ssl.sh
```

### 6. Start Production Environment

```bash
docker-compose -f docker-compose.production.yml up -d
```

### 7. Configure Azure AD in SENAITE

1. Access your SENAITE instance at `https://your-domain.com`
2. Login with admin/admin
3. Go to Site Setup > Add-ons
4. Install "pas.plugins.oidc"
5. Go to Site Setup > OIDC Settings
6. Configure:
   - Client ID: Your Azure app client ID
   - Client Secret: Your Azure app client secret
   - Discovery URL: `https://login.microsoftonline.com/{tenant-id}/v2.0/.well-known/openid_configuration`

## User Management

### Role Mapping
Configure how Azure AD groups map to SENAITE roles:
- Azure AD Group "LIMS-Admins" → SENAITE "Manager" role
- Azure AD Group "LIMS-Analysts" → SENAITE "Analyst" role
- Azure AD Group "LIMS-Clients" → SENAITE "Client" role

### Creating Users
Users will be automatically created on first login through Azure AD.

## Monitoring and Maintenance

### Health Checks
```bash
# Check container status
docker-compose -f docker-compose.production.yml ps

# View logs
docker-compose -f docker-compose.production.yml logs -f senaite

# Check SSL certificate status
docker exec senaite-certbot certbot certificates
```

### Backup Strategy
1. **Database**: Use Supabase's built-in backup features
2. **Blob storage**: Regular backup of Docker volumes
3. **Configuration**: Keep your `.env` and config files in version control

### Updates
```bash
# Pull latest images
docker-compose -f docker-compose.production.yml pull

# Restart services
docker-compose -f docker-compose.production.yml up -d
```

## Security Considerations

1. **Change default passwords** immediately after setup
2. **Use strong passwords** for all accounts
3. **Enable MFA** in Azure AD
4. **Regular security updates** for containers
5. **Monitor access logs** regularly
6. **Use HTTPS everywhere**

## Troubleshooting

### Common Issues

1. **SSL Certificate Issues**
   - Ensure DNS is pointing to your server
   - Check firewall settings (ports 80, 443)
   - Verify domain ownership

2. **Database Connection Issues**
   - Check Supabase connection details
   - Verify network connectivity
   - Check PostgreSQL user permissions

3. **Azure AD Login Issues**
   - Verify redirect URI in Azure AD app
   - Check client secret expiration
   - Ensure proper scopes are configured

### Logs
```bash
# Application logs
docker logs senaite -f

# Nginx logs
docker logs senaite-nginx -f

# Certificate renewal logs
docker logs senaite-certbot -f
```

## Support

For issues specific to this setup, please create an issue in the repository.
For SENAITE-specific issues, visit: https://github.com/senaite/senaite.lims