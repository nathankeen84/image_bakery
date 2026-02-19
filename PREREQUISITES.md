# Prerequisites — Image Bakery

This document outlines all requirements before deploying infrastructure or building images.

## 1. Local Development Environment

### Required Tools

| Tool | Version | Purpose |
| --- | --- | --- |
| **Terraform** | >= 1.5 | Infrastructure-as-code provisioning |
| **Azure CLI** | >= 2.50 | Azure resource management & authentication |
| **Packer** | >= 1.15 | VM image building orchestration |
| **PowerShell** | >= 7.0 | Windows-based provisioners (if building Windows images) |
| **Git** | >= 2.40 | Version control |

### Installation

**macOS:**

```bash
# Terraform
brew install terraform

# Azure CLI
brew install azure-cli

# Packer
brew install packer

# PowerShell (optional, for Windows image builds)
brew install powershell
```

**Linux (Ubuntu):**

```bash
# Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Packer
wget https://releases.hashicorp.com/packer/1.15.0/packer_1.15.0_linux_amd64.zip
unzip packer_1.15.0_linux_amd64.zip
sudo mv packer /usr/local/bin/
```

**Windows (PowerShell):**

```powershell
# Using Chocolatey
choco install terraform azure-cli packer powershell -y
```

### Verification

```bash
terraform version      # Should output >= 1.5.0
az --version          # Should output >= 2.50.0
packer version        # Should output >= 1.15.0
```

---

## 2. Azure Subscription & Authentication

### Required Azure Subscription

- **Resource Group**: `image-bakery-rg` (created by Terraform)
- **Subscription Permissions**: Contributor role minimum (for creating all resources)
- **Quota**: Ensure adequate quota for:
  - Compute Gallery (1)
  - Storage Account (1)
  - Key Vault (1)
  - VNet + Subnets (required for build VMs)
  - VM builds (temporary, auto-deleted after image capture)

### Azure CLI Authentication

```bash
# Login to Azure
az login

# Set subscription (if multiple subscriptions exist)
az account set --subscription "d72ed3be-46f3-4feb-b6ca-53511fa25952"

# Verify authentication
az account show
```

Output should show:

```json
{
  "id": "d72ed3be-46f3-4feb-b6ca-53511fa25952",
  "state": "Enabled",
  "isDefault": true
}
```

---

## 3. Azure Service Principal (CRITICAL)

**Packer builds require a pre-existing Azure service principal.** This SP authenticates Packer with Azure and allows image publishing to Compute Gallery.

### Create Service Principal

```bash
az ad sp create-for-rbac \
  --name "image-bakery-packer" \
  --role contributor \
  --scopes /subscriptions/d72ed3be-46f3-4feb-b6ca-53511fa25952
```

**Output (save this):**

```json
{
  "appId": "<CLIENT_ID>",
  "displayName": "image-bakery-packer",
  "password": "<CLIENT_SECRET>",
  "tenant": "<TENANT_ID>"
}
```

### Configure Terraform

Update `terraform/terraform.tfvars`:

```hcl
client_id = "<CLIENT_ID>"  # From appId above
# client_secret is read from env: ARM_CLIENT_SECRET
# tenant_id is read from env: ARM_TENANT_ID
```

### Environment Variables for Terraform

```bash
export ARM_CLIENT_ID="<CLIENT_ID>"
export ARM_CLIENT_SECRET="<CLIENT_SECRET>"
export ARM_TENANT_ID="<TENANT_ID>"
export ARM_SUBSCRIPTION_ID="d72ed3be-46f3-4feb-b6ca-53511fa25952"
```

**Tip:** Add these to `.env` or shell profile for persistence:

```bash
# ~/.zshrc or ~/.bashrc
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_TENANT_ID="..."
export ARM_SUBSCRIPTION_ID="..."
```

### Verify Service Principal

```bash
az ad sp show --id <CLIENT_ID>
```

---

## 4. CIS Benchmarks (Required for Hardening Scripts)

### Download CIS Kits

Image Bakery applies **CIS Level 1** and **CIS Level 2** hardening. The CIS benchmark PDFs are not included in the repository; you must download them from [CIS.org](https://www.cisecurity.org/cis-benchmarks/).

**Required Benchmarks:**

| Benchmark | Purpose |
| --- | --- |
| **CIS Microsoft Windows Server 2019** | Windows Server 2019 hardening |
| **CIS Microsoft Windows Server 2022** | Windows Server 2022 hardening |
| **CIS Microsoft Windows Server 2025** | Windows Server 2025 hardening |
| **CIS Red Hat Enterprise Linux 8** | RHEL 8 hardening |
| **CIS Red Hat Enterprise Linux 9** | RHEL 9 hardening |
| **CIS Ubuntu Linux 20.04 LTS** | Ubuntu 20.04 hardening |
| **CIS Ubuntu Linux 22.04 LTS** | Ubuntu 22.04 LTS hardening |
| **CIS Azure Linux 3.0** | Azure Linux 3.0 hardening |

### Download Steps

1. Visit [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/) (requires account)
2. Download PDF for each benchmark above
3. Place in `shared/scripts/cis-kits/` directory:

  ```text
  shared/scripts/cis-kits/
  ├── CIS_Microsoft_Windows_Server_2019_Benchmark_v1.*.pdf
  ├── CIS_Microsoft_Windows_Server_2022_Benchmark_v1.*.pdf
  ├── CIS_Microsoft_Windows_Server_2025_Benchmark_v1.*.pdf
  ├── CIS_Red_Hat_Enterprise_Linux_8_Benchmark_v1.*.pdf
  ├── CIS_Red_Hat_Enterprise_Linux_9_Benchmark_v1.*.pdf
  ├── CIS_Ubuntu_Linux_20.04_LTS_Benchmark_v1.*.pdf
  ├── CIS_Ubuntu_Linux_22.04_LTS_Benchmark_v1.*.pdf
  └── CIS_Azure_Linux_3.0_Benchmark_v1.*.pdf
  ```

### Upload to Azure Storage

After Terraform provisions the infrastructure:

```bash
# Get storage account name
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)

# Upload CIS kits
az storage blob upload-batch \
  --destination cis-kits \
  --source shared/scripts/cis-kits/ \
  --account-name $STORAGE_ACCOUNT \
  --account-key $(az storage account keys list \
    --resource-group image-bakery-rg \
    --account-name $STORAGE_ACCOUNT \
    --query '[0].value' -o tsv)
```

---

## 5. Azure Infrastructure (Terraform)

### Prerequisites for Terraform Apply

- ✅ Terraform >= 1.5 installed
- ✅ Azure CLI authenticated (`az login`)
- ✅ Service principal created (see Section 3)
- ✅ Environment variables set (ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID)
- ✅ Subscription ID in `terraform/terraform.tfvars`
- ✅ `terraform/tfplan` generated via `terraform plan -out=tfplan`

### Terraform Deployment Steps

```bash
cd terraform/

# Validate configuration
terraform validate

# Initialize Terraform (downloads provider plugins)
terraform init

# Generate plan
terraform plan -out=tfplan

# Review and apply
terraform apply tfplan
```

**Expected Output:**

```text
Apply complete! Resources: 28 added, 0 changed, 0 destroyed.

Outputs:
  gallery_id = "..."
  gallery_name = "imageBakeryGallery"
  key_vault_id = "..."
  storage_account_id = "..."
```

---

## 6. Packer Build Environment

### Prerequisites for Packer Builds

- ✅ Packer >= 1.15 installed
- ✅ Terraform infrastructure deployed (Section 5)
- ✅ CIS kits uploaded to storage (Section 4)
- ✅ Azure authentication configured (Section 2)
- ✅ Service principal credentials available

### Packer Variables

Packer reads from `shared/variables/common.pkrvars.hcl`:

```hcl
subscription_id = "d72ed3be-46f3-4feb-b6ca-53511fa25952"
resource_group  = "image-bakery-rg"
gallery_name    = "imageBakeryGallery"
client_id       = "<SERVICE_PRINCIPAL_CLIENT_ID>"
```

### Environment for Packer

```bash
export PACKER_LOG=1  # Enable debug logging (optional)
export ARM_CLIENT_ID="<CLIENT_ID>"
export ARM_CLIENT_SECRET="<CLIENT_SECRET>"
export ARM_TENANT_ID="<TENANT_ID>"
export ARM_SUBSCRIPTION_ID="d72ed3be-46f3-4feb-b6ca-53511fa25952"
```

### Verify Packer Template

```bash
packer validate -var-file=shared/variables/common.pkrvars.hcl \
  images/ubuntu/2204/cis1/ubuntu-2204-cis1.pkr.hcl
```

---

## 7. CI/CD Pipeline (Azure DevOps)

### Prerequisites for Pipeline Execution

- ✅ Azure DevOps project created
- ✅ Git repository mirrored/pushed to Azure Repos
- ✅ Service connection configured:
  - **Type**: Azure Resource Manager
  - **Authentication**: Service Principal
  - **Credentials**: Same as Section 3 (image-bakery-packer)
- ✅ Pipeline YAML files in `pipelines/` directory
- ✅ Pipeline variables configured:
  - `SUBSCRIPTION_ID`
  - `RESOURCE_GROUP`
  - `GALLERY_NAME`

### Create Service Connection in Azure DevOps

```bash
# In Azure DevOps Portal:
# 1. Project Settings → Service Connections
# 2. New Service Connection → Azure Resource Manager
# 3. Authentication method: Service Principal (manual)
# 4. Subscription ID: d72ed3be-46f3-4feb-b6ca-53511fa25952
# 5. Service Principal ID: <CLIENT_ID>
# 6. Service Principal Key: <CLIENT_SECRET>
# 7. Tenant ID: <TENANT_ID>
# 8. Name: image-bakery-packer
```

---

## 8. Network & Security Prerequisites

### Network Access

- ✅ Outbound HTTPS (443) to:
  - `management.azure.com` (Azure API)
  - `*.vault.azure.net` (Key Vault)
  - `storage.azure.com` (Blob storage)
  - `pypi.org` (Python packages for Linux provisioners)
  - `packages.microsoft.com` (Microsoft repositories)

### Firewall Rules (if applicable)

If building behind a corporate firewall, ensure:

- Packer can reach Azure endpoints
- Image VM can download packages/agents during provisioning
- Build logs can ship to Log Analytics

### VNet Requirements

The Terraform-created VNet includes:

- **Subnet**: `packer-subnet` (10.0.1.0/24)
- **NSG**: Allows outbound HTTPS + NTP
- **Route**: Default route through NAT Gateway for consistent egress IP

---

## 9. Checklist Before First Build

- [ ] Terraform v1.5+ installed
- [ ] Azure CLI v2.50+ installed
- [ ] Packer v1.15+ installed
- [ ] `az login` successful
- [ ] Service principal created (image-bakery-packer)
- [ ] Environment variables set (ARM_*)
- [ ] `terraform/terraform.tfvars` updated with subscription_id
- [ ] `terraform validate` passes
- [ ] `terraform plan -out=tfplan` generates 28 resources
- [ ] `terraform apply tfplan` completes successfully
- [ ] CIS benchmark PDFs downloaded to `shared/scripts/cis-kits/`
- [ ] CIS kits uploaded to storage account blob container
- [ ] `packer validate` passes for target OS template
- [ ] Azure DevOps service connection configured (if using pipelines)

---

## 10. Troubleshooting Prerequisites

### "az login" fails

```bash
# Clear cached credentials
az account clear
az login
```

### Service Principal lacks permissions

```bash
# Check role assignments
az role assignment list \
  --assignee <CLIENT_ID> \
  --all --output table
```

### Terraform can't authenticate

```bash
# Verify environment variables
echo $ARM_CLIENT_ID $ARM_CLIENT_SECRET $ARM_TENANT_ID $ARM_SUBSCRIPTION_ID

# Re-export if missing
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_TENANT_ID="..."
export ARM_SUBSCRIPTION_ID="d72ed3be-46f3-4feb-b6ca-53511fa25952"
```

### Packer build fails with quota error

```bash
# Check quota limits
az compute vm list-usage --location eastus --output table
```

---

## Additional Resources

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Packer Azure Builder](https://www.packer.io/plugins/builders/azure)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/)
- [Image Bakery Documentation](./docs/INDEX.md)
