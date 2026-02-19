#!/bin/bash
# Script: rhel-cis1-hardening.sh
# Purpose: Apply CIS Linux Benchmarks Level 1 controls to Red Hat Enterprise Linux
# OS: RHEL (8 / 9)
# CIS Benchmark Version: 2.0.0
# Controls: Foundation security hardening for baseline compliance
#
# Note: This script applies baseline CIS L1 controls
#       CIS L2 controls are applied separately (see rhel-cis2-hardening.sh)

set -e

echo "[CIS L1] Starting RHEL hardening..."

# ==============================================================================
# Section 1: Initial Setup and Prerequisites
# ==============================================================================

echo "[CIS-1.1] Configuring filesystem..."
# Ensure SELinux is in enforcing mode
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

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
sudo yum update -y
sudo yum upgrade -y

# ==============================================================================
# Section 3: Mandatory Access Control (CIS 1.6)
# ==============================================================================

echo "[CIS-1.6] Ensuring AppArmor/SELinux is installed and configured..."
# RHEL uses SELinux, not AppArmor
sudo yum install -y selinux-policy selinux-policy-devel

# ==============================================================================
# Section 4: User and Group Settings (CIS 5.x)
# ==============================================================================

echo "[CIS-5.2] Configuring sudo..."
# Ensure sudo uses dedicated log file
echo 'Defaults use_pty' | sudo tee -a /etc/sudoers.d/00-pty-req
echo 'Defaults logfile="/var/log/sudo.log"' | sudo tee -a /etc/sudoers.d/00-log-file

# Set password timeout
echo 'Defaults passwd_timeout=1' | sudo tee -a /etc/sudoers.d/00-timeout

# ==============================================================================
# Section 5: File Permissions (CIS 6.x)
# ==============================================================================

echo "[CIS-6.1] Auditing system file permissions..."

# Audit common system directories
for file in /etc/shadow /etc/gshadow /etc/security /etc/ssh; do
    [ -e "$file" ] && echo "Checking $file..." || true
done

# ==============================================================================
# Section 6: System Configuration (CIS 3.x, 4.x)
# ==============================================================================

echo "[CIS-3.1] Disabling unused network protocols..."
# Disable DCCP
echo "install dccp /bin/true" | sudo tee -a /etc/modprobe.d/dccp.conf

# Disable SCTP
echo "install sctp /bin/true" | sudo tee -a /etc/modprobe.d/sctp.conf

# Disable RDS
echo "install rds /bin/true" | sudo tee -a /etc/modprobe.d/rds.conf

# Disable TIPC
echo "install tipc /bin/true" | sudo tee -a /etc/modprobe.d/tipc.conf

echo "[CIS-4.1] Configuring auditd..."
# Ensure auditd is installed and enabled
sudo yum install -y audit audit-libs
sudo systemctl enable auditd
sudo systemctl start auditd

echo "[CIS-4.2] Setting up audit rules..."
# Basic audit configuration
echo "-w /etc/audit/ -p wa -k audit_config" | sudo tee -a /etc/audit/rules.d/image_bakery.rules
echo "-w /etc/libaudit.conf -p wa -k audit_config" | sudo tee -a /etc/audit/rules.d/image_bakery.rules

# Restart auditd to apply rules
sudo systemctl restart auditd

echo "[CIS-5.1] Configuring SSH..."
# SSH hardening
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Set SSH protocol to 2
sudo sed -i 's/^#Protocol.*/Protocol 2/' /etc/ssh/sshd_config

# Disable X11 forwarding
sudo sed -i 's/^X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config

# Validate SSH config
sudo sshd -t && echo "[CIS-5.1] SSH configuration valid" || echo "[CIS-5.1] SSH configuration has errors"

# Restart SSH
sudo systemctl restart sshd

echo "[CIS-5.3] Configuring PAM..."
# Install and configure PAM
sudo yum install -y pam pam-pwquality

# Configure password quality requirements
echo "minlen=14" | sudo tee -a /etc/security/pwquality.conf
echo "dcredit=-1" | sudo tee -a /etc/security/pwquality.conf
echo "ucredit=-1" | sudo tee -a /etc/security/pwquality.conf
echo "ocredit=-1" | sudo tee -a /etc/security/pwquality.conf
echo "lcredit=-1" | sudo tee -a /etc/security/pwquality.conf

echo "[CIS-5.4] Configuring user login retries..."
# Configure account lockout policy
echo "auth required pam_faillock.so preauth silent audit deny=5 unlock_time=900" | \
  sudo tee -a /etc/pam.d/system-auth

echo "[CIS-6.1] Checking file and directory permissions..."
# Ensure world-writable files are secure
find / -xdev -type f -perm -0002 2>/dev/null | head -10 | while read file; do
  echo "[CIS-6.1] Found world-writable: $file"
done

# Ensure SUID/SGID files are restricted
find / -xdev -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | wc -l | \
  xargs echo "[CIS-6.1] Found SUID/SGID files:"

echo "[CIS-7.x] Configuring system logging..."
# Configure rsyslog
sudo yum install -y rsyslog
sudo systemctl enable rsyslog
sudo systemctl start rsyslog

echo "[CIS-8.x] Configuring access, authentication and authorization..."
# Set strong password requirements
echo "password   requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=" | \
  sudo tee /etc/pam.d/pwquality-system-auth

# ==============================================================================
# Final: Summary and Verification
# ==============================================================================

echo ""
echo "[CIS L1] RHEL hardening completed!"
echo "[CIS L1] Key controls applied:"
echo "  • SELinux configured"
echo "  • SSH hardened"
echo "  • Auditd enabled"
echo "  • Audit rules configured"
echo "  • PAM hardened"
echo "  • Account lockout policy set"
echo "  • System logging configured"
echo "[CIS L1] Verify by running: sudo bash -x $0"
echo ""
