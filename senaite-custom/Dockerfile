FROM senaite/senaite:v2.6.0

USER root

# Install additional system dependencies for PostgreSQL and OIDC
RUN apt-get update && apt-get install -y \
    libpq-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

USER senaite

# Copy custom buildout configuration
COPY --chown=senaite:senaite buildout-custom.cfg /home/senaite/senaitelims/buildout-custom.cfg

# Install additional Python packages
RUN cd /home/senaite/senaitelims && \
    ./bin/pip install \
    RelStorage[postgresql] \
    psycopg2-binary \
    pas.plugins.oidc \
    python-jose

# Re-run buildout with custom configuration
RUN cd /home/senaite/senaitelims && \
    ./bin/buildout -c buildout-custom.cfg

COPY --chown=senaite:senaite docker-entrypoint-custom.sh /docker-entrypoint-custom.sh
RUN chmod +x /docker-entrypoint-custom.sh

ENTRYPOINT ["/docker-entrypoint-custom.sh"]
CMD ["start"]