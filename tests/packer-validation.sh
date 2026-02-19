#!/bin/bash
# Packer Validation Tests
# Validates all Packer templates

set -e

echo "===================="
echo "Packer Validation"
echo "===================="

TEMPLATE_DIR="/Users/keenn/code/image_bakery/images"
TEMPLATES=$(find "$TEMPLATE_DIR" -name "*.pkr.hcl" -type f)

if [ -z "$TEMPLATES" ]; then
  echo "❌ No Packer templates found!"
  exit 1
fi

for template in $TEMPLATES; do
  echo ""
  echo "Validating: $template"
  packer validate "$template" || exit 1
done

echo ""
echo "✅ All Packer templates validated!"
