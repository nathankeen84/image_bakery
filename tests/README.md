# Image Bakery - Test Suite

Comprehensive testing infrastructure for Image Bakery Terraform, Packer, and shell scripts.

## Test Categories

### 1. **Terraform Validation** (`terraform-validation.sh`)

- Initializes Terraform
- Validates HCL2 syntax
- Checks code formatting with `terraform fmt`
- Runs Checkov security scanning
- Runs TFLint linting (if installed)

**Run individually:**

```bash
bash tests/terraform-validation.sh
```

### 2. **Packer Validation** (`packer-validation.sh`)

- Discovers all `.pkr.hcl` templates
- Validates each template syntax
- Checks for template errors before building

**Run individually:**

```bash
bash tests/packer-validation.sh
```

### 3. **Shell Script Linting** (`shell-linting.sh`)

- Uses ShellCheck to lint all `.sh` files
- Checks for syntax errors and common mistakes
- Detects undefined variables and potential issues

**Run individually:**

```bash
bash tests/shell-linting.sh
```

### 4. **Security Compliance** (`security-compliance.sh`)

- Scans for hardcoded secrets
- Verifies file permissions (especially execute bits)
- Ensures all expected hardening scripts exist
- Validates CIS compliance script presence

**Run individually:**

```bash
bash tests/security-compliance.sh
```

## Running All Tests

Execute the complete test suite with a summary report:

```bash
bash tests/run-all-tests.sh
```

This will:

- Run all four validation categories
- Display individual pass/fail status
- Show a summary of passed/failed tests
- Return appropriate exit codes for CI/CD integration

## Setup Requirements

### Required Tools

- **Terraform** (latest version)
- **Packer** (latest version)
- **ShellCheck** (for shell linting)

### Optional Tools

- **Checkov** (for security scanning)

```bash
pip install checkov
```

- **TFLint** (for Terraform linting)

```bash
brew install tflint  # macOS
```

## CI/CD Integration

### Azure DevOps Pipeline Example

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

steps:
  - task: UsePythonVersion@0
    inputs:
      versionSpec: '3.9'

  - script: |
      brew install terraform packer shellcheck
      pip install checkov tflint
    displayName: 'Install tools'

  - script: bash tests/run-all-tests.sh
    displayName: 'Run validation tests'
    continueOnError: false
```

## Test Results

Tests will output:

- ✅ **PASSED** - all checks completed successfully
- ⚠️ **WARNING** - potential issues found (non-blocking)
- ❌ **FAILED** - critical errors requiring fixes

## Troubleshooting

### Terraform Init Fails

```bash
# Force reinit
rm -rf .terraform
terraform init -backend=false
```

### ShellCheck Not Found

```bash
# Install ShellCheck
brew install shellcheck  # macOS
apt-get install shellcheck  # Ubuntu/Debian
```

### Packer Validation Fails

- Check `.pkr.hcl` syntax
- Verify all variable references are defined
- Run `packer inspect` for debugging:

```bash
packer inspect images/ubuntu/cis1/ubuntu-cis1.pkr.hcl
```

## Adding New Tests

To add a new test category:

1. Create a new script in `tests/` (e.g., `tests/my-test.sh`)
2. Make it executable: `chmod +x tests/my-test.sh`
3. Add a `run_test` call in `run-all-tests.sh`:

```bash
run_test "My Test Name" "$TEST_DIR/my-test.sh"
```

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed

## Best Practices

1. **Run tests locally before pushing**

```bash
bash tests/run-all-tests.sh
```

1. **Check individual tests during development**

```bash
bash tests/terraform-validation.sh
bash tests/packer-validation.sh
```

1. **Review security warnings**
   - Address Checkov findings
   - Fix TFLint errors
   - Verify no secrets are committed

1. **Keep test scripts updated**
   - Update tests when new modules are added
   - Reflect changes in validation logic

## Notes

- Tests use `-backend=false` to avoid state file requirements
- Security scans skip some false-positive rules (customizable in test scripts)
- All tests are idempotent and safe to run multiple times
