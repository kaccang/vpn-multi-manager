#!/bin/bash

##############################################
# VPN Multi-Profile System - Installation
# Ubuntu/Debian VPS Setup
##############################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root!${NC}"
    exit 1
fi

# Check OS
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}Error: Cannot detect OS. This script supports Ubuntu/Debian only.${NC}"
    exit 1
fi

source /etc/os-release
if [[ ! "$ID" =~ ^(ubuntu|debian)$ ]]; then
    echo -e "${RED}Error: This script only supports Ubuntu or Debian!${NC}"
    exit 1
fi

clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                      ║${NC}"
echo -e "${CYAN}║      VPN MULTI-PROFILE SYSTEM INSTALLATION           ║${NC}"
echo -e "${CYAN}║                                                      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}This script will install:${NC}"
echo "  - Docker & Docker Compose"
echo "  - Nginx (reverse proxy)"
echo "  - VPN Multi-Profile Management System"
echo "  - Profile management scripts"
echo ""
read -p "$(echo -e ${GREEN}Continue installation? \[Y/N\]${NC}): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation cancelled.${NC}"
    exit 0
fi

# Base directory
BASE_DIR="/opt/vpn-multi"

echo ""
echo -e "${YELLOW}[1/8] Updating system packages...${NC}"
apt-get update -qq
apt-get upgrade -y -qq

echo -e "${YELLOW}[2/8] Installing required packages...${NC}"
apt-get install -y -qq curl wget git nano vim net-tools jq sqlite3 \
    apt-transport-https ca-certificates gnupg lsb-release

echo -e "${YELLOW}[3/8] Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh -qq
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}Docker installed successfully!${NC}"
else
    echo -e "${GREEN}Docker already installed, skipping...${NC}"
fi

echo -e "${YELLOW}[4/8] Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    curl -sL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}Docker Compose installed successfully!${NC}"
else
    echo -e "${GREEN}Docker Compose already installed, skipping...${NC}"
fi

echo -e "${YELLOW}[5/8] Installing Nginx...${NC}"
if ! command -v nginx &> /dev/null; then
    apt-get install -y -qq nginx
    systemctl enable nginx
    systemctl start nginx
    echo -e "${GREEN}Nginx installed successfully!${NC}"
else
    echo -e "${GREEN}Nginx already installed, skipping...${NC}"
fi

echo -e "${YELLOW}[6/8] Creating directory structure...${NC}"
mkdir -p $BASE_DIR/{docker-base/container-scripts,profiles,backups/{per-profile,global},logs,scripts}

# Copy files from current directory to BASE_DIR
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ -d "$CURRENT_DIR/docker-base" ]; then
    cp -r $CURRENT_DIR/docker-base/* $BASE_DIR/docker-base/
fi

if [ -d "$CURRENT_DIR/scripts" ]; then
    cp -r $CURRENT_DIR/scripts/* $BASE_DIR/scripts/
fi

if [ -f "$CURRENT_DIR/progress.md" ]; then
    cp $CURRENT_DIR/progress.md $BASE_DIR/
fi

if [ -f "$CURRENT_DIR/history.md" ]; then
    cp $CURRENT_DIR/history.md $BASE_DIR/
fi

echo -e "${GREEN}Directory structure created!${NC}"

echo -e "${YELLOW}[7/8] Setting up management scripts...${NC}"
# Make all scripts executable
chmod +x $BASE_DIR/scripts/*
chmod +x $BASE_DIR/docker-base/container-scripts/*
chmod +x $BASE_DIR/docker-base/startup.sh

# Create symlinks in /usr/local/bin
ln -sf $BASE_DIR/scripts/profile-create /usr/local/bin/profile-create
ln -sf $BASE_DIR/scripts/profile-delete /usr/local/bin/profile-delete 2>/dev/null || true
ln -sf $BASE_DIR/scripts/profile-list /usr/local/bin/profile-list 2>/dev/null || true
ln -sf $BASE_DIR/scripts/profile-stats /usr/local/bin/profile-stats 2>/dev/null || true

echo -e "${GREEN}Management scripts installed!${NC}"

echo -e "${YELLOW}[8/8] Configuring Nginx...${NC}"
cat > /etc/nginx/conf.d/vpn-multi.conf <<'EOFNGINX'
# VPN Multi-Profile Nginx Configuration
# This will be updated automatically when profiles are created

# Default server block
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    location / {
        return 404;
    }
}
EOFNGINX

systemctl reload nginx
echo -e "${GREEN}Nginx configured!${NC}"

# Success message
clear
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                      ║${NC}"
echo -e "${GREEN}║    VPN MULTI-PROFILE SYSTEM INSTALLED SUCCESSFULLY!  ║${NC}"
echo -e "${GREEN}║                                                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Installation completed!${NC}"
echo ""
echo -e "${YELLOW}Available commands:${NC}"
echo -e "  ${GREEN}profile-create${NC}      - Create new VPN profile"
echo -e "  ${GREEN}profile-delete${NC}      - Delete VPN profile"
echo -e "  ${GREEN}profile-list${NC}        - List all profiles"
echo -e "  ${GREEN}profile-stats${NC}       - Show profile statistics"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Ensure your domain DNS is pointing to this server IP"
echo "  2. Run: ${GREEN}profile-create${NC} to create your first profile"
echo "  3. SSH into profile and manage VPN accounts"
echo ""
echo -e "${CYAN}System information:${NC}"
echo -e "  Installation path: ${YELLOW}$BASE_DIR${NC}"
echo -e "  Docker version   : ${YELLOW}$(docker --version | cut -d' ' -f3 | tr -d ',')${NC}"
echo -e "  Nginx status     : ${YELLOW}$(systemctl is-active nginx)${NC}"
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════${NC}"

# Update history.md
cat >> $BASE_DIR/history.md << EOF

## $(date +"%Y-%m-%d %H:%M:%S")

**User Request:**
> Install VPN Multi-Profile System on VPS

**Action:**
- Installed Docker and Docker Compose
- Installed Nginx
- Created directory structure at $BASE_DIR
- Configured management scripts
- Setup command-line tools

**AI Response:**
VPN Multi-Profile System berhasil diinstall di $BASE_DIR. User sekarang dapat:
- Membuat profile baru dengan: profile-create
- Manage profile dengan CLI Semi-GUI
- SSH ke setiap profile untuk manage VPN accounts

**Status:** ✅ Success

---
EOF

echo -e "${YELLOW}Installation complete! You can now create your first profile.${NC}"
