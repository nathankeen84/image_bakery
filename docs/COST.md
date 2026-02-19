# Azure Infrastructure Cost Estimate

## Summary

**Monthly Cost (Standard Usage): $28-35**  
**Annual Cost (Standard Usage): $336-420**  
**Monthly Cost (Optimized): $18-25**  
**Annual Cost (Optimized): $216-300**

---

## Detailed Breakdown

### 1. Storage Account (Standard LRS)
- **Base Cost**: $0.02/month
- **Blob Storage**: 500 GB × $0.0184/GB = $9.20/month
- **Transactions**: 10,000 operations/day = $1.50/month
- **Subtotal**: ~$10.75/month

### 2. Key Vault
- **Standard Tier**: $0.60/month
- **Operations**: $0.04/month (10K/month)
- **Subtotal**: ~$0.65/month

### 3. Shared Image Gallery
- **Gallery & Definitions**: FREE
- **Managed Images**: 16 images × 50GB × $0.0184/GB = $14.72/month
- **Subtotal**: ~$14.72/month

### 4. Networking
- **VNet, NSG, NIC**: FREE
- **Subtotal**: $0.00/month

### 5. Monitoring & Observability
- **Application Insights**: 1 GB/month × $2.50 = $2.50/month
- **Log Analytics**: 1 GB/month × $0.30 = $0.30/month
- **Subtotal**: ~$2.80/month

### 6. Compute (Build VMs - Usage Based)
- **Standard_D2s_v3**: $0.10/hour
- **Assumption**: 4 hours/week = ~$6.40/month
- **Subtotal**: ~$6.40/month (variable)

### 7. Identity & Access (IAM)
- **Service Principal & Role Assignments**: FREE
- **Subtotal**: $0.00/month

---

## Cost Scenarios

### Minimal (Low Activity)
- 100 GB storage, 2 image versions
- 1 hour/week builds
- **Total: ~$18-20/month**

### Standard (Expected)
- 500 GB storage, 16 images
- 4 hours/week builds
- Moderate monitoring
- **Total: ~$28-35/month**

### High Activity
- 2 TB storage, 32+ images
- 20+ hours/week builds
- Heavy monitoring/logging
- **Total: ~$50-75/month**

---

## Cost Optimization Strategies

### 1. Reserved Instances for Build VMs
- **Savings**: 40-50% off on-demand rates
- **Reduction**: ~$3-4/month

### 2. Blob Lifecycle Management
- Archive old images after 90 days
- **Reduction**: ~$2-5/month

### 3. Smaller VM SKU for Testing
- Use Standard_B2s ($0.05/hr) instead of D2s ($0.10/hr)
- **Savings**: 50% on compute

### 4. Storage Tiering
- Move to Cool storage after 30 days: $0.01/GB vs $0.0184/GB
- **Reduction**: ~$3-5/month

### 5. Log Analytics Retention Tuning
- Reduce retention from 31 to 7 days
- **Savings**: ~$2/month

---

## Annual Projections

### Standard Usage (No Optimization)
```
Monthly:  $28-35
Annual:   $336-420
```

### With Optimization (Reserved + Tiering)
```
Monthly:  $18-25
Annual:   $216-300
```

### High Activity (Multi-team, All Images)
```
Monthly:  $50-75
Annual:   $600-900
```

---

## Component Costs Summary

| Component | Monthly | Notes |
|-----------|---------|-------|
| Storage Account | $10.75 | 500GB assumption |
| Key Vault | $0.65 | Standard tier |
| Managed Images | $14.72 | 16 images × 50GB |
| Networking | $0.00 | VNet/NSG/NIC free |
| Monitoring | $2.80 | App Insights + Log Analytics |
| Build VMs | $6.40 | Usage-based, 4 hrs/week |
| IAM/RBAC | $0.00 | Service Principal free |
| **Total** | **$35.32** | **Plus overages** |

---

## Important Notes

- Prices based on **Azure East US** region (February 2026)
- Does not include free tier or 12-month trial benefits
- Enterprise discounts may apply (contact Azure Sales)
- Bandwidth costs minimal (<1 GB external egress/month)
- VPN/ExpressRoute charges not included
- Regional pricing may differ significantly
- Use [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) for precise estimates

---

## Cost Management Tools

1. **Azure Cost Management + Billing**
   - Track actual vs. budgeted spending
   - Set up budget alerts

2. **Advisor Recommendations**
   - Azure Advisor highlights cost optimization opportunities

3. **Reserved Instances**
   - Commit 1-3 years for significant discounts

4. **Spot Instances** (for testing)
   - Save up to 90% for interruptible workloads

---

## Next Steps

1. Review with finance/billing team
2. Consider reserved capacity for build VMs if using >20 hrs/month
3. Implement lifecycle policies for image storage
4. Monitor actual costs via Azure Cost Management
5. Adjust compute SKU based on build performance
