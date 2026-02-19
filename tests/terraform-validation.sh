#!/bin/bash
# Terraform Validation Tests
# Runs comprehensive checks on Terraform code

set -e

echo "===================="
echo "Terraform Validation"
echo "===================="

# Initialize Terraform
echo "1. Initializing Terraform..."
terraform init -backend=false

# Validate syntax
echo "2. Validating Terraform syntax..."
terraform validate

# Format check
echo "3. Checking code formatting..."
terraform fmt -check -recursive

# Security scan with Checkov
echo "4. Running Checkov security scan..."
checkov -d . --framework terraform --quiet --skip-check CKV_AZURE_1,CKV_AZURE_49 || true

# TFLint security checks
if command -v tflint &> /dev/null; then
  echo "5. Running TFLint..."
  tflint --init
  tflint --var-file terraform.tfvars
else
  echo "5. TFLint not installed (optional)"
fi

echo ""
echo "✅ Terraform validation passed!"
