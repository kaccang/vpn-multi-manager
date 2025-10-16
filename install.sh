#!/bin/bash

##############################################
# VPN Multi-Profile System - Quick Installer
# One-liner: bash <(curl -sL https://raw.githubusercontent.com/yourusername/vpn-multi/main/install.sh)
##############################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# GitHub repo (UPDATE THIS!)
REPO_URL="https://github.com/kaccang/vpn-multi-manager"
RAW_URL="https://raw.githubusercontent.com/kaccang/vpn-multi-manager/main"

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                      ║${NC}"
echo -e "${CYAN}║      VPN MULTI-PROFILE SYSTEM INSTALLER              ║${NC}"
echo -e "${CYAN}║                  v1.0.0                              ║${NC}"
echo -e "${CYAN}║                                                      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# Check root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root!${NC}"
    echo "Please run: sudo bash install.sh"
    exit 1
fi

# Check OS
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}Error: Cannot detect OS${NC}"
    exit 1
fi

source /etc/os-release

if [[ ! "$ID" =~ ^(ubuntu|debian)$ ]]; then
    echo -e "${RED}Error: Only Ubuntu/Debian supported!${NC}"
    echo "Your OS: $ID"
    exit 1
fi

echo -e "${GREEN}✓ OS Check: $PRETTY_NAME${NC}"
echo ""

# Confirm installation
echo -e "${YELLOW}This will install:${NC}"
echo "  • Docker & Docker Compose"
echo "  • Nginx (reverse proxy)"
echo "  • rclone (backup tool)"
echo "  • VPN Multi-Profile System"
echo ""
read -p "Continue? [Y/N]: " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo -e "${CYAN}Starting installation...${NC}"
echo ""

# Install directory
INSTALL_DIR="/opt/vpn-multi"

# Update system
echo -e "${YELLOW}[1/10] Updating system...${NC}"
apt-get update -qq
apt-get upgrade -y -qq

# Install dependencies
echo -e "${YELLOW}[2/10] Installing dependencies...${NC}"
apt-get install -y -qq curl wget git nano vim net-tools jq sqlite3 \
    apt-transport-https ca-certificates gnupg lsb-release bc

# Install Docker
echo -e "${YELLOW}[3/10] Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh -qq
    systemctl enable docker
    systemctl start docker
    rm /tmp/get-docker.sh
    echo -e "${GREEN}✓ Docker installed${NC}"
else
    echo -e "${GREEN}✓ Docker already installed${NC}"
fi

# Install Docker Compose
echo -e "${YELLOW}[4/10] Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    curl -sL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✓ Docker Compose already installed${NC}"
fi

# Install Nginx
echo -e "${YELLOW}[5/10] Installing Nginx...${NC}"
if ! command -v nginx &> /dev/null; then
    apt-get install -y -qq nginx
    systemctl enable nginx
    systemctl start nginx
    echo -e "${GREEN}✓ Nginx installed${NC}"
else
    echo -e "${GREEN}✓ Nginx already installed${NC}"
fi

# Install rclone
echo -e "${YELLOW}[6/10] Installing rclone...${NC}"
if ! command -v rclone &> /dev/null; then
    curl https://rclone.org/install.sh | bash > /dev/null 2>&1
    echo -e "${GREEN}✓ rclone installed${NC}"
else
    echo -e "${GREEN}✓ rclone already installed${NC}"
fi

# Download system files
echo -e "${YELLOW}[7/10] Downloading VPN Multi-Profile System...${NC}"
rm -rf /tmp/vpn-multi
git clone --depth 1 $REPO_URL /tmp/vpn-multi -q

if [ ! -d /tmp/vpn-multi ]; then
    echo -e "${RED}✗ Failed to download from GitHub${NC}"
    echo "Please check repo URL: $REPO_URL"
    exit 1
fi

# Install system
echo -e "${YELLOW}[8/10] Installing system files...${NC}"
mkdir -p $INSTALL_DIR
cp -r /tmp/vpn-multi/* $INSTALL_DIR/
chmod +x $INSTALL_DIR/scripts/*
chmod +x $INSTALL_DIR/docker-base/*.sh
chmod +x $INSTALL_DIR/docker-base/container-scripts/*

# Create symlinks
ln -sf $INSTALL_DIR/scripts/profile-create /usr/local/bin/profile-create
ln -sf $INSTALL_DIR/scripts/profile-delete /usr/local/bin/profile-delete
ln -sf $INSTALL_DIR/scripts/profile-list /usr/local/bin/profile-list
ln -sf $INSTALL_DIR/scripts/profile-stats /usr/local/bin/profile-stats
ln -sf $INSTALL_DIR/scripts/profile-renew /usr/local/bin/profile-renew
ln -sf $INSTALL_DIR/scripts/profile-ssh /usr/local/bin/profile-ssh
ln -sf $INSTALL_DIR/scripts/backup-system /usr/local/bin/backup-system
ln -sf $INSTALL_DIR/scripts/restore-system /usr/local/bin/restore-system
ln -sf $INSTALL_DIR/scripts/health-check-setup /usr/local/bin/health-check-setup
ln -sf $INSTALL_DIR/scripts/setup-rclone /usr/local/bin/setup-rclone
ln -sf $INSTALL_DIR/scripts/setup-auto-backup /usr/local/bin/setup-auto-backup
ln -sf $INSTALL_DIR/scripts/ssl-auto-install /usr/local/bin/ssl-auto-install
ln -sf $INSTALL_DIR/scripts/setup-cron /usr/local/bin/setup-cron

# Setup .env
echo -e "${YELLOW}[9/10] Setting up configuration...${NC}"
if [ ! -f "$INSTALL_DIR/.env" ]; then
    cp $INSTALL_DIR/.env.example $INSTALL_DIR/.env
    echo -e "${GREEN}✓ Configuration template created${NC}"
fi

# Create directories
mkdir -p $INSTALL_DIR/{profiles,backups/{per-profile,global},logs}

# Configure Nginx
echo -e "${YELLOW}[10/12] Configuring Nginx...${NC}"
cat > /etc/nginx/sites-available/vpn-multi <<'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 404;
}
NGINX

ln -sf /etc/nginx/sites-available/vpn-multi /etc/nginx/sites-enabled/ 2>/dev/null
nginx -t && systemctl reload nginx

# Change SSH port for security
echo -e "${YELLOW}[11/12] Changing SSH port to 4444 (security)...${NC}"
SSH_PORT=4444

# Backup original sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Change SSH port
sed -i "s/^#Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config
sed -i "s/^Port 22/Port $SSH_PORT/" /etc/ssh/sshd_config

# Make sure Port directive exists
if ! grep -q "^Port $SSH_PORT" /etc/ssh/sshd_config; then
    echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
fi

echo -e "${GREEN}✓ SSH port changed to $SSH_PORT${NC}"

# Setup firewall
echo -e "${YELLOW}[12/12] Configuring firewall...${NC}"
if command -v ufw &> /dev/null; then
    ufw --force enable
    ufw allow $SSH_PORT/tcp comment 'SSH Host'
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    ufw allow 2200:2333/tcp comment 'SSH Containers'
    echo -e "${GREEN}✓ Firewall configured${NC}"
else
    echo -e "${YELLOW}⚠ UFW not available, install manually:${NC}"
    echo "  apt install ufw"
    echo "  ufw allow $SSH_PORT/tcp"
    echo "  ufw allow 80/tcp"
    echo "  ufw allow 443/tcp"
    echo "  ufw allow 2200:2333/tcp"
    echo "  ufw enable"
fi

# Restart SSH service
echo -e "${YELLOW}Restarting SSH service...${NC}"
systemctl restart sshd || systemctl restart ssh
echo -e "${GREEN}✓ SSH service restarted${NC}"

# Cleanup
rm -rf /tmp/vpn-multi

# Success
clear
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                      ║${NC}"
echo -e "${GREEN}║    VPN MULTI-PROFILE SYSTEM INSTALLED!               ║${NC}"
echo -e "${GREEN}║                                                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Installation completed successfully!${NC}"
echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  ⚠️  IMPORTANT: SSH PORT CHANGED TO 4444 ⚠️           ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Your SSH session will stay active, but for next login use:${NC}"
echo -e "  ${GREEN}ssh root@YOUR_VPS_IP -p 4444${NC}"
echo ""
echo -e "${YELLOW}Don't close this session until you verify new SSH port works!${NC}"
echo ""
echo -e "${YELLOW}Test in new terminal:${NC}"
echo -e "  ${GREEN}ssh root@$(hostname -I | awk '{print $1}') -p 4444${NC}"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo "1. Configure .env file:"
echo "   ${GREEN}nano $INSTALL_DIR/.env${NC}"
echo ""
echo "2. Setup automated tasks (cron jobs):"
echo "   ${GREEN}setup-cron${NC}"
echo ""
echo "3. Setup Telegram notifications (optional):"
echo "   ${GREEN}health-check-setup${NC}"
echo ""
echo "4. Setup backup (optional):"
echo "   ${GREEN}setup-rclone${NC}"
echo "   ${GREEN}setup-auto-backup${NC}"
echo ""
echo "5. Create your first profile:"
echo "   ${GREEN}profile-create${NC}"
echo ""
echo "6. Install SSL certificates (optional):"
echo "   ${GREEN}ssl-auto-install <profile-name>${NC}"
echo "   ${GREEN}ssl-auto-install --all${NC} (for all profiles with queue)"
echo ""
echo -e "${YELLOW}Quick commands:${NC}"
echo "  profile-create       - Create new VPN profile"
echo "  profile-list         - List all profiles"
echo "  profile-ssh <name>   - SSH to profile (passwordless)"
echo "  profile-stats <name> - Show profile statistics"
echo "  profile-renew        - Renew profile expiry"
echo ""
echo -e "${YELLOW}Documentation:${NC}"
echo "  README      : $INSTALL_DIR/README.md"
echo "  Backup Guide: $INSTALL_DIR/BACKUP_GUIDE.md"
echo "  Install Guide: $INSTALL_DIR/INSTALL.md"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Happy VPN hosting! 🚀${NC}"
echo ""
