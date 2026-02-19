# Packer Agent

## Description
Specialized agent for Packer template validation, building, and debugging Image Bakery VM images.

## Focus Areas
- Validate Packer HCL2 templates per OS and CIS level
- Ensure provisioner ordering: packages → DSC (Windows) / Bash (Linux) → agents
- Verify variable files reference correct subscription/gallery
- Check that CIS L2 templates call L1 provisioners first

## OS Targets
- windows (Server 2019/2022/2025)
- azurelinux (CBL-Mariner / Azure Linux 2/3)
- ubuntu (LTS releases)
- rhel (RHEL 8/9)

## MCP Servers
- filesystem
- memory

## Tools & Commands

### validate_all_templates
Validate all Packer HCL2 templates across all OS and CIS levels
```bash
find images -name "*.pkr.hcl" -exec packer validate -var-file=shared/variables/common.pkrvars.hcl {} \+
```

### validate_single_template
Validate a specific Packer template
```bash
packer validate -var-file=shared/variables/common.pkrvars.hcl images/ubuntu/cis1/ubuntu-cis1.pkr.hcl
```

### format_packer_template
Format Packer template to HCL2 standards
```bash
packer fmt -recursive
```

### inspect_packer_template
Inspect Packer template for variables, locals, and provisioners
```bash
packer inspect images/windows/cis1/windows-cis1.pkr.hcl
```

### build_packer_image
Build a Packer image
```bash
packer build -var-file=shared/variables/common.pkrvars.hcl images/ubuntu/cis1/ubuntu-cis1.pkr.hcl
```

### debug_packer_build
Debug a failed Packer build with on-error=ask to inspect the VM
```bash
packer build -on-error=ask -var-file=shared/variables/common.pkrvars.hcl images/rhel/cis2/rhel-cis2.pkr.hcl
```

### list_packer_templates
List all available Packer templates by OS and CIS level
```bash
find images -name "*.pkr.hcl" -type f
```

### check_provisioners
List all provisioners in templates to verify ordering
```bash
grep -E "provisioner|type|script" --include=*.pkr.hcl -r images
```

### validate_variables
Check that required variables are defined in .pkrvars.hcl files
```bash
grep -E "subscription_id|gallery_name|location|image_name" --include=*.pkrvars.hcl -r shared/variables
```

## Usage Examples

```bash
# Validate Ubuntu CIS L1 template before building
packer validate -var-file=shared/variables/common.pkrvars.hcl images/ubuntu/cis1/ubuntu-cis1.pkr.hcl

# Build a specific image
packer build -var-file=shared/variables/common.pkrvars.hcl images/windows/cis2/windows-cis2.pkr.hcl

# Debug a build failure and keep VM alive for inspection
packer build -on-error=ask -var-file=shared/variables/common.pkrvars.hcl images/rhel/cis1/rhel-cis1.pkr.hcl

# Override gallery/subscription for specific build
packer build \
  -var "subscription_id=<sub-id>" \
  -var "gallery_name=<gallery>" \
  images/azurelinux/cis1/azurelinux-cis1.pkr.hcl
```

## CIS Level Notes
- **CIS L1** templates: located in `images/<os>/cis1/`
- **CIS L2** templates: located in `images/<os>/cis2/`
  - L2 templates call L1 provisioners first, then add incremental controls
  - Never duplicate L1 controls in L2 scripts

## Provisioner Order (All OS)
1. Package installation (shell/PowerShell)
2. OS configuration (DSC for Windows, Bash scripts for Linux)
3. Baseline agent installation (Qualys, NXLog, XM Cyber, New Relic)
