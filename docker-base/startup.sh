#!/bin/bash

# Startup script - NO SYSTEMD!

echo "Starting VPN Profile Container..."

# Start SSH (no systemd)
/usr/sbin/sshd -D &
echo "✓ SSH server started"

# Start vnstat daemon
/usr/bin/vnstatd -d
echo "✓ vnstat daemon started"

# Start Xray if config exists
if [ -f /etc/xray/config.json ]; then
    /usr/local/bin/xray run -config /etc/xray/config.json &
    echo "✓ Xray service started"
else
    echo "⚠ Xray config not found, skipping..."
fi

# Start Nginx (no systemd)
if [ -f /etc/nginx/nginx.conf ]; then
    nginx
    echo "✓ Nginx started"
fi

# NOTE: Cron jobs run on HOST, not in container
# All automated tasks (bandwidth check, health check, backup, SSL)
# are managed by host crontab. See: setup-cron script

echo "═══════════════════════════════════════"
echo "Container started successfully!"
echo "═══════════════════════════════════════"

# Keep container running
tail -f /dev/null
