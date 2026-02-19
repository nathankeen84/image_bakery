#!/bin/bash
# Script: ubuntu-cis2-hardening.sh
# Purpose: Apply CIS Linux Benchmarks Level 2 INCREMENTAL controls to Ubuntu
# OS: Ubuntu (22.04 LTS)
# CIS Benchmark Version: 1.4.0
# Controls: Additional security controls beyond Level 1
#
# IMPORTANT: This script applies INCREMENTAL CIS L2 controls
#            Run ubuntu-cis1-hardening.sh FIRST, then this script
#            L2 controls are additive; do NOT duplicate L1 controls

set -e

echo "[CIS L2] Starting Ubuntu incremental hardening (Level 2)..."
echo "[CIS L2] Note: This assumes CIS L1 controls have been applied"
echo ""

# ==============================================================================
# Section 1: Level 2 Specific Configuration
# ==============================================================================

echo "[CIS L2-1.1] Applying stricter filesystem security..."

# 1.5.3 Ensure nodev option set on separate partitions
if mountpoint -q /boot; then
    echo "[CIS L2-1.5.3] Remounting /boot with nodev..."
    sudo mount -o remount,nodev /boot 2>/dev/null || true
fi

if mountpoint -q /var; then
    echo "[CIS L2-1.5.4] Remounting /var with nosuid and nodev..."
    sudo mount -o remount,nosuid,nodev /var 2>/dev/null || true
fi

if mountpoint -q /home; then
    echo "[CIS L2-1.5.x] Remounting /home with nodev and nosuid..."
    sudo mount -o remount,nodev,nosuid /home 2>/dev/null || true
fi

# ==============================================================================
# Section 2: Network Hardening (L2 enhancements)
# ==============================================================================

echo "[CIS L2-3.x] Applying stricter network protocols..."

# Disable IPv6 if not needed (organization policy dependent)
# Note: Commented out - enable only if IPv6 is not required
# echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf
# echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf

# Enable additional ICMP protections
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" | sudo tee -a /etc/sysctl.conf

# Enable IP forwarding control
echo "net.ipv4.ip_forward = 0" | sudo tee -a /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding = 0" | sudo tee -a /etc/sysctl.conf

# Enable SYN cookies (SYN flood protection)
echo "net.ipv4.tcp_syncookies = 1" | sudo tee -a /etc/sysctl.conf

# Apply sysctl settings
sudo sysctl -p > /dev/null 2>&1 || true

echo "[CIS L2-3.x] Network hardening (L2) applied"

# ==============================================================================
# Section 3: Access Control (L2 enhancements)
# ==============================================================================

echo "[CIS L2-5.x] Applying stricter access controls..."

# 5.4.4 Ensure default user umask is 027 or more restrictive
echo "umask 027" | sudo tee -a /etc/profile.d/umask.sh
echo "umask 027" | sudo tee -a /etc/bashrc

# 5.5.1.1 Set Password Expiration Days
echo "PASS_MAX_DAYS 90" | sudo tee -a /etc/login.defs

# 5.5.1.2 Set Password Change Minimum Number of Days
echo "PASS_MIN_DAYS 1" | sudo tee -a /etc/login.defs

# 5.5.1.3 Set Password Expiring Warning Days
echo "PASS_WARN_AGE 14" | sudo tee -a /etc/login.defs

# 5.5.2 Ensure system accounts are secured
echo "[CIS L2-5.5.2] Securing system accounts..."
awk -F: '($1!~/(root|sync|shutdown|halt)/ && $3<1000 && $7!~/\/usr\/sbin\/nologin/ && $7!~/(\/bin)?\/false/) {print $1}' /etc/passwd | while read -r user; do
    echo "[CIS L2-5.5.2] Setting nologin for system account: $user"
    sudo usermod -s /usr/sbin/nologin "$user" 2>/dev/null || true
done

# 5.6 Restrict access to the su command
echo "[CIS L2-5.6] Restricting su command access..."
echo "auth required pam_wheel.so use_uid" | sudo tee -a /etc/pam.d/su

# ==============================================================================
# Section 4: Logging and Auditing (L2 enhancements)
# ==============================================================================

echo "[CIS L2-4.x] Enhancing audit and logging..."

# Add additional audit rules for L2
echo "-a always,exit -F path=/etc/sudoers -F perm=wa -F auid>=1000 -F auid!=-1 -k scope" | \
  sudo tee -a /etc/audit/rules.d/image_bakery.rules

echo "-a always,exit -F arch=b64 -S execve -F uid=0 -k exec" | \
  sudo tee -a /etc/audit/rules.d/image_bakery.rules

# Restart auditd with new rules
sudo systemctl restart auditd || true

# ==============================================================================
# Section 5: Additional Security Services
# ==============================================================================

echo "[CIS L2-5.x] Installing additional security tools..."

# Install AIDE (File Integrity Monitoring)
echo "[CIS L2] Installing AIDE for file integrity monitoring..."
sudo apt-get install -y aide aide-common

# Initialize AIDE database
sudo aideinit 2>/dev/null || true

# ==============================================================================
# Section 6: Disable Unnecessary Services (L2)
# ==============================================================================

echo "[CIS L2-6.x] Disabling unnecessary services..."

# Disable uncommon network protocols
echo "[CIS L2-6.x] Disabling SCTP..."
echo "install sctp /bin/true" | sudo tee -a /etc/modprobe.d/sctp-disable.conf

echo "[CIS L2-6.x] Disabling DCCP..."
echo "install dccp /bin/true" | sudo tee -a /etc/modprobe.d/dccp-disable.conf

echo "[CIS L2-6.x] Disabling RDS..."
echo "install rds /bin/true" | sudo tee -a /etc/modprobe.d/rds-disable.conf

echo "[CIS L2-6.x] Disabling TIPC..."
echo "install tipc /bin/true" | sudo tee -a /etc/modprobe.d/tipc-disable.conf

# ==============================================================================
# Section 7: Kernel Hardening (L2)
# ==============================================================================

echo "[CIS L2-7.x] Applying kernel hardening parameters..."

# Enable ASLR
echo "kernel.randomize_va_space = 2" | sudo tee -a /etc/sysctl.conf

# Restrict Kernel Module Loading
echo "kernel.modules_disabled = 1" | sudo tee -a /etc/sysctl.conf

# Restrict access to kernel logs
echo "kernel.dmesg_restrict = 1" | sudo tee -a /etc/sysctl.conf

# Restrict access to /proc/sys
echo "kernel.sysrq = 0" | sudo tee -a /etc/sysctl.conf

# Apply kernel parameters
sudo sysctl -p > /dev/null 2>&1 || true

echo "[CIS L2-7.x] Kernel hardening applied"

# ==============================================================================
# Final: Summary
# ==============================================================================

echo ""
echo "[CIS L2] Ubuntu incremental hardening (Level 2) completed!"
echo "[CIS L2] Additional controls applied:"
echo "  • Stricter filesystem permissions (nodev, nosuid)"
echo "  • Enhanced network security (SYN cookies, ICMP protection)"
echo "  • Stricter password policies (90-day expiration)"
echo "  • System account lockdown"
echo "  • Su command restriction"
echo "  • Enhanced audit rules"
echo "  • File integrity monitoring (AIDE)"
echo "  • Disabled uncommon protocols (SCTP, DCCP, RDS, TIPC)"
echo "  • Kernel hardening (ASLR, dmesg restrict)"
echo "[CIS L2] Combined L1 + L2 = Comprehensive CIS compliance"
echo ""
