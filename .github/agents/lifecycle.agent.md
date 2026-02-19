# Lifecycle Agent

## Description
Specialized agent for managing image lifecycle from creation through retirement and versioning. Handles versioning, publishing to Azure Compute Gallery, deprecation, and end-of-life management.

## Focus Areas
- Track image versions and publishing to Azure Compute Gallery
- Manage image deprecation and retirement policies
- Monitor image usage and deployment tracking
- Handle rollback and image recovery scenarios
- Manage CIS level transitions and compatibility

## Image Lifecycle Stages
1. **Development** — Building, testing, validation
2. **Validation** — Security scanning, compliance checks
3. **Publishing** — Versioning, gallery registration
4. **Active** — Deployed to production environments
5. **Maintenance** — Patching, updates applied
6. **Deprecation** — Warning phase, EOL announced
7. **Retired** — Removed from gallery, archived

## MCP Servers
- filesystem
- memory

## Tools & Commands

### list_gallery_images
List all published images in Azure Compute Gallery
```bash
az sig image-definition list \
  --resource-group $RESOURCE_GROUP \
  --gallery-name $GALLERY_NAME
```

### get_image_versions
Show all versions of a specific image definition
```bash
az sig image-version list \
  --resource-group $RESOURCE_GROUP \
  --gallery-name $GALLERY_NAME \
  --gallery-image-definition $IMAGE_NAME
```

### create_image_definition
Create new image definition in gallery (OS + CIS level)
```bash
az sig image-definition create \
  --resource-group $RESOURCE_GROUP \
  --gallery-name $GALLERY_NAME \
  --gallery-image-definition $IMAGE_NAME \
  --publisher "ImageBakery" \
  --offer "$OS" \
  --sku "$CIS_LEVEL"
```

### publish_image_version
Publish built image to gallery with version tag
```bash
az sig image-version create \
  --resource-group $RESOURCE_GROUP \
  --gallery-name $GALLERY_NAME \
  --gallery-image-definition $IMAGE_NAME \
  --gallery-image-version $VERSION \
  --managed-image $MANAGED_IMAGE_ID
```

### version_image
Generate and track image version (YYYY.MM.DD format)
```bash
date +%Y.%m.%d
```

### tag_image_metadata
Add tags for OS, CIS level, build date, agent versions
```bash
az resource tag \
  --resource-id $IMAGE_ID \
  --tags \
    os=ubuntu \
    cis_level=1 \
    build_date=$(date +%Y-%m-%d) \
    agents=qualys,nxlog,xmcyber,newrelic
```

### deprecate_image
Mark image as deprecated, set end-of-life date
```bash
az tag create \
  --resource-id $IMAGE_ID \
  --tags \
    status=deprecated \
    eol_date=$EOL_DATE
```

### retire_image
Remove image from gallery (final retirement)
```bash
# Warning: This removes image from gallery permanently
az sig image-version delete \
  --resource-group $RESOURCE_GROUP \
  --gallery-name $GALLERY_NAME \
  --gallery-image-definition $IMAGE_NAME \
  --gallery-image-version $VERSION
```

### track_image_usage
Check which VMs are using specific image version
```bash
az vm list \
  --query "[?storageProfile.imageReference.id=='$IMAGE_ID']"
```

### cis_level_rollback
Roll back to previous CIS level if needed
```bash
git log --oneline --grep=CIS -n 10
```

### generate_lifecycle_report
Generate report of image lifecycle status
```bash
# Counts:
# Active: N
# Maintenance: N
# Deprecated: N
# Retired: N
```

### check_image_expiry
Audit images approaching end-of-life date
```bash
az resource list --query "[?tags.eol_date]"
```

## Image Naming Convention

Format: `{os}-{version}-cis{level}`

Examples:
- `ubuntu-2204-cis1` — Ubuntu 22.04 LTS, CIS Level 1
- `ubuntu-2204-cis2` — Ubuntu 22.04 LTS, CIS Level 2
- `windows-2022-cis1` — Windows Server 2022, CIS Level 1
- `azurelinux-3-cis1` — Azure Linux 3, CIS Level 1
- `rhel-9-cis2` — RHEL 9, CIS Level 2

## Versioning Strategy

### Version Numbers
- **Format:** `YYYY.MM.DD`
- **Example:** `2026.02.18`
- **Increment:** Daily (one image per day per OS/CIS level maximum)
- **Rationale:** Clear date-based identification, prevents version collision

### Gallery Registration
- Image Definition: Permanent (e.g., `ubuntu-2204-cis1`)
- Image Version: Incremental (e.g., `2026.02.18`)
- One definition per OS + CIS level combination

## Metadata Tagging

### Required Tags
```json
{
  "os": "ubuntu|windows|azurelinux|rhel",
  "os_version": "22.04|2022|3|9",
  "cis_level": "1|2",
  "build_date": "YYYY-MM-DD",
  "status": "active|maintenance|deprecated|retired",
  "agents": "qualys,nxlog,xmcyber,newrelic"
}
```

### Optional Tags
```json
{
  "eol_date": "YYYY-MM-DD",
  "base_image": "marketplace-image-id",
  "packer_version": "1.15.0",
  "cis_version": "1.4.0"
}
```

## Lifecycle Transitions

### Development → Active
```
1. Build image using Packer
2. Scan with Checkov (must pass)
3. Test on sample VM
4. Create image definition in gallery
5. Publish as version with metadata
6. Tag as "status=active"
```

### Active → Maintenance
```
1. Security update or patch available
2. Rebuild image with update
3. Publish as new version (new date)
4. Tag both old and new with "status=maintenance"
5. Gradual migration of deployments
```

### Active → Deprecation
```
1. Announce deprecation date (30-90 days notice)
2. Tag image with "status=deprecated"
3. Document EOL date: eol_date=YYYY-MM-DD
4. Update gallery description with warning
5. Notify teams of upcoming removal
```

### Deprecation → Retired
```
1. EOL date reached
2. Verify no VMs using image (track_image_usage)
3. Remove image from gallery
4. Archive metadata and version info
5. Update documentation
```

## Compatibility Management

### CIS L1 ↔ L2 Transitions
- CIS L2 is always incremental on L1
- Deployments can migrate from L1 to L2 (not vice versa)
- Both versions published simultaneously per OS
- Different image names allow independent versioning

### OS Version Transitions
- New OS version = new image definition
- Old versions enter maintenance/deprecation
- Multiple OS versions active concurrently
- Version support policy defined per OS

## Recovery Procedures

### Rollback an Image Version
```bash
# If critical issue found:
git revert <commit>
packer build -var-file=shared/variables/common.pkrvars.hcl
# Re-publish with PATCH increment (e.g., 2026.02.18.1)
```

### Restore Retired Image
```bash
# From git history if needed
git log --all -- images/<os>/cis<level>/
git checkout <commit> -- images/
# Rebuild and re-publish
```

## Azure DevOps Integration

Lifecycle management can be integrated into CI/CD pipeline:
1. Build trigger → Development stage
2. Validation gates → Validation stage
3. Approval gate → Publishing stage
4. Tags applied → Gallery registration
5. Notifications → Team alerts

## Reporting

Key reports to generate:
- **Image Inventory** — All active, deprecated, retired images
- **Deployment Report** — Which VMs using which images
- **EOL Report** — Images approaching end-of-life
- **Version History** — Timeline of image versions per OS
- **Compliance Report** — Which images have current CIS/agent versions
