FROM ghcr.io/railwayapp-templates/postgres-ssl:18
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y postgresql-18-postgis-3 postgresql-18-postgis-3-scripts && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives
