# SENAITE LIMS Docker Management
# Usage: make <target>

.PHONY: help up down logs restart status build clean validate-env ssl-setup

# Default target
help:
	@echo "SENAITE LIMS Docker Management"
	@echo "=============================="
	@echo "Available targets:"
	@echo "  help         - Show this help message"
	@echo "  validate-env - Validate environment configuration"
	@echo "  up           - Start production environment"
	@echo "  down         - Stop production environment"
	@echo "  restart      - Restart production environment"
	@echo "  logs         - Show logs (ctrl+c to exit)"
	@echo "  status       - Show container status"
	@echo "  build        - Build custom images"
	@echo "  clean        - Clean up containers and volumes"
	@echo "  ssl-setup    - Set up SSL certificates"
	@echo ""
	@echo "Examples:"
	@echo "  make up      - Start the application"
	@echo "  make logs    - View application logs"
	@echo "  make down    - Stop the application"

# Environment validation
validate-env:
	@echo "Validating environment configuration..."
	@if [ ! -f .env.local ]; then \
		echo "❌ .env.local file not found!"; \
		echo "Copy .env.example to .env.local and configure it"; \
		exit 1; \
	fi
	@echo "✅ .env.local file exists"
	@echo "Checking required variables..."
	@. ./.env.local && \
	if [ -z "$$DOMAIN_NAME" ]; then echo "❌ DOMAIN_NAME not set"; exit 1; fi && \
	if [ -z "$$SUPABASE_HOST" ]; then echo "❌ SUPABASE_HOST not set"; exit 1; fi && \
	if [ -z "$$SUPABASE_PASSWORD" ]; then echo "❌ SUPABASE_PASSWORD not set"; exit 1; fi && \
	echo "✅ Domain: $$DOMAIN_NAME" && \
	echo "✅ Supabase: $$SUPABASE_HOST" && \
	echo "✅ Database: $$SUPABASE_DB" && \
	echo "✅ Environment validation passed!"

# Start production environment
up: validate-env
	@echo "Starting SENAITE LIMS production environment..."
	docker-compose --env-file .env.local -f docker-compose.production.yml up -d
	@echo "✅ SENAITE LIMS is starting up..."
	@echo "📋 Run 'make logs' to view logs"
	@echo "🌐 Access at: https://$$(grep DOMAIN_NAME .env.local | cut -d'=' -f2)"

# Stop production environment
down:
	@echo "Stopping SENAITE LIMS production environment..."
	docker-compose --env-file .env.local -f docker-compose.production.yml down
	@echo "✅ SENAITE LIMS stopped"

# Restart production environment
restart: down up

# Show logs
logs:
	@echo "Showing SENAITE LIMS logs (press Ctrl+C to exit)..."
	docker-compose --env-file .env.local -f docker-compose.production.yml logs -f

# Show container status
status:
	@echo "SENAITE LIMS Container Status:"
	@echo "============================="
	docker-compose --env-file .env.local -f docker-compose.production.yml ps

# Build custom images
build:
	@echo "Building SENAITE LIMS custom images..."
	docker-compose --env-file .env.local -f docker-compose.production.yml build
	@echo "✅ Build completed"

# Clean up containers and volumes
clean:
	@echo "⚠️  This will remove all containers and volumes!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	docker-compose --env-file .env.local -f docker-compose.production.yml down -v
	docker system prune -f
	@echo "✅ Cleanup completed"

# SSL setup
ssl-setup: validate-env
	@echo "Setting up SSL certificates..."
	@if [ -z "$$EMAIL" ]; then \
		echo "❌ EMAIL environment variable required"; \
		echo "Usage: EMAIL=your@email.com make ssl-setup"; \
		exit 1; \
	fi
	@chmod +x setup-ssl.sh
	@EMAIL=$$EMAIL DOMAIN_NAME=$$(grep DOMAIN_NAME .env.local | cut -d'=' -f2) ./setup-ssl.sh
	@echo "✅ SSL setup completed"

# Development shortcuts
dev-up:
	@echo "Starting development environment..."
	docker-compose --env-file .env.local up -d

dev-logs:
	@echo "Showing development logs..."
	docker-compose --env-file .env.local logs -f

# Health check
health:
	@echo "SENAITE LIMS Health Check:"
	@echo "========================="
	@docker-compose --env-file .env.local -f docker-compose.production.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@echo "Testing database connection..."
	@docker-compose --env-file .env.local -f docker-compose.production.yml exec -T senaite python -c "import psycopg2; conn = psycopg2.connect('postgresql://senaite:$$(grep SUPABASE_PASSWORD .env.local | cut -d'=' -f2)@$$(grep SUPABASE_HOST .env.local | cut -d'=' -f2):5432/$$(grep SUPABASE_DB .env.local | cut -d'=' -f2)'); print('✅ Database connection successful'); conn.close()" 2>/dev/null || echo "❌ Database connection failed"