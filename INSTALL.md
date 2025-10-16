# VPN Multi-Profile System - Installation Guide

Complete guide to install and configure the VPN Multi-Profile System on Ubuntu/Debian VPS.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Installation](#quick-installation)
3. [Post-Installation Configuration](#post-installation-configuration)
4. [Creating Your First Profile](#creating-your-first-profile)
5. [Optional Configuration](#optional-configuration)
6. [Command Reference](#command-reference)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Server Requirements

- **Operating System**: Ubuntu 20.04/22.04 or Debian 10/11
- **RAM**: Minimum 2GB (4GB+ recommended for multiple profiles)
- **CPU**: 1 core minimum (2+ cores recommended)
- **Storage**: 20GB minimum
- **Root Access**: Required for installation

### Domain Requirements

Each VPN profile requires:
- A unique domain or subdomain pointed to your VPS IP
- DNS A record configured (e.g., `vpn1.example.com` → `your.vps.ip`)

Example DNS configuration:
```
vpn1.example.com    A    123.45.67.89
vpn2.example.com    A    123.45.67.89
vpn3.example.com    A    123.45.67.89
```

### Before You Start

1. Update your VPS:
   ```bash
   apt update && apt upgrade -y
   ```

2. Ensure you're logged in as root:
   ```bash
   sudo su
   ```

---

## Quick Installation

### One-Liner Installation

Run this single command to install the entire system:

```bash
bash <(curl -sL https://raw.githubusercontent.com/yourusername/vpn-multi/main/install.sh)
```

**Note**: Replace `yourusername/vpn-multi` with your actual GitHub repository URL.

### What Gets Installed

The installer will automatically install:
- ✅ Docker Engine & Docker Compose
- ✅ Nginx (reverse proxy)
- ✅ rclone (backup tool)
- ✅ All VPN management scripts
- ✅ System dependencies (curl, wget, git, jq, sqlite3, etc.)

### Installation Progress

You'll see these steps:
```
[1/10] Updating system...
[2/10] Installing dependencies...
[3/10] Installing Docker...
[4/10] Installing Docker Compose...
[5/10] Installing Nginx...
[6/10] Installing rclone...
[7/10] Downloading VPN Multi-Profile System...
[8/10] Installing system files...
[9/10] Setting up configuration...
[10/10] Configuring Nginx...
```

### Installation Time

- **Fast Connection**: 5-10 minutes
- **Slow Connection**: 10-20 minutes

---

## Post-Installation Configuration

After installation completes, you need to configure the system.

### Step 1: Configure .env File

Edit the configuration file:
```bash
nano /opt/vpn-multi/.env
```

**Essential Settings:**

```bash
# Telegram Notifications (Optional but recommended)
TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN_HERE"
TELEGRAM_CHAT_ID="YOUR_CHAT_ID_HERE"

# Backup Primary (rclone)
BACKUP_PRIMARY_ENABLED=true
BACKUP_PRIMARY_TYPE="rclone"
BACKUP_PRIMARY_REMOTE="gdrive"          # rclone remote name
BACKUP_PRIMARY_PATH="vpn-backups"       # path in remote

# Backup Secondary (for redundancy)
BACKUP_SECONDARY_ENABLED=true
BACKUP_SECONDARY_TYPE="rclone"
BACKUP_SECONDARY_REMOTE="ulozto"        # second rclone remote
BACKUP_SECONDARY_PATH="backups"

# Encryption (Optional)
BACKUP_ENCRYPTION_ENABLED=false
BACKUP_ENCRYPTION_PASSWORD="your-strong-password"
```

**Save and exit**: Press `Ctrl+X`, then `Y`, then `Enter`

**Important Encryption Settings:**
```bash
# Optional: Enable backup encryption with AES-256
BACKUP_ENCRYPTION_ENABLED=true
BACKUP_ENCRYPTION_PASSWORD="your-very-strong-password-here"
```

When enabled:
- ✅ Backups encrypted with AES-256-CBC + PBKDF2
- ✅ Restore automatically decrypts with password from .env
- ⚠️ Keep password safe! Lost password = lost backups

When disabled:
- Backups stored as plain tar.gz files
- Faster backup/restore
- Easier to inspect manually

### Step 2: Setup Telegram Notifications (Optional)

Telegram notifications alert you when profiles go UP/DOWN.

#### Get Bot Token:
1. Open Telegram and search for `@BotFather`
2. Send `/newbot`
3. Follow instructions to create bot
4. Copy the token (format: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

#### Get Chat ID:
1. Search for `@userinfobot` in Telegram
2. Start chat and send any message
3. Copy your Chat ID (format: `987654321`)

#### Configure:
```bash
health-check-setup
```

Follow prompts to enter your Bot Token and Chat ID.

### Step 3: Setup Automated Tasks (Cron Jobs)

Setup cron jobs for automated tasks:
```bash
setup-cron
```

This will setup:
- ✅ Bandwidth check (hourly)
- ✅ Health check (every 5 minutes)
- ✅ SSL certificate queue processor (every 3 minutes)
- ✅ Auto backup (daily at 2 AM)

All cron jobs run on the HOST, not in containers. Monitor with:
```bash
tail -f /opt/vpn-multi/logs/bandwidth.log
tail -f /opt/vpn-multi/logs/health.log
tail -f /opt/vpn-multi/logs/ssl-queue.log
tail -f /opt/vpn-multi/logs/backup.log
```

### Step 4: Setup Backup (Optional)

#### Setup rclone:
```bash
setup-rclone
```

Follow the interactive wizard to configure:
- **Primary Backup**: Google Drive (recommended - 15GB free)
- **Secondary Backup**: uloz.to (recommended - 25GB free)

Popular rclone providers:
- `drive` - Google Drive (15GB free)
- `dropbox` - Dropbox (2GB free)
- `onedrive` - Microsoft OneDrive (5GB free)
- `ulozto` - uloz.to (25GB free)
- `mega` - MEGA (50GB free)
- `s3` - AWS S3 (paid)

#### Enable Auto Backup:
```bash
setup-auto-backup
```

This creates daily backup cron jobs at 2 AM.

### Step 4: Setup Passwordless SSH (For Admin)

Generate SSH key if you don't have one:
```bash
ssh-keygen -t rsa -b 4096
```

Press Enter for all prompts (default location, no passphrase).

**Note**: Your profiles will automatically use this key for passwordless access.

### Step 5: Setup SSL Certificates (Optional but Recommended)

For HTTPS/TLS support, install SSL certificates with Let's Encrypt:

#### Option 1: Single Profile
```bash
ssl-auto-install client1
```

#### Option 2: All Profiles (with Anti-Rate Limit Queue)
```bash
ssl-auto-install --all
```

This will:
- ✅ Add all profiles to queue
- ✅ Process 1 profile every 3 minutes (avoid Let's Encrypt rate limit)
- ✅ Auto-check existing certificates (skip if valid >30 days)
- ✅ Copy certificates to containers automatically

**Let's Encrypt Rate Limit:** 50 certificates/week per domain

**Monitor queue:**
```bash
ssl-auto-install --status
tail -f /opt/vpn-multi/logs/ssl-queue.log
```

**Manual SSL installation** (if you prefer):
```bash
certbot certonly --standalone -d your-domain.com
```

Then copy to container:
```bash
docker cp /etc/letsencrypt/live/your-domain.com/fullchain.pem vpn-client1:/etc/letsencrypt/live/your-domain.com/
docker cp /etc/letsencrypt/live/your-domain.com/privkey.pem vpn-client1:/etc/letsencrypt/live/your-domain.com/
```

---

## Creating Your First Profile

### Interactive Profile Creation

Run the profile creation wizard:
```bash
profile-create
```

You'll see this interactive form:

```
╔══════════════════════════════════════════════════════╗
║         VPN MULTI-PROFILE - CREATE PROFILE           ║
╚══════════════════════════════════════════════════════╝

Profile Name: client1
  ↳ Alphanumeric only (a-z, 0-9, -)

Domain: vpn1.example.com
  ↳ Must point to this server IP

SSH Password:
  ↳ Leave empty for auto-generate (8-12 chars)
  ↳ Or enter custom (8-25 chars)

Expired Days: 30
  ↳ Days until profile expires

Bandwidth Limit (TB): 1
  ↳ Monthly bandwidth limit (outbound only)
  ↳ Resets every 1st of month

CPU Limit (%): 50
  ↳ Maximum CPU usage (e.g., 50 = 50%)

RAM Limit (MB): 512
  ↳ Maximum RAM in megabytes

Restore from backup? [y/N]: N
  ↳ Or provide URL for restore
```

### Example Profile Creation

```bash
profile-create
```

**Input Example:**
```
Profile Name: demo
Domain: demo.vpn.example.com
SSH Password: [press Enter for auto-generate]
Expired Days: 30
Bandwidth Limit (TB): 1
CPU Limit (%): 50
RAM Limit (MB): 512
Restore from backup? [y/N]: N
```

**Output:**
```
✓ Profile created successfully!

═══════════════════════════════════════════════════════
           PROFILE DETAILS
═══════════════════════════════════════════════════════
Profile Name : demo
Domain       : demo.vpn.example.com
SSH Port     : 2200
SSH Password : aB3xK9mP    ← PLAINTEXT for client delivery
Container IP : 172.18.0.2
CPU Limit    : 50%
RAM Limit    : 512 MB
Expired Date : 2025-11-15
Bandwidth    : 1 TB/month (resets monthly)
═══════════════════════════════════════════════════════

SSH Access (Admin):
  profile-ssh demo

Container running as: demo
```

### Access Your Profile

SSH to the profile container (passwordless for admin):
```bash
profile-ssh demo
```

You'll be inside the profile's Ubuntu environment with the menu:
```
╔══════════════════════════════════════════════════════╗
║              VPN PROFILE MANAGEMENT                  ║
╚══════════════════════════════════════════════════════╝

Profile    : demo
Domain     : demo.vpn.example.com
Expired    : 2025-11-15 (30 days remaining)
Bandwidth  : 0.05 / 1.00 TB (5%)
CPU Usage  : 12%
RAM Usage  : 128 MB / 512 MB
Xray Status: ● Running

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           VPN ACCOUNT MANAGEMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1. Add VMess Account       8. Delete VMess Account
  2. Add VLess Account        9. Delete VLess Account
  3. Add Trojan Account      10. Delete Trojan Account
  4. Check VMess Account     11. Renew VMess Account
  5. Check VLess Account     12. Renew VLess Account
  6. Check Trojan Account    13. Renew Trojan Account
  7. List All Accounts       14. Show VPN Statistics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
           SYSTEM MANAGEMENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 15. Restart Xray
 16. Show System Info
 17. Exit

Select option [1-17]:
```

---

## Optional Configuration

### SSL Certificate (Free with Let's Encrypt)

For each profile domain, install SSL certificate:

1. SSH to profile:
   ```bash
   profile-ssh demo
   ```

2. Inside container:
   ```bash
   apt update && apt install certbot -y
   certbot certonly --standalone -d demo.vpn.example.com
   ```

3. Certificates saved to: `/etc/letsencrypt/live/demo.vpn.example.com/`

### Firewall Configuration

Allow necessary ports:
```bash
# Allow SSH (default port)
ufw allow 22/tcp

# Allow HTTP/HTTPS (for reverse proxy)
ufw allow 80/tcp
ufw allow 443/tcp

# Allow SSH port range (for profile containers)
ufw allow 2200:2333/tcp

# Enable firewall
ufw enable
```

### Automatic Updates

Enable automatic security updates:
```bash
apt install unattended-upgrades -y
dpkg-reconfigure -plow unattended-upgrades
```

---

## Command Reference

### Profile Management

| Command | Description | Example |
|---------|-------------|---------|
| `profile-create` | Create new VPN profile | `profile-create` |
| `profile-list` | List all profiles with status | `profile-list` |
| `profile-ssh <name>` | SSH to profile (passwordless) | `profile-ssh demo` |
| `profile-stats <name>` | Show profile statistics | `profile-stats demo` |
| `profile-renew` | Extend profile expiry | `profile-renew` |
| `profile-delete` | Delete profile | `profile-delete` |

### Backup & Restore

| Command | Description |
|---------|-------------|
| `setup-rclone` | Configure rclone remotes |
| `setup-auto-backup` | Enable daily auto-backup |
| `backup-system` | Manual backup (global or per-profile) |
| `restore-system` | Restore from backup |

### SSL & Automation

| Command | Description | Example |
|---------|-------------|---------|
| `ssl-auto-install <profile>` | Install SSL for specific profile | `ssl-auto-install client1` |
| `ssl-auto-install --all` | Install SSL for all profiles (queued) | `ssl-auto-install --all` |
| `ssl-auto-install --status` | Show SSL queue status | `ssl-auto-install --status` |
| `setup-cron` | Setup automated tasks (cron jobs) | `setup-cron` |

### Health & Monitoring

| Command | Description |
|---------|-------------|
| `health-check-setup` | Configure Telegram notifications |
| `bandwidth-check` | Check all profiles bandwidth |

### Quick Examples

**List all profiles:**
```bash
profile-list
```

**Check profile statistics:**
```bash
profile-stats demo
```

**SSH to profile:**
```bash
profile-ssh demo
```

**Renew profile expiry:**
```bash
profile-renew
# Select profile → Enter days to add
```

**Manual backup:**
```bash
backup-system
# Choose: 1) Per-profile or 2) Global
```

---

## Troubleshooting

### Common Issues

#### 1. Installation Failed

**Error**: `Cannot connect to Docker daemon`

**Solution**:
```bash
systemctl start docker
systemctl enable docker
```

---

#### 2. Profile Not Accessible

**Error**: Cannot SSH to profile

**Check 1 - Container running?**
```bash
docker ps | grep profile-name
```

**Check 2 - Port forwarding?**
```bash
profile-list
# Verify SSH port is listed
```

**Fix**: Restart profile container
```bash
docker restart profile-name
```

---

#### 3. Domain Not Resolving

**Error**: Domain doesn't reach VPS

**Check DNS**:
```bash
dig vpn1.example.com
# Should show your VPS IP
```

**Fix**: Update DNS A record with your VPS IP, wait 5-60 minutes for propagation.

---

#### 4. Nginx Not Working

**Error**: Port 443/80 conflict

**Check Nginx status**:
```bash
systemctl status nginx
```

**Check port usage**:
```bash
netstat -tlnp | grep :443
```

**Fix**: Restart Nginx
```bash
nginx -t
systemctl restart nginx
```

---

#### 5. VPN Not Working

**Check Xray status** (inside profile):
```bash
profile-ssh demo
pgrep -x xray
# Should return process ID
```

**Restart Xray**:
```bash
pkill -9 xray
/usr/local/bin/xray run -config /etc/xray/config.json &
```

---

#### 6. Expired Profile

**Symptom**: SSH works but VPN doesn't connect

**Check expiry**:
```bash
profile-list
# Check "Expired" column
```

**Fix - Renew profile**:
```bash
profile-renew
# Select profile → Add days
```

---

#### 7. Bandwidth Exceeded

**Symptom**: VPN stopped working mid-month

**Check bandwidth**:
```bash
profile-stats demo
# Check bandwidth usage vs limit
```

**Fix - Increase limit** (edit profile):
```bash
nano /opt/vpn-multi/profiles/demo/profile.conf
# Update BANDWIDTH_TB value
# Restart check: docker restart demo
```

---

#### 8. Backup Failed

**Error**: rclone upload failed

**Check rclone config**:
```bash
rclone listremotes
# Should show your configured remotes
```

**Test rclone**:
```bash
rclone ls gdrive:vpn-backups
```

**Reconfigure**:
```bash
setup-rclone
```

---

### Get More Help

**Check logs**:
```bash
# Docker container logs
docker logs profile-name

# System logs
journalctl -xe

# Nginx logs
tail -f /var/log/nginx/error.log
```

**System documentation**:
- README: `/opt/vpn-multi/README.md`
- Backup Guide: `/opt/vpn-multi/BACKUP_GUIDE.md`

---

## Security Best Practices

### 1. Change Default SSH Port

Edit `/etc/ssh/sshd_config`:
```bash
Port 2222  # Change from 22
```

Restart SSH:
```bash
systemctl restart sshd
```

### 2. Disable Root Password Login

Edit `/etc/ssh/sshd_config`:
```bash
PermitRootLogin without-password
PasswordAuthentication no
```

### 3. Enable Firewall

```bash
ufw enable
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp  # Your SSH port
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 2200:2333/tcp
```

### 4. Regular Updates

```bash
apt update && apt upgrade -y
```

### 5. Monitor System

```bash
# Enable health check
health-check-setup

# Check daily
profile-list
```

---

## Performance Tuning

### For High Traffic Servers

Edit `/opt/vpn-multi/.env`:
```bash
# Increase Docker resources
DOCKER_DEFAULT_CPU=100
DOCKER_DEFAULT_RAM=1024
```

### Optimize Nginx

Edit `/etc/nginx/nginx.conf`:
```nginx
worker_processes auto;
worker_connections 4096;
```

Restart Nginx:
```bash
systemctl restart nginx
```

---

## Next Steps

1. **Create profiles** for each client
2. **Setup backup** for disaster recovery
3. **Enable monitoring** for uptime alerts
4. **Configure firewall** for security
5. **Document** your client credentials

---

## Support

- **Documentation**: `/opt/vpn-multi/README.md`
- **Backup Guide**: `/opt/vpn-multi/BACKUP_GUIDE.md`
- **GitHub Issues**: Report bugs and feature requests

---

**Happy VPN Hosting!** 🚀
