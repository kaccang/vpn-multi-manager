# VPN Multi-Profile System

**Docker-Based Multi-Profile VPN Management System**

Sistem manajemen VPN berbasis Docker yang memungkinkan 1 VPS menjalankan multiple VPN profiles yang terisolasi. Setiap profile berjalan di container Ubuntu terpisah dengan SSH access, resource limits, dan traffic monitoring.

---

## Fitur Utama

### Multi-Profile Architecture
- 1 VPS bisa host banyak VPN profiles yang terisolasi
- Setiap profile = container Ubuntu terpisah
- Resource allocation per profile (CPU & RAM)
- Domain berbeda per profile
- SSH access per profile dengan custom port

### Protocol Support
- **VMess**: WebSocket TLS & Non-TLS
- **VLess**: WebSocket TLS
- **Trojan**: WebSocket TLS

### Management Features
- CLI Semi-GUI interface (user-friendly)
- Auto port detection (SSH port 2200-2222)
- Backup & restore per profile
- Traffic monitoring (vnstat per profile)
- Resource statistics (CPU, RAM, Network usage)

### Isolation & Security
- Full filesystem isolation per profile
- Dedicated Xray instance per profile
- Separate SSL certificate per profile
- Independent user database per profile

---

## System Requirements

### Minimum
- **OS**: Ubuntu 20.04/22.04 or Debian 11/12
- **CPU**: 1 Core
- **RAM**: 1 GB
- **Disk**: 10 GB
- **Network**: Public IP + domain/subdomain

### Recommended
- **OS**: Ubuntu 22.04 LTS
- **CPU**: 2+ Cores
- **RAM**: 2+ GB
- **Disk**: 20+ GB
- **Network**: Wildcard DNS (*.yourdomain.com)

---

## Installation

### 1. Download System

```bash
cd /root
git clone https://github.com/kaccang/vpn-multi-manager.git vpn-multi
cd vpn-multi
```

Or use one-liner installer:

```bash
bash <(curl -sL https://raw.githubusercontent.com/kaccang/vpn-multi-manager/main/install.sh)
```

**⚠️ SSH Port Notice:** Installer will change SSH port from 22 → 4444 for security.

### 2. Run Installation

```bash
chmod +x scripts/install-multi-vpn.sh
./scripts/install-multi-vpn.sh
```

Installation akan menginstall:
- Docker & Docker Compose
- Nginx
- Management scripts
- Directory structure

### 3. Setup DNS

Pastikan domain/subdomain Anda pointing ke VPS IP:

```
# Contoh DNS records
sg1.yourdomain.com    A    YOUR_VPS_IP
sg2.yourdomain.com    A    YOUR_VPS_IP

# Atau gunakan wildcard
*.yourdomain.com      A    YOUR_VPS_IP
```

---

## Usage Guide

### Create Profile

```bash
profile-create
```

Akan muncul CLI Semi-GUI:

```
╔══════════════════════════════════════════════════════╗
║          CREATE NEW VPN PROFILE                      ║
╚══════════════════════════════════════════════════════╝

Profile Name: asep1
Domain: sg1.domain.com
CPU (%): 150
RAM (MB): 2048
Port SSH [2201]: 2201
Restore Link [optional]:

══════════════════════════════════════════════════════
Profile yang akan dibuat:
══════════════════════════════════════════════════════
Nama          : asep1
Domain        : sg1.domain.com
CPU           : 150%
RAM           : 2048MB
Port SSH      : 2201
Restore link  : (Fresh install)
══════════════════════════════════════════════════════

Apakah yakin create profile baru? [Y/N]: Y
```

### List Profiles

```bash
profile-list
```

Output:
```
╔══════════════════════════════════════════════════════╗
║              VPN PROFILE LIST                        ║
╚══════════════════════════════════════════════════════╝

No    Name         Domain                CPU     RAM      SSH Port   Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1     asep1        sg1.domain.com        150%    2048MB   2201       Running
2     client2      sg2.domain.com        100%    512MB    2202       Running

Total profiles: 2
```

### View Profile Stats

```bash
profile-stats asep1
```

### Delete Profile

```bash
profile-delete asep1
```

### SSH to Profile

```bash
ssh root@YOUR_VPS_IP -p 2201
# Password: vpnprofile
```

---

## Inside Profile Management

Setelah SSH ke profile, akan muncul menu:

```
╔══════════════════════════════════════════╗
║         VPN PROFILE MANAGEMENT           ║
╚══════════════════════════════════════════╝

Profile Information:
  Name         : asep1
  Domain       : sg1.domain.com
  Xray Status  : Running

Resource Usage:
  CPU Usage    : 12.5%
  RAM Usage    : 256MB / 2048MB
  Disk Usage   : 45%

VPN Accounts:
  VMess        : 3
  VLess        : 2
  Trojan       : 1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VMess Management:
  1) Add VMess Account
  2) Delete VMess Account
  3) List VMess Accounts
  4) Renew VMess Account
  5) Check VMess Account

VLess Management:
  6) Add VLess Account
  7) Delete VLess Account
  8) List VLess Accounts
  9) Renew VLess Account
  10) Check VLess Account

Trojan Management:
  11) Add Trojan Account
  12) Delete Trojan Account
  13) List Trojan Accounts
  14) Renew Trojan Account
  15) Check Trojan Account

System:
  16) Restart Xray
  17) View Logs
  18) Traffic Stats (vnstat)
  0) Exit
```

---

## Resource Allocation Guide

### CPU Limits
- **25-50%**: Light usage (1-5 users)
- **50-100%**: Medium usage (5-20 users)
- **100-200%**: Heavy usage (20-50 users)
- **200-400%**: Very heavy (50+ users, requires multi-core VPS)

### RAM Limits
- **128-256MB**: Light usage
- **256-512MB**: Medium usage
- **512-1024MB**: Heavy usage
- **1024-2048MB**: Very heavy usage

### Example Scenarios (1C 1GB VPS)

**Scenario 1: Multiple Light Profiles**
```
Profile 1: 50% CPU, 256MB RAM
Profile 2: 50% CPU, 256MB RAM
Profile 3: 50% CPU, 256MB RAM
Total: ~750MB used, 250MB free for host
```

**Scenario 2: Fewer Heavy Profiles**
```
Profile 1: 100% CPU, 512MB RAM
Profile 2: 100% CPU, 384MB RAM
Total: ~900MB used, 100MB free
```

---

## Backup & Restore

### Manual Backup Profile

```bash
cd /opt/vpn-multi/profiles/asep1
tar -czf /opt/vpn-multi/backups/per-profile/asep1-$(date +%Y%m%d).tar.gz .
```

### Restore from Backup

Saat create profile, masukkan backup URL:

```
Restore Link: http://yourserver.com/backups/asep1-backup.tar.gz
```

System akan auto-download dan restore.

---

## Troubleshooting

### Container tidak start

```bash
# Check logs
docker logs vpn-asep1

# Restart container
cd /opt/vpn-multi/profiles/asep1
docker-compose restart
```

### SSH tidak bisa connect

```bash
# Check if port is listening
ss -tuln | grep 2201

# Check container status
docker ps | grep vpn-asep1

# Restart SSH in container
docker exec vpn-asep1 service ssh restart
```

### Xray tidak jalan

```bash
# SSH ke profile
ssh root@localhost -p 2201

# Check Xray status
ps aux | grep xray

# Restart Xray
pkill xray
/usr/local/bin/xray run -config /etc/xray/config.json &
```

### Resource limit issue

Edit `docker-compose.yml` di profile directory:

```yaml
deploy:
  resources:
    limits:
      cpus: '1.5'        # Ubah sesuai kebutuhan
      memory: 1024M      # Ubah sesuai kebutuhan
```

Lalu restart:
```bash
docker-compose down
docker-compose up -d
```

---

## File Structure

```
/opt/vpn-multi/
├── docker-base/
│   ├── Dockerfile
│   ├── startup.sh
│   └── container-scripts/
│       ├── menu
│       ├── add-vmess
│       ├── add-vless
│       ├── add-trojan
│       ├── list-vmess
│       ├── list-vless
│       └── list-trojan
├── profiles/
│   ├── asep1/
│   │   ├── profile.conf
│   │   ├── config.json
│   │   ├── domain.txt
│   │   ├── docker-compose.yml
│   │   └── logs/
│   └── client2/
│       └── ...
├── backups/
│   ├── per-profile/
│   └── global/
├── scripts/
│   ├── install-multi-vpn.sh
│   ├── profile-create
│   ├── profile-delete
│   ├── profile-list
│   └── profile-stats
├── logs/
├── progress.md
└── history.md
```

---

## Security Notes

**Host SSH Port:** The system uses port **4444** for host SSH (not 22) to prevent confusion with container SSH ports (2200-2333).

1. **After installation, reconnect with:**
   ```bash
   ssh root@YOUR_VPS_IP -p 4444
   ```

2. **Change default SSH password** di setiap profile:
   ```bash
   passwd
   ```

3. **Firewall automatically configured:**
   ```
   Port 4444     - Host SSH
   Port 80/443   - HTTP/HTTPS
   Port 2200-2333 - Container SSH
   ```

4. **Regular updates**:
   ```bash
   apt update && apt upgrade -y
   ```

5. **Monitor logs**:
   ```bash
   tail -f /opt/vpn-multi/logs/system.log
   ```

---

## Performance Tips

1. **Limit profile count**: Jangan overload VPS
2. **Monitor resources**: Gunakan `profile-stats` regularly
3. **Clean old logs**: Rotate atau hapus log lama
4. **Use SSD VPS**: Untuk performance lebih baik
5. **Optimize Xray config**: Sesuaikan dengan kebutuhan

---

## Known Issues

1. **SSL generation fails**: Pastikan port 80 tidak diblock
2. **Container slow start**: Normal untuk first build
3. **Memory limit**: Docker overhead ~100MB per container

---

## FAQ

**Q: Berapa banyak profile bisa dibuat di 1C 1GB VPS?**
A: Realistis 2-4 profile dengan RAM 256-384MB per profile.

**Q: Apakah bisa migrasi profile ke VPS lain?**
A: Ya, gunakan backup/restore feature.

**Q: Apakah support auto-renew SSL?**
A: Ya, acme.sh auto-renew setiap 60 hari.

**Q: Bisa tambah protocol lain (Shadowsocks, WireGuard)?**
A: Bisa, edit container scripts dan Xray config.

---

## Support

Jika ada issue atau butuh bantuan:

1. Check `history.md` untuk log actions
2. Check `progress.md` untuk status system
3. Check logs: `/opt/vpn-multi/logs/`

---

## License

MIT License - Free to use and modify

---

**Created with ❤️ by Claude Code AI Assistant**

Last Updated: 2025-10-16
