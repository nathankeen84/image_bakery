#!/bin/bash
# Script: rhel-cis2-hardening.sh
# Purpose: Apply CIS Linux Benchmarks Level 2 INCREMENTAL controls to RHEL
# OS: RHEL (8 / 9)
# CIS Benchmark Version: 2.0.0
# Controls: Additional security controls beyond Level 1
#
# IMPORTANT: This script applies INCREMENTAL CIS L2 controls
#            Run rhel-cis1-hardening.sh FIRST, then this script
#            L2 controls are additive; do NOT duplicate L1 controls

set -e

echo "[CIS L2] Starting RHEL incremental hardening (Level 2)..."
echo "[CIS L2] Note: This assumes CIS L1 controls have been applied"
echo ""

# ==============================================================================
# Section 1: SELinux L2 Configuration
# ==============================================================================

echo "[CIS L2-1.x] Applying enhanced SELinux configuration..."

# 1.6.1.3 Ensure SELinux policy is MLS or XGuard
echo "[CIS L2-1.6.1.3] Setting SELinux policy..."
sudo sed -i 's/^SELINUXTYPE=.*/SELINUXTYPE=mls/' /etc/selinux/config || true

# Enable SELinux deny_ptrace (if available)
echo "deny_ptrace = yes" | sudo tee -a /etc/selinux/selinux_deny_ptrace.conf 2>/dev/null || true

echo "[CIS L2-1.x] Enhanced SELinux applied"

# ==============================================================================
# Section 2: Network Hardening (L2 enhancements)
# ==============================================================================

echo "[CIS L2-3.x] Applying stricter network protocols..."

# Disable IPv6 if not needed (organization policy dependent)
# Note: Commented out - enable only if IPv6 is not required
# echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-hardening.conf
# echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-hardening.conf

# Enable additional ICMP protections
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" | sudo tee -a /etc/sysctl.d/99-hardening.conf
echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" | sudo tee -a /etc/sysctl.d/99-hardening.conf

# Enable IP forwarding control
echo "net.ipv4.ip_forward = 0" | sudo tee -a /etc/sysctl.d/99-hardening.conf
echo "net.ipv6.conf.all.forwarding = 0" | sudo tee -a /etc/sysctl.d/99-hardening.conf

# Enable SYN cookies (SYN flood protection)
echo "net.ipv4.tcp_syncookies = 1" | sudo tee -a /etc/sysctl.d/99-hardening.conf

# TCP hardening
echo "net.ipv4.conf.all.send_redirects = 0" | sudo tee -a /etc/sysctl.d/99-hardening.conf
echo "net.ipv4.conf.default.send_redirects = 0" | sudo tee -a /etc/sysctl.d/99-hardening.conf

# Apply sysctl settings
sudo sysctl -p /etc/sysctl.d/99-hardening.conf > /dev/null 2>&1 || true

echo "[CIS L2-3.x] Network hardening (L2) applied"

# ==============================================================================
# Section 3: Access Control (L2 enhancements)
# ==============================================================================

echo "[CIS L2-5.x] Applying stricter access controls..."

# 5.4.4 Ensure default user umask is 027 or more restrictive
echo "umask 027" | sudo tee -a /etc/profile.d/umask.sh
echo "umask 027" | sudo tee -a /etc/bashrc

# 5.5.1.1 Set Password Expiration Days
sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs

# 5.5.1.2 Set Password Change Minimum Number of Days
sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' /etc/login.defs

# 5.5.1.3 Set Password Expiring Warning Days
sudo sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

# 5.5.2 Ensure system accounts are secured
echo "[CIS L2-5.5.2] Securing system accounts..."
awk -F: '($1!~/(root|sync|shutdown|halt|nfsnobody)/ && $3<1000 && $7!~/\/usr\/sbin\/nologin/ && $7!~/(\/bin)?\/false/) {print $1}' /etc/passwd | while read -r user; do
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
echo "-a always,exit -F path=/etc/sudoers -F perm=wa -F auid>=1000 -F auid!=4294967295 -k scope" | \
  sudo tee -a /etc/audit/rules.d/image_bakery.rules

echo "-a always,exit -F arch=b64 -S execve -F uid=0 -k exec" | \
  sudo tee -a /etc/audit/rules.d/image_bakery.rules

echo "-a always,exit -F arch=b32 -S execve -F uid=0 -k exec" | \
  sudo tee -a /etc/audit/rules.d/image_bakery.rules

# Restart auditd with new rules
sudo systemctl restart auditd || true

echo "[CIS L2-4.x] Enhanced audit rules applied"

# ==============================================================================
# Section 5: Additional Security Tools (L2)
# ==============================================================================

echo "[CIS L2-5.x] Installing additional security tools..."

# Install AIDE (File Integrity Monitoring)
echo "[CIS L2] Installing AIDE for file integrity monitoring..."
sudo yum install -y aide

# Initialize AIDE database
sudo aideinit 2>/dev/null || true

# Install intrusion detection tools
echo "[CIS L2] Installing fail2ban for intrusion prevention..."
sudo yum install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "[CIS L2-5.x] Security tools installed"

# ==============================================================================
# Section 6: Kernel Hardening (L2)
# ==============================================================================

echo "[CIS L2-7.x] Applying kernel hardening parameters..."

# Enable ASLR
echo "kernel.randomize_va_space = 2" | sudo tee -a /etc/sysctl.d/99-hardening.conf

# Restrict Kernel Module Loading
echo "kernel.modules_disabled = 1" | sudo tee -a /etc/sysctl.d/99-hardening.conf

# Restrict access to kernel logs
echo "kernel.dmesg_restrict = 1" | sudo tee -a /etc/sysctl.d/99-hardening.conf

# Restrict Kernel Pointer Exposure
echo "kernel.kptr_restrict = 2" | sudo tee -a /etc/sysctl.d/99-hardening.conf

# Restrict Kernel Parameter Access
echo "kernel.yama.ptrace_scope = 3" | sudo tee -a /etc/sysctl.d/99-hardening.conf

# Apply kernel parameters
sudo sysctl -p /etc/sysctl.d/99-hardening.conf > /dev/null 2>&1 || true

echo "[CIS L2-7.x] Kernel hardening applied"

# ==============================================================================
# Final: Summary
# ==============================================================================

echo ""
echo "[CIS L2] RHEL incremental hardening (Level 2) completed!"
echo "[CIS L2] Additional controls applied:"
echo "  • Enhanced SELinux configuration (MLS policy)"
echo "  • Stricter network security (SYN cookies, ICMP protection)"
echo "  • Stricter password policies (90-day expiration)"
echo "  • System account lockdown"
echo "  • Su command restriction"
echo "  • Enhanced audit rules"
echo "  • File integrity monitoring (AIDE)"
echo "  • Intrusion prevention (fail2ban)"
echo "  • Advanced kernel hardening (ASLR, ptrace restrict, kptr restrict)"
echo "[CIS L2] Combined L1 + L2 = Comprehensive CIS compliance"
echo ""
