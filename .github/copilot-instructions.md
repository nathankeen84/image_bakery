# Copilot Instructions for Image Bakery

## Project Overview

Image Bakery builds hardened, baseline Azure VM images for four OS targets:
- **Windows Server** (Server 2019 / 2022 /2025)
- **Azure Linux** (CBL-Mariner / Azure Linux 2/3)
- **Ubuntu** (LTS releases)
- **Red Hat Enterprise Linux** (RHEL 8 / 9)

Each image bakes in baseline agents (monitoring, security, management) and org-wide configuration so deployed VMs are production-ready without post-deployment setup.

Two hardening variants are produced per OS target:
- **CIS Level 1** — baseline security posture, suitable for general workloads
- **CIS Level 2** — stricter controls, for sensitive/high-compliance workloads (may impact performance/functionality)

## Architecture

```
images/
  windows/
    cis1/        # CIS Level 1 Packer template + scripts
    cis2/        # CIS Level 2 Packer template + scripts
  azurelinux/
    cis1/
    cis2/
  ubuntu/
    cis1/
    cis2/
  rhel/
    cis1/
    cis2/
shared/
  scripts/
    hardening/
      cis1/      # CIS L1 hardening scripts (shared across OS where possible)
      cis2/      # CIS L2 hardening scripts (incremental on top of L1)
  variables/     # Shared variable files (subscription IDs, gallery names, tags)
pipelines/       # Azure DevOps pipeline definitions
```

**Build flow:** Packer authenticates to Azure → spins up a temporary VM from the marketplace base image → runs provisioners (shell/PowerShell/Ansible) to install agents + apply CIS hardening → captures a managed image → publishes to Azure Compute Gallery as a separate image definition per OS+CIS level.

**CIS L2 is always incremental on L1** — the L2 template/scripts apply additional controls on top of L1. Never duplicate L1 controls in L2 scripts.

## Tech Stack

- **Image builders:** HashiCorp Packer (`azure-arm` / `azure` v2 builder) **and** Azure Image Builder (AIB)
- **Provisioners:** PowerShell (Windows), Bash/shell (Linux), Ansible playbooks, PowerShell DSC
- **Infrastructure target:** Azure (Compute Gallery for versioned image distribution)
- **CI/CD:** Azure DevOps Pipelines
- **Auth:** Service principal or managed identity via `ARM_CLIENT_ID` / `ARM_CLIENT_SECRET` env vars

## Developer Workflows

```bash
# Validate a CIS L1 template before building (example: Ubuntu)
packer validate -var-file=shared/variables/common.pkrvars.hcl images/ubuntu/cis1/ubuntu-cis1.pkr.hcl

# Build a CIS L1 image
packer build -var-file=shared/variables/common.pkrvars.hcl images/ubuntu/cis1/ubuntu-cis1.pkr.hcl

# Build a CIS L2 image
packer build -var-file=shared/variables/common.pkrvars.hcl images/ubuntu/cis2/ubuntu-cis2.pkr.hcl

# Build with a specific Azure subscription/gallery override
packer build \
  -var "subscription_id=<sub-id>" \
  -var "gallery_name=<gallery>" \
  images/windows/cis1/windows-cis1.pkr.hcl

# Debug a failed Packer build (keeps the VM alive for inspection)
packer build -on-error=ask images/rhel/cis2/rhel-cis2.pkr.hcl

# Azure Image Builder (AIB) builds are triggered via Azure DevOps Pipeline
# See pipelines/ for pipeline YAML definitions
```

**CI/CD:** All builds run through **Azure DevOps Pipelines**. Packer builds are invoked as pipeline tasks; AIB builds use the `AzureImageBuilderTask` or az CLI. Pipeline definitions live in `pipelines/`.

## Conventions

- **One directory per OS per CIS level** under `images/<os>/cis1/` and `images/<os>/cis2/`. Each contains its own `.pkr.hcl` template and OS+level-specific scripts.
- **CIS L2 scripts are additive** — they apply controls on top of L1. The L2 Packer template calls the L1 provisioners first, then the L2-specific ones. Never re-apply L1 controls inside L2 scripts.
- **Image naming in Compute Gallery:** use a consistent suffix, e.g. `ubuntu-2204-cis1` and `ubuntu-2204-cis2`, to make the level identifiable from the image definition name.
- **Shared provisioner scripts** live in `shared/scripts/` and are referenced by all templates. Avoid duplicating scripts per OS.
- **Variable files** (`.pkrvars.hcl`) separate environment-specific values (subscription, resource group, gallery) from template logic.
- **Image versioning** follows `YYYY.MM.DD` or semantic versioning in the Compute Gallery definition — stay consistent within the project.
- **Baseline agents installed in every image:**
  - Qualys (vulnerability scanning)
  - NXLog (log shipping)
  - XM Cyber (attack path / exposure management)
  - New Relic Infrastructure agent (metrics/observability)
- **Provisioner ordering:** package installs (shell/PowerShell) → Ansible roles → DSC resources → agent installers. Keep this order consistent across all OS templates.
- **Config management layering:** use shell/PowerShell for OS-level setup, Ansible for idempotent agent configuration, DSC for Windows compliance enforcement.
- Windows provisioners use PowerShell; Linux provisioners use Bash/Ansible. Keep OS-specific items in `images/<os>/scripts/`; reuse in `shared/scripts/` when applicable across Linux targets.

## Key Files / Directories

| Path | Purpose |
|------|---------|
| `images/<os>/cis1/<os>-cis1.pkr.hcl` | Packer HCL2 template — CIS Level 1 variant |
| `images/<os>/cis2/<os>-cis2.pkr.hcl` | Packer HCL2 template — CIS Level 2 variant |
| `images/<os>/aib/` | Azure Image Builder template JSON/YAML per OS |
| `images/<os>/cis1/scripts/` | OS+level-specific provisioner scripts for CIS L1 |
| `images/<os>/cis2/scripts/` | Incremental CIS L2 provisioner scripts |
| `shared/variables/common.pkrvars.hcl` | Shared variable values (gallery, location, tags) |
| `shared/scripts/hardening/cis1/` | Shared CIS L1 hardening scripts (Linux targets) |
| `shared/scripts/hardening/cis2/` | Shared CIS L2 incremental hardening scripts |
| `shared/scripts/` | Agent installers and other cross-OS scripts |
| `shared/ansible/` | Ansible playbooks/roles for agent configuration |
| `shared/dsc/` | PowerShell DSC configurations (Windows compliance) |
| `pipelines/` | Azure DevOps pipeline YAML definitions |
