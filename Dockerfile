FROM bitnami/wordpress-nginx:6.8.1-debian-12-r1

USER root

# 1️⃣ PHP config tweak
COPY 99-upload-size.ini /opt/bitnami/php/etc/conf.d/

# 2️⃣ Your custom sync scripts, plugins & uploads
COPY scripts/    /opt/bitnami/scripts/
COPY plugins/    /opt/bitnami/wordpress/wp-content/plugins/
COPY uploads/    /opt/bitnami/wordpress/wp-content/uploads/

# 3️⃣ Install Python + venv + pip, then your sync-script deps
RUN install_packages python3 python3-venv python3-pip && \
    python3 -m venv /opt/bitnami/venv && \
    /opt/bitnami/venv/bin/pip install --no-cache-dir \
      sqlalchemy pymysql supabase python-dotenv

# 4️⃣ Fix ownership
RUN chown -R 1001:1001 \
      /opt/bitnami/scripts \
      /opt/bitnami/wordpress/wp-content/plugins \
      /opt/bitnami/wordpress/wp-content/uploads

# 5️⃣ Drop back to non-root
USER 1001
