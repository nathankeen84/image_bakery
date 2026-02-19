# Image Bakery - Documentation Index

**Complete guide to all documentation in Image Bakery, organized by use case and role.**

---

## 🎯 By Role

### 👨‍💻 For New Users

Start here if you're new to Image Bakery.

1. [README.md](README.md) — Project overview (5 min read)
2. [PREREQUISITES.md](PREREQUISITES.md) — Setup requirements (10 min read)
3. [GETTING_STARTED.md](GETTING_STARTED.md) — 5-minute quickstart

### 🏗️ For Infrastructure Engineers

Building the Azure infrastructure.

- [PREREQUISITES.md](PREREQUISITES.md) — Environment setup
- [terraform/](terraform/) — Terraform modules and deployment
- [docs/guides/secrets-management.md](docs/guides/secrets-management.md) — Key Vault setup

### 🖼️ For Image Builders

Creating and publishing VM images.

- [GETTING_STARTED.md](GETTING_STARTED.md) — First image build (10 min)
- [docs/guides/secrets-management.md](docs/guides/secrets-management.md) — Credential management
- [docs/COST.md](docs/COST.md) — Cost estimation

### 🔒 For Security & Compliance

Hardening, CIS controls, and audit.

- [PREREQUISITES.md](PREREQUISITES.md) — Security prerequisites
- [docs/guides/secrets-management.md](docs/guides/secrets-management.md) — Secrets management
- [docs/reports/](docs/reports/) — Audit & compliance reports
- [docs/architecture/AGENT-INTERCONNECTIONS.md](docs/architecture/AGENT-INTERCONNECTIONS.md) — System architecture

### 📊 For Operations

Running, monitoring, and troubleshooting.

- [docs/COST.md](docs/COST.md) — Cost management
- [docs/architecture/AGENT-INTERCONNECTIONS.md](docs/architecture/AGENT-INTERCONNECTIONS.md) — System design
- [.github/copilot-instructions.md](.github/copilot-instructions.md) — Project conventions

---

## 📚 Core Documentation

| Document | Purpose | Audience |
| --- | --- | --- |
| **[README.md](README.md)** | Project overview & quick start | Everyone |
| **[GETTING_STARTED.md](GETTING_STARTED.md)** | 5-minute quickstart guide | New users |
| **[PREREQUISITES.md](PREREQUISITES.md)** | Setup requirements & tools | Everyone (required) |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | How to extend Image Bakery | Contributors |

---

## 🗂️ Architecture & Design

Located in [docs/](docs/):

| Document | Purpose |
| --- | --- |
| **[docs/INDEX.md](docs/INDEX.md)** | Documentation navigation |
| **[docs/COST.md](docs/COST.md)** | Cost estimation & optimization |
| **[docs/guides/secrets-management.md](docs/guides/secrets-management.md)** | Key Vault & credential management |
| **[docs/architecture/AGENT-INTERCONNECTIONS.md](docs/architecture/AGENT-INTERCONNECTIONS.md)** | System components & interactions |

---

## 📋 Infrastructure Code

| Path | Purpose |
| --- | --- |
| **[terraform/](terraform/)** | Terraform modules for Azure infrastructure |
| **[terraform/modules/](terraform/modules/)** | 7 reusable Terraform modules |
| **[shared/variables/](shared/variables/)** | Packer & Terraform variables |
| **[shared/scripts/](shared/scripts/)** | Agent installers & hardening scripts |

---

## 🖼️ Image Templates

| Path | Purpose |
| --- | --- |
| **[images/windows/](images/windows/)** | Windows Server Packer templates |
| **[images/ubuntu/](images/ubuntu/)** | Ubuntu LTS Packer templates |
| **[images/rhel/](images/rhel/)** | RHEL Packer templates |
| **[images/azurelinux/](images/azurelinux/)** | Azure Linux Packer templates |

Each OS has `cis1/` (baseline) and `cis2/` (strict) hardening variants.

---

## 🤖 Agent Documentation

Automation agents for Copilot:

| Path | Purpose |
| --- | --- |
| **[.github/agents/terraform.agent.md](.github/agents/terraform.agent.md)** | Terraform automation |
| **[.github/agents/packer.agent.md](.github/agents/packer.agent.md)** | Packer automation |
| **[.github/agents/security.agent.md](.github/agents/security.agent.md)** | Security scanning |
| **[.github/agents/documentation.agent.md](.github/agents/documentation.agent.md)** | Documentation generation |

---

## 📊 Reports & Status

Located in [docs/reports/](docs/reports/):

| Document | Purpose |
| --- | --- |
| **[PROJECT_STATUS.md](docs/reports/PROJECT_STATUS.md)** | Current project status |
| **[IMPLEMENTATION_COMPLETE.md](docs/reports/IMPLEMENTATION_COMPLETE.md)** | Implementation summary |
| **[FINAL_VERIFICATION.md](docs/reports/FINAL_VERIFICATION.md)** | Verification results |
| **[VALIDATION-REPORT.md](docs/reports/VALIDATION-REPORT.md)** | Test coverage & validation |
| **[SECURITY_AUDIT_REPORT.md](docs/reports/SECURITY_AUDIT_REPORT.md)** | Security audit findings |

---

## 🎯 Quick Links by Task

### Deploy Infrastructure

1. [PREREQUISITES.md](PREREQUISITES.md) — Verify all tools installed
2. [terraform/](terraform/) — Review Terraform modules
3. Run: `cd terraform && terraform apply tfplan`

### Build Your First Image

1. [GETTING_STARTED.md](GETTING_STARTED.md) — Follow quickstart
2. Run: `packer build images/ubuntu/2204/cis1/ubuntu-2204-cis1.pkr.hcl`
3. Verify in Azure portal

### Manage Secrets

- [docs/guides/secrets-management.md](docs/guides/secrets-management.md) — Complete guide

### Understand Costs

- [docs/COST.md](docs/COST.md) — Cost breakdown & optimization

### Review Security

- [docs/reports/SECURITY_AUDIT_REPORT.md](docs/reports/SECURITY_AUDIT_REPORT.md) — Audit findings

### View System Design

- [docs/architecture/AGENT-INTERCONNECTIONS.md](docs/architecture/AGENT-INTERCONNECTIONS.md) — Architecture overview

---

## 📁 Project Structure

```text
image_bakery/
├── README.md                    # Main overview
├── GETTING_STARTED.md          # Quick start (5 min)
├── PREREQUISITES.md            # Setup requirements
├── CONTRIBUTING.md             # Contribution guidelines
├── INDEX.md                    # This file
│
├── terraform/                  # Azure infrastructure
│   ├── main.tf
│   ├── modules/                # 7 reusable modules
│   └── variables.tf
│
├── images/                     # Packer templates (16 templates)
│   ├── windows/cis1/ & cis2/
│   ├── ubuntu/cis1/ & cis2/
│   ├── rhel/cis1/ & cis2/
│   └── azurelinux/cis1/ & cis2/
│
├── shared/
│   ├── scripts/                # Install scripts + hardening
│   ├── variables/              # Packer variables
│   └── scripts/cis-kits/       # CIS benchmark PDFs
│
├── docs/                       # Documentation
│   ├── INDEX.md               # Doc navigation
│   ├── COST.md                # Cost estimation
│   ├── guides/                # How-to guides
│   ├── architecture/          # Design docs
│   └── reports/               # Status & audit reports
│
└── .github/
    ├── copilot-instructions.md # Project conventions
    └── agents/                # Automation agents
```

---

## ✅ Getting Started Checklist

- [ ] Read [README.md](README.md)
- [ ] Complete [PREREQUISITES.md](PREREQUISITES.md)
- [ ] Follow [GETTING_STARTED.md](GETTING_STARTED.md)
- [ ] Deploy via [terraform/](terraform/)
- [ ] Build first image
- [ ] Review [docs/COST.md](docs/COST.md)

---

## 🆘 Need Help?

1. **Setup issues?** → [PREREQUISITES.md](PREREQUISITES.md)
2. **First time?** → [GETTING_STARTED.md](GETTING_STARTED.md)
3. **Architecture?** → [docs/architecture/AGENT-INTERCONNECTIONS.md](docs/architecture/AGENT-INTERCONNECTIONS.md)
4. **Reports?** → [docs/reports/](docs/reports/)
5. **Contributing?** → [CONTRIBUTING.md](CONTRIBUTING.md)




