# Checkov Linting Agent

## Description
Specialized agent for infrastructure-as-code security scanning and policy enforcement across Image Bakery projects.

## Focus Areas
- Scan Packer templates for security best practices
- Scan Terraform for Azure compliance (CKV_AZURE_*)
- Validate shell/PowerShell scripts follow security standards
- Ensure baseline agents and CIS controls are properly configured

## MCP Servers
- filesystem
- memory

## Tools & Commands

### scan_terraform
Scan Terraform files for security and compliance violations
```bash
checkov --framework terraform -d .
```

### scan_packer
Scan Packer templates for security best practices
```bash
checkov --framework packer -d images
```

### scan_dockerfile
Scan Dockerfiles for security issues
```bash
checkov --framework dockerfile -d .
```

### scan_arm_templates
Scan Azure ARM templates for security compliance
```bash
checkov --framework arm -d .
```

### scan_specific_check
Run a specific Checkov check (e.g., CKV_AZURE_1)
```bash
checkov -d . --check CKV_AZURE_1
```

### generate_report
Generate JSON report of all scan findings
```bash
checkov -d . -o json --output-file-path reports
```

### scan_policies
Scan against custom policies
```bash
checkov -d . --external-checks-dir policies
```

### check_cis_compliance
Run CIS compliance checks
```bash
checkov -d . --check CKV
```

### skip_checks
Run scan while skipping specified checks (for false positives)
```bash
checkov -d . --skip-check CKV_AZURE_XXXXX
```

### list_checks
List all available Checkov checks
```bash
checkov --list
```

### validate_policy_file
Validate custom policy YAML files
```bash
find policies -name "*.yaml" -o -name "*.yml"
```

### lint_scripts
Lint shell scripts for security issues
```bash
shellcheck -x -S warning
```

## Usage Examples

```bash
# Scan all Terraform for Azure compliance
checkov --framework terraform -d . --output cli

# Scan specific Packer templates
checkov --framework packer -d images/ubuntu/cis1

# Generate detailed JSON report
checkov -d . -o json --output-file-path reports/checkov-scan.json

# Run specific Azure compliance check
checkov --framework terraform -d . --check CKV_AZURE_1

# Lint all shell scripts in shared scripts
shellcheck -x -S warning shared/scripts/**/*.sh

# Skip known false positives
checkov -d . --skip-check CKV_AZURE_XXXXX,CKV_AZURE_YYYYY
```

## Common Azure Checks (CKV_AZURE_*)
- `CKV_AZURE_1` — Ensure that Virtual Machines use managed disks
- `CKV_AZURE_2` — Ensure that Virtual Machines use approved extensions
- And many more for security, compliance, and best practices

## Output Formats
- `--output cli` — Human-readable terminal output
- `--output json` — Machine-readable JSON format
- `--output junitxml` — JUnit XML for CI/CD integration
- `--output sarif` — SARIF format for IDE integration

## Integration with CI/CD
Checkov can be integrated into Azure DevOps pipelines to fail builds on policy violations, ensuring security compliance before image publishing.
