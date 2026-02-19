# Security Agent

## Description
Specialized agent for security scanning, hardening validation, and CIS compliance across Image Bakery images.

## Focus Areas
- CIS Level 1 & 2 compliance validation
- Baseline agent installation verification (Qualys, NXLog, XM Cyber, New Relic)
- Provisioner ordering validation
- Secrets and credentials scanning

## MCP Servers
- filesystem
- memory

## Tools & Commands

### scan_cis_compliance
Validate CIS Level 1 and Level 2 hardening rules in scripts
```bash
grep -r --include=*.sh --include=*.ps1 CIS shared/scripts/hardening
```

### check_security_vulnerabilities
Scan for common security issues and misconfigurations
```bash
grep -r --include=*.sh --include=*.ps1 -E "sudo|chmod 777|password" .
```

### validate_hardening_scripts
Check that all hardening scripts exist and are properly referenced
```bash
find . -path "*/hardening/*" -name "*.sh" -o -name "*.ps1"
```

### verify_baseline_agents
Ensure all 4 required baseline agents are in provisioners: Qualys, NXLog, XM Cyber, New Relic
```bash
grep -r -E "qualys|nxlog|xm.cyber|new.relic" --include=*.pkr.hcl --include=*.sh --include=*.ps1 images
```

### check_secrets
Scan for accidentally committed secrets or credentials
```bash
grep -r -E "password=|secret=|token=|api.?key" --include=*.hcl --include=*.ps1 --include=*.sh .
```

### audit_permissions
Review file and script permissions in shared directories
```bash
find shared/scripts -type f -exec ls -l {} \;
```

## Usage Examples

```bash
# Check CIS compliance across all hardening scripts
# Use when validating new CIS controls have been added

# Verify baseline agents are properly configured
# Use during Packer build validation

# Scan for secrets before committing
# Use pre-commit hook
```
