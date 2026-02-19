# Image Bakery

🖼️ **Build hardened, baseline Azure VM images for production deployment.**

Image Bakery automates the creation of security-hardened VM images for multiple operating systems with CIS Benchmark compliance, baseline security agents, and organization-wide configuration baked in.

## Quick Links

🚀 **[Getting Started](GETTING_STARTED.md)** — 5-minute setup  
📚 **[Full Documentation](docs/)** — Everything you need  
💡 **[Contributing](CONTRIBUTING.md)** — How to extend Image Bakery

---

## What It Does

✅ Creates hardened baseline VM images for:

- Windows Server (2019, 2022, 2025)
- RHEL (8, 9)
- Ubuntu (20.04 LTS, 22.04 LTS)
- Azure Linux (3)

✅ Bakes in:

- CIS Level 1 (baseline) or CIS Level 2 (strict) hardening
- 4 baseline security agents (Qualys, NXLog, XM Cyber, New Relic)
- Organization-wide configuration (networking, monitoring, secrets)
- Consistent tagging and versioning

✅ Deploys to:

- Azure Compute Gallery (versioned, replicable)
- Multiple regions (via gallery replication)
- Ready for immediate VM deployment

## Project Status

✅ **Production Ready** — All infrastructure, images, and hardening complete

---

## Quick Start

**1. Deploy infrastructure** (5 min)

```bash
cd terraform
terraform apply tfplan
```

**2. Build your first image** (30-60 min)

```bash
packer build images/windows/2022/cis1/windows-2022-cis1.pkr.hcl
```

### 3. Find your image

```bash
az sig image-definition list --gallery-name imageBakeryGallery
```

👉 [Full Getting Started Guide](GETTING_STARTED.md)

---

## Documentation Index

👉 **[Complete Documentation Index →](INDEX.md)**

**Quick Navigation:**

- **[Getting Started](GETTING_STARTED.md)** — 5-minute quickstart
- **[Prerequisites](PREREQUISITES.md)** — Setup requirements
- **[Contributing](CONTRIBUTING.md)** — How to extend Image Bakery
- **[docs/](docs/)** — Full documentation archive

### Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### Build Your First Image

```bash
# Validate Ubuntu CIS L1 template
packer validate \
  -var-file=shared/variables/common.pkrvars.hcl \
  images/ubuntu/cis1/ubuntu-cis1.pkr.hcl

# Build Ubuntu CIS L1 image
packer build \
  -var-file=shared/variables/common.pkrvars.hcl \
  images/ubuntu/cis1/ubuntu-cis1.pkr.hcl

# Build Ubuntu CIS L2 image (incremental controls on top of L1)
packer build \
  -var-file=shared/variables/common.pkrvars.hcl \
  images/ubuntu/cis2/ubuntu-cis2.pkr.hcl
```

## Project Structure

```text
image_bakery/
├── images/                          # OS-specific Packer templates
│   ├── ubuntu/cis1/ & cis2/        # Ubuntu 22.04 LTS templates
│   ├── windows/cis1/ & cis2/       # Windows Server 2022 templates
│   ├── azurelinux/cis1/ & cis2/    # Azure Linux 3 templates
│   └── rhel/cis1/ & cis2/          # RHEL 9 templates
├── shared/
│   ├── scripts/
│   │   ├── hardening/cis1/         # CIS L1 hardening scripts (Linux)
│   │   ├── hardening/cis2/         # CIS L2 hardening scripts (incremental)
│   │   └── agents/                 # Baseline agent installers
│   └── variables/
│       └── common.pkrvars.hcl      # Shared Packer variables
├── terraform/                       # Azure infrastructure-as-code
│   ├── main.tf                     # Compute Gallery, Key Vault, etc.
│   ├── variables.tf
│   └── terraform.tfvars
├── pipelines/                       # Azure DevOps pipeline definitions
│   └── azure-pipelines.yml
├── .github/agents/                  # MCP agents for workflow automation
│   ├── security.agent.md
│   ├── packer.agent.md
│   ├── terraform.agent.md
│   ├── checkov.agent.md
│   ├── mermaid.agent.md
│   ├── documentation.agent.md
│   ├── update.agent.md
│   └── lifecycle.agent.md
└── docs/                            # Project documentation
```

## Agents 🤖

8 specialized agents handle different aspects of the Image Bakery workflow:

| Agent | Purpose |
| --- | --- |
| **Security Agent** | CIS compliance validation, vulnerability scanning, secrets detection |
| **Packer Agent** | Template validation, image building, provisioner ordering |
| **Terraform Agent** | Infrastructure management, resource planning, state management |
| **Checkov Agent** | IaC security scanning, policy compliance checking |
| **Mermaid Agent** | Workflow diagrams, architecture documentation |
| **Documentation Agent** | README files, API docs, guides, variable reference |
| **Update Agent** | Version management, patching, bulk updates |
| **Lifecycle Agent** | Image versioning, publishing, deprecation, retirement |

## CIS Levels Explained

### CIS Level 1 (Baseline)

- Foundation security controls
- Suitable for general workloads
- Minimal performance impact
- Examples: disk encryption, firewall rules, SSH hardening

### CIS Level 2 (Stricter)

- All L1 controls PLUS additional stricter controls
- For sensitive/high-compliance workloads
- May impact performance/functionality
- Examples: mandatory access controls, enhanced auditing

**Important**: CIS L2 is always incremental. L2 scripts apply additional controls on top of L1, never duplicate.

## Image Naming Convention

Format: `{os}-{version}-cis{level}`

Examples:

- `ubuntu-2204-cis1` — Ubuntu 22.04 LTS, CIS Level 1
- `ubuntu-2204-cis2` — Ubuntu 22.04 LTS, CIS Level 2
- `windows-2022-cis1` — Windows Server 2022, CIS Level 1
- `rhel-9-cis2` — RHEL 9, CIS Level 2

## Image Versioning

Images are versioned using `YYYY.MM.DD` format:

- `2026.02.18` — Built February 18, 2026
- Allows multiple builds per day if needed
- Published to Azure Compute Gallery

## Baseline Agents

Every image includes these 4 agents:

1. **Qualys** — Vulnerability scanning
2. **NXLog** — Log shipping and forwarding
3. **XM Cyber** — Attack path and exposure management
4. **New Relic** — Infrastructure monitoring and metrics

## Provisioner Execution Order

All OS targets follow this order:

1. **Package Installation** — OS-level packages and tools
2. **OS Configuration** — DSC (Windows) or Bash (Linux) setup
3. **Agent Installation** — Qualys, NXLog, XM Cyber, New Relic
4. **Cleanup** — Remove temporary files, optimize image

## Available Commands

### Packer

```bash
# Validate template syntax
packer validate -var-file=shared/variables/common.pkrvars.hcl images/<os>/cis<level>/<template>.pkr.hcl

# Format HCL files
packer fmt -recursive

# Build image
packer build -var-file=shared/variables/common.pkrvars.hcl images/<os>/cis<level>/<template>.pkr.hcl

# Debug failed build (keeps VM alive)
packer build -on-error=ask -var-file=shared/variables/common.pkrvars.hcl images/<os>/cis<level>/<template>.pkr.hcl
```

### Terraform

```bash
# Initialize Terraform
cd terraform
terraform init

# Plan changes
terraform plan -var-file=terraform.tfvars

# Apply changes
terraform apply -var-file=terraform.tfvars

# View resource graph
terraform graph
```

### Security Scanning

```bash
# Checkov security scan
checkov -d . --framework terraform,packer

# Lint shell scripts
shellcheck -x -S warning shared/scripts/**/*.sh
```

## CI/CD Pipeline

The Azure DevOps pipeline (`pipelines/azure-pipelines.yml`) includes:

- **Validation Stage**: Template validation, Terraform checks
- **Documentation Stage**: README verification
- **Build Stage**: Image building (main branch only)
- **Infrastructure Stage**: Terraform plan and apply
- **Publish Stage**: Artifact publishing

Trigger conditions:

- Runs on changes to `main` or `develop`
- Watches: `images/`, `shared/`, `terraform/`, `pipelines/`

## Contributing

1. Create a branch for your changes
2. Validate: `packer validate`, `terraform validate`, `checkov -d .`
3. Test: Build an image locally
4. Document: Update README files if needed
5. Push and create a pull request

## Troubleshooting

### Build Fails: "Marketplace image not found"

Check that `image_offer`, `image_sku`, `image_version` match available marketplace images.

### Checkov Warnings

Review policy violations carefully. Some may be false positives for cloud images. Use `--skip-check` to exclude known issues.

### Packer Build Hangs

Set `build_date` explicitly and increase `vm_size` to `Standard_D8s_v3` for faster builds.

### Terraform Apply Fails

Ensure service principal has `Contributor` role on the subscription.

## Support & Documentation

- **CIS Benchmarks**: [https://www.cisecurity.org/](https://www.cisecurity.org/)
- **Packer Docs**: [https://developer.hashicorp.com/packer](https://developer.hashicorp.com/packer)
- **Terraform Docs**: [https://developer.hashicorp.com/terraform](https://developer.hashicorp.com/terraform)
- **Azure DevOps**: [https://dev.azure.com/](https://dev.azure.com/)

## License

[Your License Here]

## Authors

Image Bakery Development Team
