# Use the official Bitnami WP+NGINX base
FROM bitnami/wordpress-nginx:6.8.1-debian-12-r1

# Become root so we can install Python & dependencies
USER root

# Copy in your custom sync scripts, plugins and uploads
COPY scripts/    /opt/bitnami/scripts/
COPY plugins/    /opt/bitnami/wordpress/wp-content/plugins/
COPY uploads/    /opt/bitnami/wordpress/wp-content/uploads/
COPY 99-upload-size.ini /opt/bitnami/php/etc/conf.d/

# Install Python + venv + pip, then our sync-script deps
RUN install_packages python3 python3-venv python3-pip && \
    python3 -m venv /opt/bitnami/venv && \
    /opt/bitnami/venv/bin/pip install --no-cache-dir \
      sqlalchemy pymysql supabase python-dotenv

# Drop back to non-root for running the container
USER 1001
