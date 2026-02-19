#!/bin/bash
# Script: retrieve-keyvault-secrets.sh
# Purpose: Retrieve secrets from Azure Key Vault and set as environment variables for Packer
# Usage: source retrieve-keyvault-secrets.sh

set -e

# Configuration
VAULT_NAME="${KEY_VAULT_NAME:-image-bakery-kv}"
RESOURCE_GROUP="${RESOURCE_GROUP:-image-bakery-rg}"

echo "[SECRETS] Retrieving secrets from Azure Key Vault: $VAULT_NAME"

# Retrieve Packer credentials
echo "[SECRETS] Loading Packer credentials..."
export ARM_CLIENT_ID=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "packer-client-id" --query value -o tsv 2>/dev/null)
export ARM_CLIENT_SECRET=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "packer-client-secret" --query value -o tsv 2>/dev/null)
export ARM_TENANT_ID=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "packer-tenant-id" --query value -o tsv 2>/dev/null)
export ARM_SUBSCRIPTION_ID=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "packer-subscription-id" --query value -o tsv 2>/dev/null)

# Retrieve Qualys secrets
echo "[SECRETS] Loading Qualys agent credentials..."
export QUALYS_API_KEY=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "qualys-api-key" --query value -o tsv 2>/dev/null || echo "")
export QUALYS_API_URL=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "qualys-api-url" --query value -o tsv 2>/dev/null || echo "")
export QUALYS_USERNAME=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "qualys-username" --query value -o tsv 2>/dev/null || echo "")
export QUALYS_PASSWORD=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "qualys-password" --query value -o tsv 2>/dev/null || echo "")

# Retrieve NXLog secrets
echo "[SECRETS] Loading NXLog agent credentials..."
export NXLOG_API_KEY=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "nxlog-api-key" --query value -o tsv 2>/dev/null || echo "")
export NXLOG_ENDPOINT=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "nxlog-endpoint" --query value -o tsv 2>/dev/null || echo "")

# Retrieve XM Cyber secrets
echo "[SECRETS] Loading XM Cyber agent credentials..."
export XM_CYBER_API_KEY=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "xm-cyber-api-key" --query value -o tsv 2>/dev/null || echo "")
export XM_CYBER_API_URL=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "xm-cyber-api-url" --query value -o tsv 2>/dev/null || echo "")

# Retrieve New Relic secrets
echo "[SECRETS] Loading New Relic agent credentials..."
export NEWRELIC_API_KEY=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "newrelic-api-key" --query value -o tsv 2>/dev/null || echo "")
export NEWRELIC_LICENSE_KEY=$(az keyvault secret show --vault-name "$VAULT_NAME" --name "newrelic-license-key" --query value -o tsv 2>/dev/null || echo "")

echo "[SECRETS] ✓ All secrets loaded from Key Vault"
echo "[SECRETS] Ready for Packer build"
