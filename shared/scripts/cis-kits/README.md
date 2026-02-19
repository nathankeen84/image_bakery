# CIS Build Kits Storage

This directory stores CIS benchmark validation tools and build kits used during image hardening.

## Directory Structure

```text
cis-kits/
├── linux/
│   ├── rhel/
│   │   ├── cis-cat-lite/          # CIS-CAT Lite for RHEL validation
│   │   └── benchmarks/             # CIS Linux Benchmark control files
│   ├── ubuntu/
│   │   ├── cis-cat-lite/
│   │   └── benchmarks/
│   └── azurelinux/
│       ├── cis-cat-lite/
│       └── benchmarks/
├── windows/
│   ├── cis-cat-lite/              # CIS-CAT Lite for Windows
│   ├── benchmarks/                 # CIS Windows Benchmark files
│   └── lgpo/                       # Local Group Policy Object tools
└── tools/
    ├── cis-cat-lite-launcher.jar  # CIS-CAT Lite runner
    ├── jre/                        # Java runtime (if needed)
    └── validation-scripts/         # Custom validation helpers
```

## Usage in Packer Build

### During Hardening Provisioner

```bash
# Linux example in provisioner
provisioner "shell" {
  script = "${path.root}/../../shared/scripts/hardening/cis1/rhel-cis1-hardening.sh"
  environment_vars = [
    "CIS_KIT_PATH=/opt/cis-kits",
    "BENCHMARK_VERSION=2.0.0"
  ]
}

# Validate with CIS-CAT
provisioner "shell" {
  inline = [
    "java -jar /opt/cis-kits/tools/cis-cat-lite-launcher.jar -a -r /tmp/cis-report"
  ]
}
```

### Within Hardening Scripts

```bash
#!/bin/bash
# Reference CIS benchmark controls
CIS_KIT_PATH=${CIS_KIT_PATH:-/opt/cis-kits}
BENCHMARK_FILE="$CIS_KIT_PATH/linux/rhel/benchmarks/CIS_RHEL_Linux_9_Benchmark_2.0.0.xml"

# Use benchmark data for validation
grep "control-id" "$BENCHMARK_FILE"
```

## Download & Installation

### Before Image Build (Prep Phase)

1. **Download CIS Benchmarks** (requires CIS account):

```bash
# From CIS website or CI/CD pipeline
wget -O cis-benchmarks.zip https://cis.org/benchmarks/download
unzip cis-benchmarks.zip -d cis-kits/
```

1. **Place CIS-CAT Lite**:

```bash
# Download from CIS
mkdir -p cis-kits/tools
cp CIS-CAT-Lite.jar cis-kits/tools/cis-cat-lite-launcher.jar
```

### During Image Build (Provisioner Phase)

Option 1: **Upload with Packer** (for small files)

```hcl
provisioner "file" {
  source      = "${path.root}/../../cis-kits/"
  destination = "/opt/cis-kits"
}
```

Option 2: **Download from Storage** (preferred for large files)

```hcl
provisioner "shell" {
  inline = [
    "mkdir -p /opt/cis-kits",
    "az storage blob download-batch -d /opt/cis-kits -s cis-kits-container --account-name ${var.storage_account_name}",
    "chmod -R 755 /opt/cis-kits"
  ]
}
```

Option 3: **Reference from Host** (during validation)

```hcl
provisioner "shell" {
  script = "validate-with-cis.sh"
  environment_vars = [
    "CIS_KIT_PATH=/tmp/cis-kits"  # Mount or pass during build
  ]
}
```

## CIS-CAT Lite Validation

Add post-hardening validation to Packer build:

```hcl
# After all hardening provisioners
provisioner "shell" {
  inline = [
    "echo 'Running CIS-CAT Lite validation...'",
    "java -jar /opt/cis-kits/tools/cis-cat-lite-launcher.jar -a -r /tmp/cis-compliance-report.html",
    "echo 'CIS compliance report generated at /tmp/cis-compliance-report.html'"
  ]
}
```

## Storage Account Integration

### Upload CIS Kits to Azure Storage

```bash
# Create storage container
az storage container create \
  --name cis-kits-container \
  --account-name ${STORAGE_ACCOUNT} \
  --auth-mode login

# Upload kits
az storage blob upload-batch \
  -s ./cis-kits \
  -d cis-kits-container \
  --account-name ${STORAGE_ACCOUNT}

# Get SAS URL for access during builds
az storage blob generate-sas \
  --account-name ${STORAGE_ACCOUNT} \
  --container-name cis-kits-container \
  --name "" \
  --permissions racwd \
  --expiry 2026-12-31T23:59:00Z
```

## Security Considerations

- **Store credentials securely** - Use Key Vault for CIS website credentials
- **Validate checksums** - Verify integrity of downloaded kits
- **Restrict access** - Limit Storage Account access via RBAC
- **Version control** - Tag CIS kit versions alongside benchmark versions
- **Cleanup** - Remove from final image (not needed at runtime)

## Troubleshooting

| Issue | Solution |
| --- | --- |
| CIS-CAT fails to run | Ensure Java is installed: `yum install -y java-11-openjdk` |
| Permission denied | Check ownership: `ls -la /opt/cis-kits/` |
| Benchmark file not found | Verify extraction: `unzip -l cis-benchmarks.zip` |
| Large file timeout | Use Azure Storage download instead of file provisioner |

## References

- [CIS Benchmarks](https://www.cisecurity.org/benchmarks/)
- [CIS-CAT Lite](https://www.cisecurity.org/cis-cat/)
- [CIS Controls](https://www.cisecurity.org/controls/)


