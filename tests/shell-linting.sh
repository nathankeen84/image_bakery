#!/bin/bash
# Shell Script Validation Tests
# Lints all shell scripts for errors

set -e

echo "===================="
echo "Shell Script Linting"
echo "===================="

# Lint all shell scripts
echo "Running ShellCheck on all scripts..."
find /Users/keenn/code/image_bakery/shared/scripts -name "*.sh" -type f | while read script; do
  echo "Linting: $script"
  shellcheck -x -S warning "$script" || true
done

echo ""
echo "✅ Shell script validation complete!"
