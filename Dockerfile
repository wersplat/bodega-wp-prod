# 1. Base off Bitnami’s nginx+WP image
FROM bitnami/wordpress-nginx:6.8.1-debian-12-r1

# 2. Become root to install python & venv support
USER root

# 3. Install python3-venv (Debian needs this), pip & create a virtualenv 
RUN install_packages python3 python3-pip python3-venv \
 && python3 -m venv /opt/bitnami/venv \
 && /opt/bitnami/venv/bin/pip install --no-cache-dir \
      sqlalchemy pymysql supabase python-dotenv

# 4. Copy in your sync scripts
COPY scripts/ /opt/bitnami/scripts/

# 5. Copy your WP-content bits
COPY plugins/ /opt/bitnami/wordpress/wp-content/plugins/
COPY uploads/ /opt/bitnami/wordpress/wp-content/uploads/

# 6. Increase PHP upload limits
COPY 99-upload-size.ini /opt/bitnami/php/etc/conf.d/

# 7. Drop back to non-root for Bitnami entrypoint
USER 1001
# ensure our venv is on PATH
ENV PATH="/opt/bitnami/venv/bin:${PATH}"
