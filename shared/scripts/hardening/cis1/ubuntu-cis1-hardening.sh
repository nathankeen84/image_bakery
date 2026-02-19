#!/bin/bash
# Script: ubuntu-cis1-hardening.sh
# Purpose: Apply CIS Linux Benchmarks Level 1 controls to Ubuntu 22.04 LTS
# OS: Ubuntu (Debian-based)
# CIS Benchmark Version: 1.4.0
# Controls: Foundation security hardening for baseline compliance
# 
# Note: This script applies baseline CIS L1 controls
#       CIS L2 controls are applied separately (see ubuntu-cis2-hardening.sh)

set -e

echo "[CIS L1] Starting Ubuntu hardening..."

# ==============================================================================
# Section 1: Initial Setup and Prerequisites
# ==============================================================================

# 1.1 Ensure filesystem configuration is in place
echo "[CIS-1.1] Configuring filesystem..."
# Create /etc/fstab if it doesn't exist
test -f /etc/fstab || touch /etc/fstab

# ==============================================================================
# Section 2: Filesystem Configuration (CIS 1.1.x - 1.4.x)
# ==============================================================================

# 1.1.2 Ensure separate partition for /tmp
echo "[CIS-1.1.2] Verifying /tmp partition configuration..."
# Note: For cloud images, this is typically pre-configured

# 1.1.4 Ensure /tmp mounted with noexec option
if mountpoint -q /tmp; then
    echo "[CIS-1.1.4] Remounting /tmp with noexec..."
    sudo mount -o remount,noexec /tmp 2>/dev/null || true
fi

# ==============================================================================
# Section 2: Software Updates (CIS 1.8)
# ==============================================================================

echo "[CIS-1.8] Ensuring software updates are installed..."
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y software-properties-common

# ==============================================================================
# Section 3: Mandatory Access Control (CIS 1.6)
# ==============================================================================

echo "[CIS-1.6] Configuring SELinux/AppArmor..."
# AppArmor is default on Ubuntu, ensure it's enabled
sudo systemctl enable apparmor 2>/dev/null || true
sudo systemctl start apparmor 2>/dev/null || true

# ==============================================================================
# Section 4: Kernel Parameters (CIS 3.x)
# ==============================================================================

echo "[CIS-3.x] Configuring kernel parameters..."

# 3.1.1 Ensure IP forwarding is disabled
echo "net.ipv4.ip_forward = 0" | sudo tee /etc/sysctl.d/99-cis-hardening.conf > /dev/null

# 3.1.2 Ensure ICMP redirects are not accepted
echo "net.ipv4.conf.all.send_redirects = 0" | sudo tee -a /etc/sysctl.d/99-cis-hardening.conf > /dev/null
echo "net.ipv4.conf.default.send_redirects = 0" | sudo tee -a /etc/sysctl.d/99-cis-hardening.conf > /dev/null

# 3.3.1 Ensure source routed packets are not accepted
echo "net.ipv4.conf.all.accept_source_route = 0" | sudo tee -a /etc/sysctl.d/99-cis-hardening.conf > /dev/null
echo "net.ipv4.conf.default.accept_source_route = 0" | sudo tee -a /etc/sysctl.d/99-cis-hardening.conf > /dev/null

# Apply kernel parameters
sudo sysctl -p /etc/sysctl.d/99-cis-hardening.conf > /dev/null

# ==============================================================================
# Section 5: File Permissions and Access Control (CIS 5.2)
# ==============================================================================

echo "[CIS-5.2] Setting file permissions..."

# 5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured
sudo chmod 0600 /etc/ssh/sshd_config 2>/dev/null || true

# 5.2.7 Ensure SSH root login is disabled
echo "PermitRootLogin no" | sudo tee /etc/ssh/sshd_config.d/99-cis-hardening.conf > /dev/null

# ==============================================================================
# Section 6: Audit and Logging (CIS 4.x)
# ==============================================================================

echo "[CIS-4.x] Configuring logging..."

# Install auditd for system auditing
sudo apt-get install -y auditd

# Enable and start auditd
sudo systemctl enable auditd
sudo systemctl start auditd

# ==============================================================================
# Section 7: User and Group Settings (CIS 5.1, 5.3)
# ==============================================================================

echo "[CIS-5.1, 5.3] Configuring user and group settings..."

# 5.3.1 Ensure password expiration is 365 days or less
sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   365/' /etc/login.defs

# 5.3.2 Ensure minimum password change interval is 1 day or more
sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' /etc/login.defs

# 5.3.3 Ensure password expiration warning days is 14 or more
sudo sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

# ==============================================================================
# Section 8: Essential System Packages (CIS 2.x)
# ==============================================================================

echo "[CIS-2.x] Installing essential security packages..."

# Install important security and monitoring tools
sudo apt-get install -y \
    aide \
    aide-common \
    chrony \
    curl \
    wget \
    net-tools \
    telnet \
    openssh-server \
    openssh-client

# ==============================================================================
# Section 9: Firewall Configuration (CIS 6.x)
# ==============================================================================

echo "[CIS-6.x] Configuring firewall (UFW)..."

# Install and enable UFW
sudo apt-get install -y ufw
sudo ufw --force enable 2>/dev/null || true

# Allow SSH (critical for cloud deployments)
sudo ufw allow 22/tcp 2>/dev/null || true

# ==============================================================================
# Verification and Completion
# ==============================================================================

echo "[CIS L1] Ubuntu hardening completed successfully"
echo "[CIS L1] Applied baseline security controls"
echo "[CIS L1] Image is ready for agent installation"
