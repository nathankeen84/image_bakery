# Agent Interconnection Map

This document shows how the 8 Image Bakery agents work together.

## Dependency Graph

```mermaid
graph TD
    Security["🔒 Security Agent<br/>CIS Compliance, Secrets"]
    Packer["📦 Packer Agent<br/>Template Building"]
    Terraform["🏗️ Terraform Agent<br/>Infrastructure"]
    Checkov["✅ Checkov Agent<br/>Policy Compliance"]
    Mermaid["📊 Mermaid Agent<br/>Diagrams & Visualization"]
    Documentation["📖 Documentation Agent<br/>README, APIs, Guides"]
    Update["🔄 Update Agent<br/>Version Management"]
    Lifecycle["🔁 Lifecycle Agent<br/>Publishing & Versioning"]
    
    Terraform -->|validates| Security
    Packer -->|validates| Security
    Packer -->|builds images| Checkov
    Terraform -->|provisions resources| Checkov
    Security -->|compliance data| Documentation
    Packer -->|template info| Mermaid
    Terraform -->|resource info| Mermaid
    Documentation -->|docs| Mermaid
    Update -->|version checks| Packer
    Update -->|version checks| Terraform
    Packer -->|builds| Lifecycle
    Terraform -->|publishes to| Lifecycle

## Agent Workflow: Image Build Process

```text
┌─────────────────────────────────────────────────────────┐
│                   Developer Commit                      │
│           (Packer template or script change)           │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ▼
        ┌─────────────────────────┐
        │   Security Agent        │
        │ • Scan for secrets      │
        │ • Check permissions     │
        │ • Validate CIS rules    │
        └──────────┬──────────────┘
                   │ ✅ Pass
                   ▼
        ┌─────────────────────────┐
        │   Packer Agent          │
        │ • Validate templates    │
        │ • Check provisioners    │
        │ • Format HCL2           │
        └──────────┬──────────────┘
                   │ ✅ Pass
                   ▼
        ┌─────────────────────────┐
        │   Terraform Agent       │
        │ • Plan infrastructure   │
        │ • Validate modules      │
        │ • Check variables       │
        └──────────┬──────────────┘
                   │ ✅ Pass
                   ▼
        ┌─────────────────────────┐
        │   Checkov Agent         │
        │ • Scan Packer IaC       │
        │ • Scan Terraform IaC    │
        │ • Generate reports      │
        └──────────┬──────────────┘
                   │ ✅ Pass
                   ▼
        ┌─────────────────────────┐
        │   Documentation Agent   │
        │ • Update README         │
        │ • Document changes      │
        │ • Sync variable docs    │
        └──────────┬──────────────┘
                   │
                   ▼
        ┌─────────────────────────┐
        │   Mermaid Agent         │
        │ • Create diagrams       │
        │ • Update architecture   │
        │ • Document workflow     │
        └──────────┬──────────────┘
                   │
                   ▼
        ┌─────────────────────────┐
        │   Build Stage           │
        │ • Packer build runs     │
        │ • Image created         │
        │ • Published to Gallery  │
        └──────────┬──────────────┘
                   │
                   ▼
        ┌─────────────────────────┐
        │   Lifecycle Agent       │
        │ • Tag image version     │
        │ • Update gallery        │
        │ • Trigger deprecation   │
        └─────────────────────────┘
```

## Agent Responsibilities

### 🔒 Security Agent

**Files**: `.github/agents/security.agent.md`

**Responsibilities**:

- Scan for accidentally committed secrets
- Validate CIS control implementation
- Verify baseline agent configuration
- Check file permissions on sensitive scripts
- Audit hardening rules compliance

**Tools**:

```bash
scan_cis_compliance         # Validate CIS controls
check_secrets              # Find exposed credentials
validate_hardening_scripts # Ensure all controls present
verify_baseline_agents     # Check 4 required agents
audit_permissions          # Review script/file perms
```

**Triggers**:

- Before Packer build
- On merge to main/develop
- Pre-commit hook (recommended)

---

### 📦 Packer Agent

**Files**: `.github/agents/packer.agent.md`

**Responsibilities**:

- Validate HCL2 syntax across all templates
- Ensure provisioner ordering consistency
- Check variable file completeness
- Verify CIS L2 calls L1 provisioners first
- Build images for all OS targets

**Tools**:

```bash
validate_all_templates     # Check all *.pkr.hcl files
validate_single_template   # Test specific OS
format_packer_template     # Enforce HCL2 standards
build_packer_image        # Execute image build
debug_packer_build        # Inspect failed builds
check_provisioners        # Verify ordering
```

**Triggers**:

- CI/CD validation stage
- Manual build command
- After template edits

**Outputs**:

- Validates to Security Agent
- Feeds image info to Mermaid Agent
- Publishes via Lifecycle Agent

---

### 🏗️ Terraform Agent

**Files**: `.github/agents/terraform.agent.md`

**Responsibilities**:

- Validate Terraform configuration
- Plan and apply Azure resources
- Manage Compute Gallery definitions
- Configure Key Vault for secrets
- Create resource groups and storage

**Tools**:

```bash
terraform_validate        # Check syntax
terraform_plan           # Preview changes
terraform_apply          # Deploy resources
terraform_destroy        # Remove resources
terraform_graph          # Visualize dependencies
list_terraform_variables # Extract vars
```

**Triggers**:

- Infrastructure changes
- Secret updates needed
- Resource cleanup

**Outputs**:

- Validates to Security Agent
- Feeds resource info to Mermaid Agent
- Infrastructure ready for Packer

---

### ✅ Checkov Agent

**Files**: `.github/agents/checkov.agent.md`

**Responsibilities**:

- Scan Packer templates for security best practices
- Scan Terraform for Azure compliance (CKV_AZURE_*)
- Validate shell/PowerShell scripts
- Generate compliance reports
- Check CIS benchmark alignment

**Tools**:

```bash
scan_terraform            # Scan IaC compliance
scan_packer              # Check Packer security
scan_dockerfile          # Container security
generate_report          # JSON compliance report
check_cis_compliance     # CIS alignment check
skip_checks              # Handle false positives
```

**Triggers**:

- Post-validation stage
- Compliance review needed
- Security audit

**Outputs**:

- Reports to Security Agent
- Feeds findings to Documentation Agent

---

### 📊 Mermaid Agent

**Files**: `.github/agents/mermaid.agent.md`

**Responsibilities**:

- Create workflow diagrams
- Document architecture
- Visualize provisioner sequence
- Generate dependency graphs
- Create state machines for image lifecycle

**Diagram Types**:

```text
flowchart       - Build pipeline flow
graph           - Dependency trees
sequence        - Provisioner ordering
stateDiagram    - Image lifecycle
classDiagram    - Resource relationships
```

**Triggers**:

- After major changes
- Documentation updates
- Architecture reviews

**Outputs**:

- Embeds in README
- Referenced by Documentation Agent
- Part of project wiki

---

### 📖 Documentation Agent

**Files**: `.github/agents/documentation.agent.md`

**Responsibilities**:

- Maintain README files (root + per-OS)
- Document all variables and their purposes
- Create CIS control mapping
- Update quick-start guides
- Maintain API documentation

**Tools**:

```bash
find_readme_files         # Locate all docs
document_packer_structure # Extract provisioners
list_shared_scripts       # Index scripts
cis_control_mapping       # Map CIS to scripts
update_variable_docs      # Sync variable docs
```

**Triggers**:

- Post-documentation stage
- README edits
- Variable changes

**Outputs**:

- Updates README.md
- Creates docs/CIS-MAPPING.md
- Provides context for Mermaid Agent

---

### 🔄 Update Agent

**Files**: `.github/agents/update.agent.md`

**Responsibilities**:

- Scan for outdated versions
- Update Packer provider versions
- Update Terraform versions
- Check CIS benchmark updates
- Manage baseline agent updates
- Sync shared script changes

**Tools**:

```bash
scan_outdated_versions    # Find old versions
update_packer_version     # Bump Packer
update_terraform_version  # Bump Terraform
check_cis_updates         # Check benchmarks
validate_after_update     # Test after changes
rollback_update          # Revert if needed
```

**Triggers**:

- Weekly version check
- Security updates available
- Dependency updates

**Outputs**:

- Feeds version info to Packer/Terraform Agents
- Triggers re-validation

---

### 🔁 Lifecycle Agent

**Files**: `.github/agents/lifecycle.agent.md`

**Responsibilities**:

- Manage image versioning (YYYY.MM.DD)
- Publish images to Compute Gallery
- Mark old images for deprecation
- Manage image retirement
- Track image lineage
- Handle rollback scenarios

**Tools**:

```bash
version_image             # Assign version
publish_to_gallery        # Push image
mark_deprecated           # Retire old image
create_image_tags         # Tag with metadata
list_gallery_images       # Inventory images
deprecate_image_version   # Schedule removal
rollback_image            # Restore previous
```

**Triggers**:

- After successful Packer build
- Scheduled maintenance
- Deprecation policy checks

**Outputs**:

- Final stage in build workflow
- Images available to teams

---

## Data Flow Between Agents

### 1. Template Validation Flow

```text
Developer → Packer Agent (validate)
                    ↓
         [template syntax valid?]
                    ↓
                Security Agent (scan controls)
                    ↓
         [no secrets? CIS rules OK?]
                    ↓
                Checkov Agent (policy check)
                    ↓
         ✅ Ready for build
```

### 2. Infrastructure Setup Flow

```text
Terraform Agent (init/plan)
         ↓
  [resources defined?]
         ↓
  Security Agent (scan vars)
         ↓
  Checkov Agent (compliance)
         ↓
  ✅ Ready to apply
```

### 3. Documentation Flow

```text
Packer Template + Terraform Config
         ↓
Documentation Agent (extract info)
         ↓
Mermaid Agent (visualize)
         ↓
README + Diagrams + CIS Mapping
```

### 4. Version Update Flow

```text
Update Agent (scan versions)
         ↓
[newer version available?]
         ↓
Packer/Terraform Agents (update)
         ↓
Security + Checkov Agents (validate)
         ↓
✅ Updated or ⏮️ Rollback
```

## MCP Server Usage

All agents use two MCP servers for context:

### Filesystem MCP Server

- **Purpose**: Read project files, navigate directories
- **Used By**: All agents
- **Operations**:
  - List directories
  - Read template files
  - Search for patterns
  - Find file locations

### Memory MCP Server

- **Purpose**: Maintain agent conversation context
- **Used By**: All agents
- **Operations**:
  - Remember previous analysis
  - Track multi-step workflows
  - Store validation results
  - Maintain state between calls

## Error Handling & Escalation

```text
┌─────────────────┐
│  Agent Detects  │
│     Error       │
└────────┬────────┘
         │
         ▼
    [Severity?]
         │
    ┌────┴────┐
    │          │
 LOW      CRITICAL
    │          │
    ▼          ▼
 Log &    Stop & Alert
 Continue Security Agent
         │
         ▼
  Documentation Agent
     (incident log)
```

## Integration with Azure DevOps Pipeline

All agents are called during pipeline execution:

```yaml
stages:
  - Validation (Security → Packer → Terraform → Checkov)
  - Documentation (Documentation → Mermaid)
  - Build (Packer build)
  - Infrastructure (Terraform apply)
  - Publish (Lifecycle)
```

See [azure-pipelines.yml](../pipelines/azure-pipelines.yml) for details.

## Agent Communication Protocol

Agents communicate through:

1. **Shared Context** (via MCP memory server)
   - Previous validation results
   - Discovered files/resources
   - Error states

2. **File System** (via MCP filesystem server)
   - Read templates
   - Check variables
   - Access hardening scripts

3. **CLI Output** (standard out/err)
   - Validation results
   - Error messages
   - Build status

4. **Artifacts** (generated files)
   - Reports (Checkov JSON)
   - Diagrams (Mermaid files)
   - Documentation (README updates)

## Best Practices for Agent Workflows

### ✅ Do's

- ✓ Run Security Agent first before Packer Agent
- ✓ Validate both Packer and Terraform before building
- ✓ Use Checkov to catch compliance issues early
- ✓ Document as you code (keep Mermaid Agent running)
- ✓ Run Update Agent weekly to catch version drift
- ✓ Use Lifecycle Agent to track image versions

### ❌ Don'ts

- ✗ Skip Security Agent - secrets WILL leak
- ✗ Build without Packer Agent validation
- ✗ Ignore Checkov findings
- ✗ Commit secrets to git (Security Agent catches this)
- ✗ Build different OS targets without consistent provisioner ordering

---

**Last Updated**: February 18, 2026  
**All Agents**: Connected and Validated ✅
