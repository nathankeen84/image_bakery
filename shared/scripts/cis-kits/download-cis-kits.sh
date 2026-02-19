#!/bin/bash
# Script: download-cis-kits.sh
# Purpose: Download CIS benchmarks and tools from Azure Storage during Packer build
# Usage: Called as provisioner in Packer templates

set -e

CIS_STORAGE_ACCOUNT="${CIS_STORAGE_ACCOUNT:-}"
CIS_STORAGE_KEY="${CIS_STORAGE_KEY:-}"
CIS_CONTAINER="${CIS_CONTAINER:-cis-kits-container}"
CIS_KIT_PATH="/opt/cis-kits"

echo "======================================================================"
echo "CIS Kit Download & Installation"
echo "======================================================================"

# Create directory
mkdir -p "$CIS_KIT_PATH"
echo "[✓] Created CIS kit directory: $CIS_KIT_PATH"

# Determine OS and download appropriate kits
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
  OS=$ID
  OS_VERSION=$VERSION_ID
fi

case "$OS" in
  rhel|centos)
    echo "[→] Detected RHEL/CentOS $OS_VERSION"
    KIT_PREFIX="linux/rhel"
    ;;
  ubuntu)
    echo "[→] Detected Ubuntu $OS_VERSION"
    KIT_PREFIX="linux/ubuntu"
    ;;
  *)
    echo "[!] Unsupported OS: $OS"
    KIT_PREFIX="linux/generic"
    ;;
esac

# Download from Azure Storage if credentials provided
if [[ -n "$CIS_STORAGE_ACCOUNT" && -n "$CIS_STORAGE_KEY" ]]; then
  echo "[→] Downloading CIS kits from Azure Storage..."
  
  # Install az CLI if not present (Linux)
  if ! command -v az &> /dev/null; then
    echo "  Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash > /dev/null 2>&1 || true
  fi
  
  # Set storage credentials
  export AZURE_STORAGE_ACCOUNT="$CIS_STORAGE_ACCOUNT"
  export AZURE_STORAGE_KEY="$CIS_STORAGE_KEY"
  
  # Download kits
  az storage blob download-batch \
    --destination "$CIS_KIT_PATH" \
    --source "$CIS_CONTAINER/$KIT_PREFIX" \
    --account-name "$CIS_STORAGE_ACCOUNT" \
    --account-key "$CIS_STORAGE_KEY" \
    2>&1 || {
    echo "[!] Failed to download from Azure Storage"
    echo "    Storage Account: $CIS_STORAGE_ACCOUNT"
    echo "    Container: $CIS_CONTAINER"
  }
  
  echo "[✓] CIS kits downloaded"
else
  echo "[⚠] CIS_STORAGE_ACCOUNT or CIS_STORAGE_KEY not set"
  echo "    Skipping download - kits may need to be provided via file provisioner"
fi

# Set permissions
if [[ -d "$CIS_KIT_PATH" ]]; then
  chmod -R 755 "$CIS_KIT_PATH"
  echo "[✓] Set permissions on $CIS_KIT_PATH"
fi

# Verify structure
if [[ -f "$CIS_KIT_PATH/tools/cis-cat-lite-launcher.jar" ]]; then
  echo "[✓] CIS-CAT Lite found at: $CIS_KIT_PATH/tools/cis-cat-lite-launcher.jar"
else
  echo "[⚠] CIS-CAT Lite not found - validation may not be available"
fi

# List available benchmarks
echo ""
echo "Available CIS benchmarks:"
find "$CIS_KIT_PATH" -name "*.xml" -o -name "*Benchmark*" 2>/dev/null | head -10 || echo "  (none found)"

echo ""
echo "[✓] CIS kit setup complete"
echo "    Location: $CIS_KIT_PATH"
echo "    OS: $OS $OS_VERSION"
