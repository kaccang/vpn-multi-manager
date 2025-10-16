FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

# Install required packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    wget \
    curl \
    nano \
    vim \
    net-tools \
    iputils-ping \
    vnstat \
    sqlite3 \
    unzip \
    tar \
    gzip \
    p7zip-full \
    ca-certificates \
    tzdata \
    jq \
    socat \
    nginx \
    bc \
    && rm -rf /var/lib/apt/lists/*

# Install Xray - Latest version
# Note: Check https://github.com/XTLS/Xray-core/releases for latest version
# Standard format: v1.8.24, v1.8.25, etc.
# If custom version, ensure it exists in releases!
ARG XRAY_VERSION=v25.10.15
RUN mkdir -p /usr/local/bin /usr/local/share/xray /var/log/xray && \
    echo "Downloading Xray ${XRAY_VERSION}..." && \
    wget -O /tmp/xray-linux.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip || \
    { echo "Failed to download Xray ${XRAY_VERSION}!"; \
      echo "Checking if version exists at: https://github.com/XTLS/Xray-core/releases/tag/${XRAY_VERSION}"; \
      echo "Standard Xray versions: v1.8.24, v1.8.25, etc."; \
      exit 1; } && \
    unzip -o /tmp/xray-linux.zip -d /tmp/xray && \
    mv /tmp/xray/xray /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray && \
    wget -O /usr/local/share/xray/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat && \
    wget -O /usr/local/share/xray/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat && \
    rm -rf /tmp/xray /tmp/xray-linux.zip && \
    /usr/local/bin/xray version

# Setup SSH - NO SYSTEMD
RUN mkdir -p /var/run/sshd && \
    echo 'root:vpnprofile' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Setup vnstat
RUN mkdir -p /var/lib/vnstat && \
    vnstat --create -i eth0 2>/dev/null || true

# Create directories
RUN mkdir -p /etc/xray /root/scripts /var/log/xray /root/.ssh

# Copy management scripts
COPY container-scripts/ /root/scripts/
RUN chmod +x /root/scripts/* && \
    ln -sf /root/scripts/menu /usr/local/bin/menu

# Setup check-expiry on login
COPY check-expiry.sh /root/check-expiry.sh
RUN chmod +x /root/check-expiry.sh && \
    echo '[ -f /root/check-expiry.sh ] && /root/check-expiry.sh' >> /root/.bashrc && \
    echo '[ -f /root/scripts/menu ] && /root/scripts/menu' >> /root/.bashrc

# Expose ports (internal only, mapped by docker-compose)
EXPOSE 22 10001 10002 10003

# Startup script
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

CMD ["/startup.sh"]
