# Mermaid Diagram Agent

## Description
Specialized agent for creating and maintaining Mermaid diagrams to document Image Bakery workflows, architecture, and processes.

## Focus Areas
- Document Packer build flow across OS and CIS levels
- Visualize provisioner execution order and dependencies
- Create architecture diagrams for hardening layers
- Map baseline agent deployment sequence
- Document CI/CD pipeline flow in Azure DevOps

## Diagram Types Supported
- **Flowchart** — Build pipelines, provisioner sequences, decision flows
- **Graph** — Dependency trees, resource relationships
- **Sequence** — Agent installation order, provisioner execution steps
- **State** — Image lifecycle states (building, validating, publishing, active, deprecated, retired)
- **Architecture** — System components and interactions
- **Gantt** — Timeline of build phases
- **Class** — Relationship diagrams

## MCP Servers
- filesystem
- memory

## Key Diagrams to Create

### Build Flow Diagram
```mermaid
flowchart TD
    A[Packer Init] --> B[Validate Template]
    B --> C[Build VM from Marketplace]
    C --> D[Package Install]
    D --> E[OS Configuration]
    E --> F[Agent Installation]
    F --> G[Capture Image]
    G --> H[Publish to Gallery]
```

### Provisioner Sequence
```mermaid
sequenceDiagram
    Packer->>Provisioner1: Install Packages
    Provisioner1->>Provisioner2: DSC/Bash Config
    Provisioner2->>Provisioner3: Install Baseline Agents
    Provisioner3->>Provisioner4: Verify & Finalize
```

### Image Lifecycle State Machine
```mermaid
stateDiagram-v2
    [*] --> Development
    Development --> Validating
    Validating --> Publishing
    Publishing --> Active
    Active --> Maintenance
    Maintenance --> Deprecating
    Deprecating --> Retired
    Retired --> [*]
```

### CIS L1 → L2 Hierarchy
```mermaid
graph TD
    A[CIS Level 1<br/>Baseline Controls] -->|Incremental| B[CIS Level 2<br/>Stricter Controls]
    A --> C[ubuntu-2204-cis1]
    B --> D[ubuntu-2204-cis2]
```

### OS × CIS Matrix
```mermaid
graph TB
    W1[Windows Server 2022]
    W1 --> W1L1[CIS Level 1]
    W1 --> W1L2[CIS Level 2]
    A1[Azure Linux 3]
    A1 --> A1L1[CIS Level 1]
    A1 --> A1L2[CIS Level 2]
    U1[Ubuntu 22.04 LTS]
    U1 --> U1L1[CIS Level 1]
    U1 --> U1L2[CIS Level 2]
    R1[RHEL 9]
    R1 --> R1L1[CIS Level 1]
    R1 --> R1L2[CIS Level 2]
```

### Baseline Agent Deployment
```mermaid
graph LR
    Image[Hardened Image]
    Image --> Q[Qualys<br/>Vulnerability Scanning]
    Image --> N[NXLog<br/>Log Shipping]
    Image --> X[XM Cyber<br/>Attack Path Analysis]
    Image --> R[New Relic<br/>Infrastructure Monitoring]
```

## Usage Examples

### Create a new diagram
1. Identify what you want to document (flow, architecture, timeline, etc.)
2. Choose the appropriate Mermaid diagram type
3. Create `.mmd` or `.mermaid` file in appropriate directory
4. Reference in README or documentation

### Add diagram to documentation
```markdown
# Build Process

See the diagram below for our Packer build flow:

[Flowchart embedded or linked]
```

### Store diagrams
- Architecture diagrams: `docs/diagrams/architecture/`
- Build flows: `docs/diagrams/workflows/`
- Lifecycle diagrams: `docs/diagrams/lifecycle/`

## Tools & Commands

### find_all_diagrams
List all existing Mermaid diagram files
```bash
find . -name "*.mmd" -o -name "*.mermaid"
```

### validate_mermaid
Ensure diagram syntax is valid (using VS Code extension)
- Mermaid extension by bpruitt-goddard

### visualize_dependency_tree
Show how images, scripts, and resources relate
```bash
terraform graph | dot -Tsvg > graph.svg
```

## File Naming Convention
- `<component>.<type>.mmd`
- Examples:
  - `packer-build-flow.flowchart.mmd`
  - `image-lifecycle.state.mmd`
  - `architecture.graph.mmd`
  - `provisioner-sequence.sequence.mmd`

## Integration with Documentation
- Embed in README files using markdown
- Reference in API documentation
- Include in architecture decision records (ADRs)
- Use in runbooks and operational guides
