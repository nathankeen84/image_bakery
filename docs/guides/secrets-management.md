# Secrets Management

## Overview

Image Bakery uses **Azure Key Vault** to securely store all sensitive information:
- Service principal credentials (Packer)
- API keys and authentication tokens
- Baseline agent credentials
- Certificates and TLS keys

**Never commit secrets to git!** All sensitive files are protected by `.gitignore`.

## Setup Process

### 1. Create Azure Service Principal for Packer

```bash
# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "ImageBakery-Packer" \
  --role "Contributor" \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID

# Output will be:
# {
#   "appId": "YOUR_CLIENT_ID",
#   "password": "YOUR_CLIENT_SECRET",
#   "tenant": "YOUR_TENANT_ID"
# }

# Save these values securely
```

### 2. Deploy Key Vault Infrastructure

```bash
# Navigate to terraform directory
cd terraform

# Copy the secrets template
cp secrets.tfvars.example secrets.tfvars

# Edit with your actual credentials (DO NOT COMMIT)
vim secrets.tfvars

# Initialize Terraform
terraform init

# Create the Key Vault and store all secrets
terraform apply \
  -var-file=terraform.tfvars \
  -var-file=secrets.tfvars
```

### 3. Verify Secrets in Key Vault

```bash
# List all secrets
az keyvault secret list \
  --vault-name image-bakery-kv \
  --query "[].name" -o table

# Retrieve a specific secret (test access)
az keyvault secret show \
  --vault-name image-bakery-kv \
  --name "packer-client-id" \
  --query value -o tsv
```

## Retrieving Secrets for Builds

### Option A: Using the Helper Script (Recommended)

```bash
# Load all secrets into environment variables
source shared/scripts/retrieve-keyvault-secrets.sh

# Verify secrets are loaded
echo $ARM_CLIENT_ID

# Now build with Packer
packer build -var-file=shared/variables/common.pkrvars.hcl \
  images/ubuntu/cis1/ubuntu-cis1.pkr.hcl
```

### Option B: Manual Environment Variables

```bash
# Export from Key Vault one by one
export ARM_CLIENT_ID=$(az keyvault secret show --vault-name image-bakery-kv --name "packer-client-id" --query value -o tsv)
export ARM_CLIENT_SECRET=$(az keyvault secret show --vault-name image-bakery-kv --name "packer-client-secret" --query value -o tsv)
export ARM_TENANT_ID=$(az keyvault secret show --vault-name image-bakery-kv --name "packer-tenant-id" --query value -o tsv)
export ARM_SUBSCRIPTION_ID=$(az keyvault secret show --vault-name image-bakery-kv --name "packer-subscription-id" --query value -o tsv)

# Load baseline agent secrets
export QUALYS_API_KEY=$(az keyvault secret show --vault-name image-bakery-kv --name "qualys-api-key" --query value -o tsv)
export NXLOG_API_KEY=$(az keyvault secret show --vault-name image-bakery-kv --name "nxlog-api-key" --query value -o tsv)
export XM_CYBER_API_KEY=$(az keyvault secret show --vault-name image-bakery-kv --name "xm-cyber-api-key" --query value -o tsv)
export NEWRELIC_LICENSE_KEY=$(az keyvault secret show --vault-name image-bakery-kv --name "newrelic-license-key" --query value -o tsv)
```

### Option C: Via Packer Variables

```bash
packer build \
  -var-file=shared/variables/common.pkrvars.hcl \
  -var "qualys_api_key=$(az keyvault secret show --vault-name image-bakery-kv --name qualys-api-key --query value -o tsv)" \
  -var "nxlog_api_key=$(az keyvault secret show --vault-name image-bakery-kv --name nxlog-api-key --query value -o tsv)" \
  images/ubuntu/cis1/ubuntu-cis1.pkr.hcl
```

## CI/CD Pipeline Integration

### Azure DevOps: Using Managed Identity

```yaml
# In azure-pipelines.yml
- task: AzureCLI@2
  inputs:
    azureSubscription: 'ImageBakery-ServiceConnection'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      # Retrieve secrets using managed identity
      export ARM_CLIENT_ID=$(az keyvault secret show --vault-name image-bakery-kv --name packer-client-id --query value -o tsv)
      export ARM_CLIENT_SECRET=$(az keyvault secret show --vault-name image-bakery-kv --name packer-client-secret --query value -o tsv)
      
      # Build image
      packer build -var-file=shared/variables/common.pkrvars.hcl images/ubuntu/cis1/ubuntu-cis1.pkr.hcl
```

### GitHub Actions: Using Azure Login

```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

- name: Retrieve Key Vault Secrets
  run: |
    export ARM_CLIENT_ID=$(az keyvault secret show --vault-name image-bakery-kv --name packer-client-id --query value -o tsv)
    export ARM_CLIENT_SECRET=$(az keyvault secret show --vault-name image-bakery-kv --name packer-client-secret --query value -o tsv)
    # ... continue with Packer build
```

## Managing Secrets

### Adding a New Secret

```bash
# Add to Key Vault
az keyvault secret set \
  --vault-name image-bakery-kv \
  --name "new-secret-name" \
  --value "secret-value"

# Update Terraform (add to variables.tf and secrets.tf)
# Re-apply Terraform to document in IaC
terraform apply -var-file=secrets.tfvars
```

### Rotating a Secret

```bash
# Update the secret value
az keyvault secret set \
  --vault-name image-bakery-kv \
  --name "packer-client-secret" \
  --value "new-secret-value"

# Verify update
az keyvault secret show \
  --vault-name image-bakery-kv \
  --name "packer-client-secret" \
  --query value -o tsv

# Test Packer build with new credentials
```

### Deleting a Secret

```bash
# Mark secret for deletion
az keyvault secret delete \
  --vault-name image-bakery-kv \
  --name "old-secret-name"

# Or hard delete immediately
az keyvault secret delete \
  --vault-name image-bakery-kv \
  --name "old-secret-name" \
  --inrecovery
```

## Security Best Practices

### ✅ Do's
- ✓ Store all credentials in Key Vault
- ✓ Use Terraform to manage secrets (IaC)
- ✓ Rotate credentials regularly (quarterly minimum)
- ✓ Use managed identities in CI/CD pipelines
- ✓ Enable Key Vault purge protection
- ✓ Enable Key Vault soft delete
- ✓ Audit secret access with Azure Monitor
- ✓ Use least-privilege service principals

### ❌ Don'ts
- ✗ Commit `secrets.tfvars` to git
- ✗ Print secrets to logs or build output
- ✗ Share credentials via email or Slack
- ✗ Use production secrets in development
- ✗ Store secrets in environment files locally
- ✗ Use broad permissions for service principals

## Troubleshooting

### Error: "Secret not found"

```bash
# Verify secret exists
az keyvault secret show \
  --vault-name image-bakery-kv \
  --name "packer-client-id"

# If missing, add it
az keyvault secret set \
  --vault-name image-bakery-kv \
  --name "packer-client-id" \
  --value "your-client-id"
```

### Error: "Permission denied"

```bash
# Check Key Vault access policies
az keyvault show \
  --vault-name image-bakery-kv \
  --query "properties.accessPolicies"

# Grant access if needed
az keyvault set-policy \
  --vault-name image-bakery-kv \
  --object-id <your-object-id> \
  --secret-permissions get list
```

### Error: "Azure authentication failed"

```bash
# Verify Azure CLI is authenticated
az account show

# Login if needed
az login

# Set correct subscription
az account set --subscription YOUR_SUBSCRIPTION_ID

# Verify access to Key Vault
az keyvault secret list --vault-name image-bakery-kv
```

## Key Vault Access Control

### Create Access Policy for Packer Service Principal

```bash
# Get service principal object ID
PRINCIPAL_ID=$(az ad sp show --id <client-id> --query id -o tsv)

# Grant secret access
az keyvault set-policy \
  --vault-name image-bakery-kv \
  --object-id $PRINCIPAL_ID \
  --secret-permissions get list
```

### Create Access Policy for Your User

```bash
# Get your object ID
MY_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)

# Grant full access (use judiciously)
az keyvault set-policy \
  --vault-name image-bakery-kv \
  --object-id $MY_OBJECT_ID \
  --secret-permissions get list set delete
```

## Monitoring & Auditing

### Enable Key Vault Logging

```bash
# Create storage account for logs
az storage account create \
  --name kvauitlogs \
  --resource-group image-bakery-rg

# Enable diagnostic settings
az monitor diagnostic-settings create \
  --resource /subscriptions/YOUR_SUBSCRIPTION_ID/resourcegroups/image-bakery-rg/providers/microsoft.keyvault/vaults/image-bakery-kv \
  --name kv-audit \
  --storage-account kvauitlogs \
  --logs '[{"category":"AuditEvent","enabled":true}]'
```

### View Audit Logs

```bash
# List recent secret access events
az keyvault secret list \
  --vault-name image-bakery-kv \
  --query "[].attributes"
```
