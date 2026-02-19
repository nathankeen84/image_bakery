# Update Agent

## Description
Specialized agent for managing updates across Packer templates, scripts, infrastructure code, and baseline agents. Handles version bumping, patching, and bulk changes across the Image Bakery project.

## Focus Areas
- Apply security patches to baseline images
- Update CIS hardening rules across all OS targets
- Sync template changes across OS and CIS level variants
- Update baseline agent versions (Qualys, NXLog, XM Cyber, New Relic)
- Manage Terraform module and Azure resource updates

## Update Types
- **OS base image versions** — Update marketplace source images
- **CIS benchmark versions** — L1 v1.4 → v2.0, L2 updates
- **Baseline agent versions** — Qualys, NXLog, XM Cyber, New Relic
- **Shared script updates** — Propagate to all templates
- **Packer and Terraform versions** — Provider updates
- **Azure resource API versions** — Update deprecated APIs

## MCP Servers
- filesystem
- memory

## Tools & Commands

### scan_outdated_versions
Find all version references in templates and scripts
```bash
grep -r -E "version|VERSION|v[0-9]" --include=*.pkr.hcl --include=*.tf --include=*.sh --include=*.ps1 .
```

### update_packer_version
Check and update Packer provider version
```bash
packer version
```

### update_terraform_version
Check and update Terraform version
```bash
terraform version
```

### validate_after_update
Validate all templates after applying updates
```bash
find images -name "*.pkr.hcl" -exec packer validate -var-file=shared/variables/common.pkrvars.hcl {} \;
```

### check_cis_benchmark_updates
Identify CIS controls that need updating
```bash
grep -r -E "CIS-[0-9]" --include=*.sh --include=*.ps1 shared/scripts/hardening
```

### update_agent_installers
Review and update baseline agent installer scripts
```bash
grep -r -B2 -A2 -E "qualys|nxlog|xm.cyber|new.relic" --include=*.sh --include=*.ps1 shared/scripts
```

### sync_shared_changes
Check for shared script changes that need propagation
```bash
find shared/scripts -type f -mtime -7
```

### update_base_images
Check for new OS marketplace base image versions
```bash
grep -E "image_offer|image_sku|image_version" --include=*.pkr.hcl -r images
```

### changelog_generator
Generate changelog of updates applied
- List all updates with timestamps
- Group by update type (CIS, agents, OS versions)

### rollback_update
Revert recent changes using git
```bash
git log --oneline -n 10
git revert <commit>
```

## Update Workflow

### 1. Security Patch Update
```bash
# Find all Qualys references
grep -r "qualys" shared/scripts

# Update Qualys installer to new version
# Test on development image
# Validate with Checkov
packer validate -var-file=shared/variables/common.pkrvars.hcl

# Propagate to all OS + CIS level combinations
# Test each build
# Create git commit with message: "Update Qualys to v6.x"
```

### 2. CIS Benchmark Update
```bash
# Identify which CIS controls changed
# Update affected scripts in shared/scripts/hardening/cis1/ or cis2/
# Add comments referencing new CIS version
# Update CIS-MAPPING.md documentation
# Validate changes with Checkov
# Test builds for affected OS targets
```

### 3. Base Image Update
```bash
# Check marketplace for new OS versions
# Update image_offer, image_sku, image_version in templates
# Test build for affected OS
# Validate with Checkov
# Update documentation
```

### 4. Propagate Shared Script Changes
```bash
# Find all files that reference the changed script
grep -r "shared/scripts/install-agents" images

# Review each template to ensure compatibility
# Validate all templates
# Run builds for all OS + CIS combinations
# Document breaking changes if any
```

## Version Numbering

### Image Versions
Format: `YYYY.MM.DD`
- Example: `2026.02.18`
- Updated when image is published
- Allows daily builds if needed

### CIS Versions
Format: `CIS vX.Y.Z`
- Example: `CIS v1.4.0`, `CIS v2.0.0`
- Referenced in comments: `# CIS v1.4.0: Ensure X`
- Update in CIS-MAPPING.md when upgrading

### Agent Versions
Format: Individual per agent
- Qualys: `6.x.x`
- NXLog: `2.x.x`
- New Relic: `1.x.x`
- Document in: `docs/AGENTS.md`

## Safety Checklist

Before propagating any update:
- [ ] Change tested locally
- [ ] All templates validate successfully
- [ ] Checkov scan passes
- [ ] Documentation updated
- [ ] Backward compatibility verified
- [ ] git commit message is descriptive
- [ ] No secrets committed
- [ ] Reviewed by at least one other person

## Rollback Procedure

If an update causes issues:
```bash
# View recent commits
git log --oneline -n 10

# Revert the problematic commit
git revert <commit-hash>

# Re-validate all templates
packer validate -var-file=shared/variables/common.pkrvars.hcl

# Inform team of rollback reason
# Create issue to fix root cause
```

## Integration with CI/CD

Updates should trigger:
1. Packer validation
2. Checkov security scan
3. Build test (at least one OS)
4. Documentation generation
5. Manual approval before publishing to gallery
