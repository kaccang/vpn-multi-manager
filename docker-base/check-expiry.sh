#!/bin/bash

##############################################
# Profile Expiry Checker
# Run on login and by cron
##############################################

PROFILE_CONF="/etc/xray/profile.conf"
CHECK_ONLY="${1:-false}"

# Load profile config
if [ -f "$PROFILE_CONF" ]; then
    source "$PROFILE_CONF"
else
    # If no config, skip check
    exit 0
fi

# Get current date
NOW=$(date +%s)
EXPIRED_DATE_EPOCH=$(date -d "$EXPIRED_DATE" +%s 2>/dev/null || echo "0")

# Calculate days remaining
DAYS_REMAINING=$(( ($EXPIRED_DATE_EPOCH - $NOW) / 86400 ))

# Function: Stop Xray service
stop_xray() {
    pkill -9 xray 2>/dev/null
}

# Function: Start Xray service
start_xray() {
    if [ -f /etc/xray/config.json ]; then
        /usr/local/bin/xray run -config /etc/xray/config.json &
    fi
}

# Check bandwidth exceeded
if [ -f /etc/xray/profile.conf ]; then
    BANDWIDTH_EXCEEDED=$(grep "BANDWIDTH_EXCEEDED" /etc/xray/profile.conf | cut -d'=' -f2 2>/dev/null || echo "0")
else
    BANDWIDTH_EXCEEDED=0
fi

# Check if bandwidth exceeded
if [ "$BANDWIDTH_EXCEEDED" == "1" ]; then
    # BANDWIDTH EXCEEDED

    # Stop Xray if running
    if pgrep -x "xray" > /dev/null; then
        stop_xray
    fi

    # Show warning on login
    if [ "$CHECK_ONLY" != "check-only" ]; then
        clear
        echo -e "\033[0;31m╔══════════════════════════════════════════════════════╗\033[0m"
        echo -e "\033[0;31m║                                                      ║\033[0m"
        echo -e "\033[0;31m║           ⚠️  BANDWIDTH LIMIT EXCEEDED  ⚠️           ║\033[0m"
        echo -e "\033[0;31m║                                                      ║\033[0m"
        echo -e "\033[0;31m╚══════════════════════════════════════════════════════╝\033[0m"
        echo ""
        echo -e "\033[1;33mProfile Information:\033[0m"
        echo -e "  Profile Name  : \033[1;31m$PROFILE_NAME\033[0m"
        echo -e "  Domain        : \033[1;31m$DOMAIN\033[0m"
        echo -e "  Bandwidth     : \033[1;31mLIMIT EXCEEDED\033[0m"
        echo ""
        echo -e "\033[1;33mService Status:\033[0m"
        echo -e "  VPN Service   : \033[0;31m❌ DISABLED (Bandwidth exceeded)\033[0m"
        echo -e "  SSH Access    : \033[0;32m✅ ENABLED\033[0m"
        echo ""
        echo -e "\033[1;36m═══════════════════════════════════════════════════════\033[0m"
        echo ""
        echo -e "\033[1;33mBandwidth sudah habis. Silakan hubungi admin untuk upgrade:\033[0m"
        echo ""
        echo -e "  📱 Telegram : @YourAdmin"
        echo -e "  📱 WhatsApp : +62xxx-xxxx-xxxx"
        echo ""
        echo -e "Data Anda \033[1;32mmasih aman\033[0m. Bandwidth akan reset pada"
        echo -e "tanggal 1 bulan depan, atau upgrade paket sekarang."
        echo ""
        echo -e "\033[1;36m═══════════════════════════════════════════════════════\033[0m"
        echo ""
        read -p "Press Enter to continue..."
    fi

elif [ "$DAYS_REMAINING" -lt 0 ]; then
    # EXPIRED

    # Stop Xray if running
    if pgrep -x "xray" > /dev/null; then
        stop_xray
        echo "$(date): Profile expired, Xray stopped" >> /var/log/xray/expiry.log
    fi

    # Show warning on login (not for cron check)
    if [ "$CHECK_ONLY" != "check-only" ]; then
        clear
        echo -e "\033[0;31m╔══════════════════════════════════════════════════════╗\033[0m"
        echo -e "\033[0;31m║                                                      ║\033[0m"
        echo -e "\033[0;31m║              ⚠️  PROFILE EXPIRED  ⚠️                 ║\033[0m"
        echo -e "\033[0;31m║                                                      ║\033[0m"
        echo -e "\033[0;31m╚══════════════════════════════════════════════════════╝\033[0m"
        echo ""
        echo -e "\033[1;33mProfile Information:\033[0m"
        echo -e "  Profile Name  : \033[1;31m$PROFILE_NAME\033[0m"
        echo -e "  Domain        : \033[1;31m$DOMAIN\033[0m"
        echo -e "  Expired Date  : \033[1;31m$EXPIRED_DATE\033[0m"
        echo -e "  Days Overdue  : \033[1;31m$((-$DAYS_REMAINING)) days\033[0m"
        echo ""
        echo -e "\033[1;33mService Status:\033[0m"
        echo -e "  VPN Service   : \033[0;31m❌ DISABLED (Expired)\033[0m"
        echo -e "  SSH Access    : \033[0;32m✅ ENABLED\033[0m"
        echo ""
        echo -e "\033[1;36m═══════════════════════════════════════════════════════\033[0m"
        echo ""
        echo -e "\033[1;33mUntuk memperpanjang layanan VPN, silakan hubungi admin:\033[0m"
        echo ""
        echo -e "  📱 Telegram : @YourAdmin"
        echo -e "  📱 WhatsApp : +62xxx-xxxx-xxxx"
        echo ""
        echo -e "Data Anda \033[1;32mmasih aman\033[0m dan akan aktif kembali setelah"
        echo -e "perpanjangan diproses."
        echo ""
        echo -e "\033[1;36m═══════════════════════════════════════════════════════\033[0m"
        echo ""
        read -p "Press Enter to continue..."
    fi

elif [ "$DAYS_REMAINING" -le 5 ]; then
    # WARNING: Less than 5 days

    if [ "$CHECK_ONLY" != "check-only" ]; then
        echo ""
        echo -e "\033[1;33m⚠️  WARNING: Profile akan expired dalam $DAYS_REMAINING hari!\033[0m"
        echo -e "    Expired date: $EXPIRED_DATE"
        echo -e "    Segera hubungi admin untuk perpanjangan."
        echo ""
        sleep 2
    fi

else
    # ACTIVE
    if [ "$CHECK_ONLY" != "check-only" ]; then
        echo ""
        echo -e "\033[1;32m✓ Profile active ($DAYS_REMAINING days remaining)\033[0m"
        echo ""
    fi
fi

# Exit (continue to menu if login)
exit 0
