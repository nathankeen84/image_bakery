# Contributing to Image Bakery

Thank you for contributing! This guide explains how to extend Image Bakery with new OS variants, modify hardening controls, and add new features.

## Project Structure

```text
images/
├── windows/{2019,2022,2025}/cis{1,2}/
├── rhel/{8,9}/cis{1,2}/
├── ubuntu/{2004,2204}/cis{1,2}/
└── azurelinux/3/cis{1,2}/

shared/
├── scripts/hardening/cis{1,2}/
├── scripts/agents/
└── variables/
```

## Adding a New OS Variant

### 1. Create Directory Structure

```bash
mkdir -p images/OSNAME/VERSION/cis{1,2}
```

### 2. Create CIS L1 Packer Template

Copy from existing template and modify:

```hcl
# images/OSNAME/VERSION/cis1/OSNAME-VERSION-cis1.pkr.hcl

packer {
  required_version = ">= 1.15"
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2.0"
    }
  }
}

source "azure-arm" "OSNAME" {
  client_id       = var.packer_client_id
  client_secret   = var.packer_client_secret
  tenant_id       = var.packer_tenant_id
  subscription_id = var.packer_subscription_id

  managed_image_resource_group_name = var.resource_group_name
  managed_image_name                = "OSNAME-VERSION-cis1-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  # OS-specific source
  os_type = "Linux"  # or "Windows"
  image_publisher = "Publisher"
  image_offer     = "Offer"
  image_sku       = "SKU"
  image_version   = "latest"
  
  location = var.location
  vm_size  = "Standard_D2s_v3"
  
  # Gallery publication
  shared_image_gallery_destination {
    subscription   = var.packer_subscription_id
    resource_group = var.resource_group_name
    gallery_name   = var.gallery_name
    image_name     = "OSNAME-VERSION-cis1"
    image_version  = formatdate("YYYY.MM.DD", timestamp())
    replication_regions = [var.location]
  }
}

build {
  sources = ["source.azure-arm.OSNAME"]

  # 1. System updates
  provisioner "shell" {
    script = "${path.root}/../../scripts/update-system.sh"
  }

  # 2. CIS L1 hardening
  provisioner "shell" {
    script = "${path.root}/../../shared/scripts/hardening/cis1/OSNAME-cis1-hardening.sh"
  }

  # 3. Install agents
  provisioner "shell" {
    environment_vars = [
      "QUALYS_API_KEY=${var.qualys_api_key}",
      "NXLOG_API_KEY=${var.nxlog_api_key}",
      "XM_CYBER_API_KEY=${var.xm_cyber_api_key}",
      "NEWRELIC_LICENSE_KEY=${var.newrelic_license_key}"
    ]
    script = "${path.root}/../../shared/scripts/agents/install-baseline-agents.sh"
  }

  # 4. Cleanup
  provisioner "shell" {
    script = "${path.root}/../../scripts/cleanup.sh"
  }
}
```

### 3. Create CIS L2 Template

Copy CIS L1 template and add L2 provisioner:

```hcl
# Inside build block, after CIS L1:

provisioner "shell" {
  script = "${path.root}/../../shared/scripts/hardening/cis2/OSNAME-cis2-hardening.sh"
}
```

### 4. Create Hardening Scripts

**CIS L1** (`shared/scripts/hardening/cis1/OSNAME-cis1-hardening.sh`):

```bash
#!/bin/bash
set -e

echo "=== Applying CIS Level 1 Hardening for OSNAME ==="

# SSH hardening (CIS 5.2)
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Firewall (CIS 3.1)
systemctl enable firewalld
systemctl start firewalld

# More controls...

echo "✅ CIS Level 1 hardening complete"
```

**CIS L2** (`shared/scripts/hardening/cis2/OSNAME-cis2-hardening.sh`):

```bash
#!/bin/bash
set -e

echo "=== Applying CIS Level 2 Hardening for OSNAME (Incremental) ==="

# Additional stricter controls (DO NOT repeat L1)

# Kernel hardening (CIS 1.1.1)
echo "kernel.sysrq = 0" >> /etc/sysctl.conf
sysctl -p

# AIDE (CIS 1.3.1)
apt-get install -y aide aide-common

echo "✅ CIS Level 2 hardening complete"
```

### 5. Update Terraform

Add image definition to `terraform/main.tf`:

```hcl
{
  name        = "OSNAME-VERSION-cis1"
  offer       = "osname"
  sku         = "VERSION-cis1"
  os_type     = "Linux"  # or "Windows"
  description = "OSNAME VERSION with CIS Level 1 hardening"
  os_version  = "VERSION"
}
```

## Modifying Hardening Controls

### 1. Find the Control

Look in `shared/scripts/hardening/cis{1,2}/` for your OS

### 2. Edit the Script

```bash
# Example: increase password expiration
sed -i 's/PASS_MAX_DAYS 90/PASS_MAX_DAYS 60/' /etc/login.defs
```

### 3. Test with Packer

```bash
packer validate -var-file=shared/variables/common.pkrvars.hcl \
  images/OSNAME/VERSION/cis1/OSNAME-VERSION-cis1.pkr.hcl

packer build -var-file=shared/variables/common.pkrvars.hcl \
  images/OSNAME/VERSION/cis1/OSNAME-VERSION-cis1.pkr.hcl
```

### 4. Validate with CIS-CAT Lite

```bash
java -jar cis-cat-lite-launcher.jar -a /path/to/benchmark.xml
```

## Adding Baseline Agents

### 1. Modify Agent Installation Script

Edit `shared/scripts/agents/install-baseline-agents.sh`:

```bash
# Add your agent
install_myagent() {
  echo "Installing MyAgent..."
  apt-get install -y myagent
  systemctl enable myagent
  echo "✅ MyAgent installed"
}

install_myagent
```

### 2. Add Environment Variables

In Packer template:

```hcl
provisioner "shell" {
  environment_vars = [
    # ... existing agents
    "MYAGENT_KEY=${var.myagent_key}"
  ]
  script = "${path.root}/../../shared/scripts/agents/install-baseline-agents.sh"
}
```

### 3. Add Terraform Variable

In `terraform/variables.tf`:

```hcl
variable "myagent_key" {
  description = "API key for MyAgent"
  type        = string
  sensitive   = true
}
```

## Development Workflow

1. **Create feature branch**

  ```bash
  git checkout -b feature/OSNAME-VERSION
  ```

1. **Make changes** (templates, scripts, Terraform)

1. **Validate**

  ```bash
  terraform validate
  packer validate -var-file=shared/variables/common.pkrvars.hcl images/OSNAME/VERSION/cis1/*.pkr.hcl
  ```

1. **Test build** (optional, takes 30+ minutes)

  ```bash
  packer build -var-file=shared/variables/common.pkrvars.hcl images/OSNAME/VERSION/cis1/*.pkr.hcl
  ```

1. **Document changes** in [docs/](docs/)

1. **Submit PR** with clear description

---

## Best Practices

✅ **DO:**

- Keep L2 scripts incremental (don't repeat L1 controls)
- Use relative paths in Packer templates
- Test scripts locally before committing
- Reference CIS Benchmark control numbers
- Use consistent variable naming
- Add comments to complex hardening steps

❌ **DON'T:**

- Hardcode secrets in scripts or templates
- Use absolute paths in provisioners
- Modify L1 controls when making L2 changes
- Skip error handling (`set -e` in shell scripts)
- Create duplicate code (reuse shared scripts)

---

## Testing Checklist

Before submitting a PR, verify:

- [ ] Packer templates validate
- [ ] Terraform configurations validate
- [ ] Scripts have proper error handling
- [ ] No hardcoded secrets or credentials
- [ ] Image builds successfully (or explain why it can't)
- [ ] Image is published to gallery
- [ ] Image can launch a VM
- [ ] CIS controls are applied (verify with CIS-CAT Lite)
- [ ] Documentation is updated

---

## Questions?

See [docs/FAQ.md](../docs/FAQ.md) or check existing issues/PRs for similar questions.


