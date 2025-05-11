# 1) start FROM your base WordPress + NGINX image
FROM bitnami/wordpress-nginx:6.8.1-debian-12-r1

# 2) become root so we can install system deps
USER root

# 3) install python, venv, pip; create venv; install your Python deps
RUN install_packages python3 python3-pip python3-venv && \
    python3 -m venv /opt/bitnami/venv && \
    /opt/bitnami/venv/bin/pip install --no-cache-dir \
      sqlalchemy pymysql supabase python-dotenv

# 4) drop in your custom scripts & plugins & uploads & PHP tweaks
COPY ./scripts        /opt/bitnami/scripts/
COPY ./plugins        /opt/bitnami/wordpress/wp-content/plugins/
COPY ./uploads        /opt/bitnami/wordpress/wp-content/uploads/
COPY 99-upload-size.ini /opt/bitnami/php/etc/conf.d/

# 5) switch back to the non-root user that bitnami expects
USER 1001
