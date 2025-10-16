# VPN Multi-Profile Backup System

## Overview

Sistem backup dengan **DUAL REDUNDANCY**:
- **Primary Backup**: rclone (Google Drive, OneDrive, dll)
- **Secondary Backup**: rclone/S3 (uloz.to, Wasabi, S3, dll)

Kedua backup berjalan **parallel** dan **independent**.

---

## Setup Guide

### 1. Install rclone (if not installed)
```bash
curl https://rclone.org/install.sh | bash
```

### 2. Configure rclone Remotes
```bash
# Setup primary remote (e.g., Google Drive)
setup-rclone
# Follow prompts:
# - Choose "n" for new remote
# - Name: "gdrive"
# - Type: "drive" (for Google Drive)
# - Follow OAuth flow

# Setup secondary remote (e.g., uloz.to)
rclone config
# Choose "n" for new remote
# Name: "ulozto"
# Type: "ulozto"
# Follow prompts
```

### 3. Copy and Configure .env
```bash
cd /opt/vpn-multi
cp .env.example .env
nano .env
```

**Edit these settings:**
```bash
# Primary Backup (Google Drive)
BACKUP_PRIMARY_ENABLED=true
BACKUP_PRIMARY_TYPE="rclone"
BACKUP_PRIMARY_REMOTE="gdrive"          # Must match rclone config name
BACKUP_PRIMARY_PATH="vpn-backups"
BACKUP_PRIMARY_RETENTION_DAYS=30

# Secondary Backup (uloz.to)
BACKUP_SECONDARY_ENABLED=true
BACKUP_SECONDARY_TYPE="rclone"
BACKUP_SECONDARY_REMOTE="ulozto"        # Must match rclone config name
BACKUP_SECONDARY_PATH="vpn-backups"
BACKUP_SECONDARY_RETENTION_DAYS=60

# Optional: Enable encryption
BACKUP_ENCRYPTION_ENABLED=true
BACKUP_ENCRYPTION_PASSWORD="your-strong-password"
```

### 4. Test Backup
```bash
# Backup single profile
backup-system profile asep1

# Backup all profiles
backup-system all

# Backup entire system
backup-system global
```

### 5. Setup Auto Backup (Optional)
```bash
setup-auto-backup
```

---

## Backup Commands

### Manual Backup
```bash
# Backup specific profile
backup-system profile asep1

# Backup all profiles
backup-system all

# Global backup (entire system)
backup-system global
```

### Restore
```bash
# Restore from primary backup
restore-system primary

# Restore from secondary backup
restore-system secondary

# Will show list of available backups to choose from
```

---

## Recommended Cloud Storage

### FREE Options
| Provider | Free Storage | Speed | Reliability |
|----------|--------------|-------|-------------|
| Google Drive | 15 GB | Fast | Excellent |
| MEGA | 20 GB | Medium | Good |
| OneDrive | 5 GB | Fast | Excellent |
| uloz.to | Unlimited | Slow | Medium |
| Dropbox | 2 GB | Fast | Excellent |

### Paid Options (Cheap & Reliable)
| Provider | Price | Storage | Speed |
|----------|-------|---------|-------|
| Wasabi | $6/TB/mo | Unlimited | Fast |
| Backblaze B2 | $5/TB/mo | Unlimited | Fast |
| AWS S3 | ~$23/TB/mo | Unlimited | Fast |

---

## Backup Strategy Recommendations

### Option A: FREE (Recommended for Start)
```
Primary   : Google Drive (15GB free)
Secondary : MEGA or uloz.to (large free storage)
```

### Option B: Performance & Reliability
```
Primary   : Wasabi S3 ($6/TB/mo)
Secondary : Google Drive (backup redundancy)
```

### Option C: Maximum Redundancy
```
Primary   : Google Drive
Secondary : OneDrive or Dropbox
Tertiary  : Wasabi (manual/weekly)
```

---

## Backup File Structure

```
Remote Storage:
├── vpn-backups/               # Profiles
│   ├── asep1-20251016-140530.tar.gz
│   ├── client2-20251016-140545.tar.gz
│   └── ...
└── global/                    # Full system backups
    ├── global-backup-20251016-020000.tar.gz
    └── ...
```

---

## Encryption

Backups can be encrypted with AES-256:

```bash
# Enable in .env
BACKUP_ENCRYPTION_ENABLED=true
BACKUP_ENCRYPTION_PASSWORD="your-very-strong-password-here"
```

**⚠️ IMPORTANT:** Save password securely! Lost password = unrecoverable backup.

---

## Auto-Cleanup

Old backups are automatically deleted based on retention settings:

```bash
BACKUP_PRIMARY_RETENTION_DAYS=30      # Keep 30 days
BACKUP_SECONDARY_RETENTION_DAYS=60    # Keep 60 days
```

---

## Monitoring

Telegram notifications are sent for:
- ✅ Backup success
- ❌ Backup failures
- ⚠️ Partial failures (one destination failed)

---

## Troubleshooting

### "rclone not found"
```bash
curl https://rclone.org/install.sh | bash
```

### "Remote not found"
```bash
# Check configured remotes
rclone listremotes

# Re-configure
rclone config
```

### "Backup failed"
```bash
# Test rclone connection
rclone lsd gdrive:

# Check logs
tail -f /opt/vpn-multi/logs/backup.log
```

### "Restore failed"
```bash
# List available backups manually
rclone lsf gdrive:vpn-backups/

# Download manually
rclone copy gdrive:vpn-backups/asep1-20251016.tar.gz /tmp/
```

---

## Best Practices

1. **Test restores regularly** - Backups are useless if you can't restore
2. **Use encryption** for sensitive data
3. **Multiple destinations** - Don't rely on single storage
4. **Monitor backup size** - Ensure it's not growing unexpectedly
5. **Check backup logs** - Verify auto-backups are running
6. **Keep .env secure** - Contains credentials!

---

## Advanced: S3 Configuration

For AWS S3, Wasabi, or Backblaze B2:

```bash
# Install AWS CLI
pip3 install awscli

# Configure
aws configure
# Enter: Access Key, Secret Key, Region

# .env settings
BACKUP_SECONDARY_TYPE="s3"
BACKUP_SECONDARY_REMOTE="vpn-multi-backups"  # Bucket name
S3_ENDPOINT_URL="https://s3.wasabisys.com"   # For Wasabi
```

---

## Support

- Backup logs: `/opt/vpn-multi/logs/backup.log`
- rclone docs: https://rclone.org/docs/
- AWS CLI docs: https://docs.aws.amazon.com/cli/

