# Getting Started with Image Bakery

Get a hardened Azure VM image built and deployed in 10 minutes.

## Prerequisites

- Azure CLI configured (`az login`)
- Terraform 1.5+
- Packer 1.15+
- Bash/PowerShell (depending on your OS)

## Quick Start (5 Minutes)

### 1. Deploy Infrastructure

```bash
cd terraform
terraform plan -out=tfplan
terraform apply tfplan
```

Wait ~5 minutes for Azure resources to create.

### 2. Build Your First Image

```bash
packer build \
  -var-file=shared/variables/common.pkrvars.hcl \
  images/windows/2022/cis1/windows-2022-cis1.pkr.hcl
```

Or for Linux:

```bash
packer build \
  -var-file=shared/variables/common.pkrvars.hcl \
  images/ubuntu/2204/cis1/ubuntu-2204-cis1.pkr.hcl
```

Your image will be published to Azure Compute Gallery automatically.

### 3. Verify in Azure

```bash
az sig image-definition list \
  --gallery-name imageBakeryGallery \
  --resource-group image-bakery-rg
```

---

## What You Get

✅ **Resource Group** - Contains all infrastructure  
✅ **Shared Image Gallery** - Centralized image management  
✅ **Storage Account** - Artifacts and logs  
✅ **Key Vault** - Secrets management  
✅ **Monitoring** - Application Insights + Log Analytics  

---

## Build Variants Available

### Operating Systems

- **Windows**: 2019, 2022, 2025
- **RHEL**: 8, 9
- **Ubuntu**: 20.04 LTS, 22.04 LTS
- **Azure Linux**: 3

### Hardening Levels

- **CIS Level 1**: Baseline security (general workloads)
- **CIS Level 2**: Strict controls (high-compliance workloads)

---

## Next Steps

| Goal | Guide |
| --- | --- |
| Set up prerequisites | [PREREQUISITES.md](PREREQUISITES.md) |
| Manage credentials | [docs/guides/secrets-management.md](docs/guides/secrets-management.md) |
| See cost estimate | [docs/COST.md](docs/COST.md) |
| View all documentation | [INDEX.md](INDEX.md) |

---

## Common Issues

**Q: "subscription ID not known"**  
A: Run `az account list` to verify your subscription is accessible

**Q: Packer timeout on build**  
A: Image building can take 30+ minutes. Check logs in storage account

**Q: "Permission denied" on Key Vault**  
A: Ensure your service principal has correct RBAC roles (see [PREREQUISITES.md](PREREQUISITES.md))

See [PREREQUISITES.md](PREREQUISITES.md) or [INDEX.md](INDEX.md) for more help.

---

## Documentation

Complete documentation is organized by topic:

- **[docs/](docs/)** - Main documentation
- **[docs/guides/](docs/guides/)** - Step-by-step tutorials
- **[docs/architecture/](docs/architecture/)** - System design & components
- **[docs/reports/](docs/reports/)** - Historical audit reports


