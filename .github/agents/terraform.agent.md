# Terraform Agent

## Description
Specialized agent for Terraform infrastructure-as-code validation, planning, and deployment for Image Bakery Azure resources.

## Focus Areas
- Manage Azure infrastructure (Compute Gallery, resource groups, VMs)
- Support Image Bakery infrastructure-as-code
- Plan and apply Azure resource changes
- Validate Terraform modules and resources

## MCP Servers
- filesystem
- memory

## Tools & Commands

### terraform_validate
Validate Terraform configuration syntax and structure
```bash
terraform validate
```

### terraform_format
Format Terraform files to standard
```bash
terraform fmt -recursive
```

### terraform_init
Initialize Terraform working directory
```bash
terraform init
```

### terraform_plan
Plan Terraform changes (requires -var-file or variables set)
```bash
terraform plan -out=tfplan
```

### terraform_apply
Apply Terraform changes (use with caution in production)
```bash
terraform apply tfplan
```

### terraform_destroy
Destroy Terraform-managed infrastructure (destructive operation)
```bash
terraform destroy
```

### terraform_state_list
List resources in Terraform state
```bash
terraform state list
```

### terraform_state_show
Show details of a resource in Terraform state
```bash
terraform state show <resource>
```

### terraform_graph
Generate a visual representation of Terraform resource dependencies
```bash
terraform graph
```

### list_terraform_modules
Find all Terraform modules in the project
```bash
find . -name "*.tf" -type f
```

### list_terraform_variables
Extract variable definitions from Terraform files
```bash
grep -E "^variable" --include=*.tf -r .
```

### check_resource_naming
Verify resource naming conventions are consistent
```bash
grep -E "resource|data|locals" --include=*.tf -r .
```

## Usage Examples

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format all Terraform files
terraform fmt -recursive

# Plan changes for review
terraform plan -out=tfplan

# Apply approved changes
terraform apply tfplan

# Inspect Terraform graph (pipe to graphviz for visualization)
terraform graph
```

## Image Bakery Azure Resources

This agent manages:
- **Azure Compute Gallery** — Stores versioned VM images
- **Resource Groups** — Containers for gallery and supporting resources
- **Virtual Machines** — Build VMs for Packer (temporary)
- **Managed Images** — Captured images before gallery publishing

## Safety Best Practices
- Always run `terraform plan` before `apply`
- Review the plan carefully for destructive changes (`-/destroy` indicators)
- Use `terraform destroy` with caution in production
- Commit `.tfstate` to version control only if using remote state (recommended)
- Use `terraform lock` to prevent concurrent modifications
