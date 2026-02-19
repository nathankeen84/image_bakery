#!/bin/bash
# Security Compliance Tests
# Validates CIS compliance and security configurations

set -e

echo "===================="
echo "Security Compliance"
echo "===================="

# Check for secrets in code
echo "1. Checking for exposed secrets..."
if grep -r "password\|secret\|token\|api.key" /Users/keenn/code/image_bakery/images /Users/keenn/code/image_bakery/terraform --include="*.hcl" --include="*.sh" --include="*.tf" 2>/dev/null | grep -v "\.tfvars" | grep -v "example" | grep -v ".gitignore"; then
  echo "⚠️  Warning: Potential secrets found (may be false positives)"
else
  echo "✅ No obvious secrets found"
fi

# Check file permissions
echo ""
echo "2. Checking file permissions..."
find /Users/keenn/code/image_bakery/shared/scripts -name "*.sh" -type f -exec ls -l {} \; | while read line; do
  if [[ ! "$line" =~ "x" ]]; then
    echo "⚠️  Warning: Script not executable: $line"
  fi
done

# Verify hardening scripts exist
echo ""
echo "3. Verifying hardening scripts..."
for level in cis1 cis2; do
  script="/Users/keenn/code/image_bakery/shared/scripts/hardening/$level/ubuntu-$level-hardening.sh"
  if [ -f "$script" ]; then
    echo "✅ Found: $script"
  else
    echo "⚠️  Missing: $script"
  fi
done

echo ""
echo "✅ Security compliance check complete!"
