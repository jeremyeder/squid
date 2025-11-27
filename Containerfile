FROM docker.io/library/alpine:latest

# Install Squid
RUN apk add --no-cache squid bash

# Create necessary directories
RUN mkdir -p /var/spool/squid /var/log/squid && \
    chown -R squid:squid /var/spool/squid /var/log/squid

# Create entrypoint script to initialize cache
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '# Fix permissions on mounted volumes' >> /entrypoint.sh && \
    echo 'chown -R squid:squid /var/spool/squid /var/log/squid' >> /entrypoint.sh && \
    echo '# Initialize cache directories if needed' >> /entrypoint.sh && \
    echo 'if [ ! -d /var/spool/squid/00 ]; then' >> /entrypoint.sh && \
    echo '    echo "Initializing cache directories..."' >> /entrypoint.sh && \
    echo '    squid -z -f /etc/squid/squid.conf' >> /entrypoint.sh && \
    echo '    rm -f /var/run/squid.pid' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '# Start Squid in foreground' >> /entrypoint.sh && \
    echo 'exec squid -NYC -f /etc/squid/squid.conf' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 3128

ENTRYPOINT ["/entrypoint.sh"]
