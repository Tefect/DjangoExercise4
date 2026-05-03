# ── Base image ──────────────────────────────────────────────────────────────
FROM python:3.13.3-slim as base

ENV PYTHONUNBUFFERED=1

# Install nginx + build tools
RUN apt-get update && apt-get install -y \
    libpq-dev \
    build-essential \
    nginx \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies
COPY requirements.txt /app/
RUN python3 -m pip install --no-cache-dir -r requirements.txt
RUN python3 -m pip install gunicorn

# Copy full project
COPY . /app/

# Point Django at mysite/settings.py
ENV DJANGO_SETTINGS_MODULE=mysite.settings

# Migrate and collect static files at build time
RUN python manage.py migrate --noinput
RUN python manage.py collectstatic --noinput

# Drop in nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Port 80 = nginx (public), gunicorn runs internally on 8000
EXPOSE 80

# Start gunicorn then nginx
CMD sh -c "gunicorn --chdir /app mysite.wsgi:application --bind 127.0.0.1:8000 --workers 2 & nginx -g 'daemon off;'"
