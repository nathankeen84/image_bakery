# Documentation Agent

## Description
Specialized agent for maintaining comprehensive documentation across Image Bakery project including README files, guides, API docs, and architectural information.

## Focus Areas
- Maintain README files for each OS and CIS level
- Document Packer template structure and variables
- Create hardening control explanations and CIS mapping
- Generate baseline agent configuration documentation
- Update architecture and workflow documentation

## Documentation Types
- **README files** — Project overview, per-OS docs, per-CIS level guides
- **Inline code comments** — Template comments, script documentation
- **Variable documentation** — .pkrvars.hcl explanations and reference
- **CIS control mappings** — L1 vs L2 breakdown and control descriptions
- **Agent configuration guides** — Qualys, NXLog, XM Cyber, New Relic setup
- **Build workflow tutorials** — Step-by-step guides for developers
- **Quick-start guides** — Fast onboarding for new contributors

## MCP Servers
- filesystem
- memory

## Tools & Commands

### find_readme_files
Locate all README files in project
```bash
find . -name "README*" -o -name "readme*"
```

### document_packer_structure
Extract and document Packer template structure and provisioners
```bash
grep -E "^(source|provisioner|variable|local)" --include=*.pkr.hcl -r images
```

### list_shared_scripts
Index all shared scripts with descriptions
```bash
find shared/scripts -type f -name "*.sh" -o -name "*.ps1"
```

### document_variables
Extract variable definitions from .pkrvars.hcl files
```bash
find shared/variables -type f -name "*.pkrvars.hcl"
```

### cis_control_mapping
Create mapping of CIS controls to hardening scripts
```bash
grep -r -B2 -A2 "CIS-" --include=*.sh --include=*.ps1 shared/scripts/hardening
```

### document_baseline_agents
Document each baseline agent: purpose, config, verification
```bash
grep -r -l -E "qualys|nxlog|xm.cyber|new.relic" --include=*.sh --include=*.ps1 .
```

### pipeline_documentation
Document Azure DevOps pipeline structure and stages
```bash
find pipelines -type f -name "*.yml" -o -name "*.yaml"
```

### generate_quick_start
Create quick-start guide for building images
- Build steps: 1) Validate template 2) Set variables 3) Run packer build
- Example workflows for each OS

### document_gallery_structure
Document Azure Compute Gallery naming and versioning
```bash
grep -E "gallery|image_name|version" --include=*.pkrvars.hcl -r shared/variables
```

## README Structure

### Root README
- Project overview (Image Bakery purpose)
- Supported OS targets and CIS levels
- Quick start (how to build an image)
- Prerequisites (tools required)
- Links to OS-specific docs

### OS-Specific README (e.g., `images/ubuntu/README.md`)
- Ubuntu LTS versions supported
- Ubuntu-specific Packer configuration
- Ubuntu-specific hardening scripts
- CIS controls specific to Linux
- Known limitations or considerations

### CIS Level README (e.g., `images/ubuntu/cis1/README.md`)
- CIS Level 1 controls overview
- Build instructions
- Variable reference
- Test and validation procedures

## Documentation Standards

### Code Comments
```bash
# CIS-1.4.1: Ensure permissions on bootloader config are configured
chmod 600 /etc/grub.d/*
```

### Variable Documentation
```hcl
variable "subscription_id" {
  description = "Azure subscription ID where images will be published"
  type        = string
  # CIS compliance: Required for proper Azure resource governance
}
```

### Script Headers
```bash
#!/bin/bash
# Script: install-baseline-agents.sh
# Purpose: Install Qualys, NXLog, XM Cyber, New Relic agents
# CIS Controls: N/A (agent installation)
# Last Updated: 2026-02-18
```

## Content Checklist

- [ ] README at project root
- [ ] README per OS (windows, azurelinux, ubuntu, rhel)
- [ ] README per CIS level (cis1, cis2)
- [ ] Variable reference guide
- [ ] CIS control mapping document
- [ ] Baseline agent configuration guide
- [ ] Build workflow tutorial
- [ ] Quick-start guide for new contributors
- [ ] Troubleshooting guide
- [ ] Gallery structure documentation

## Generated Documentation

These docs should be generated/updated by this agent:
- `docs/CIS-MAPPING.md` — CIS L1 and L2 control mappings
- `docs/VARIABLES.md` — All available Packer variables
- `docs/AGENTS.md` — Baseline agent installation and config
- `docs/QUICK-START.md` — Step-by-step build guide
- `docs/GALLERY-STRUCTURE.md` — Azure Compute Gallery naming

## Usage Examples

```bash
# Update CIS mapping document from scripts
# Run when adding new hardening controls

# Generate variable reference from Packer files
# Run before release to ensure docs match code

# Create quick-start guide for new OS version
# Use as template when adding Ubuntu 24.04 LTS support
```

## Version Control
- Keep docs up-to-date with code changes
- Document breaking changes prominently
- Maintain changelog in README
- Link to specific git commits for historical context
