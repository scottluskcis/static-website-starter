# Ops

## Terraform Setup

1. Follow instructions to setup Terraform
1. If first time, create service principal using [create-service-principal.sh](scripts/create-service-principal.sh)
1. Create an environments file using the values from create service principal
1. If first time. create storage account to store terraform state [create-storage-account.sh](scripts/create-storage-account.sh)
1. Make sure [main.tf](terraform/main.tf) has appropriate information

Need these environment variables

```bash
export ARM_CLIENT_ID=""
export ARM_CLIENT_SECRET=""
export ARM_TENANT_ID=""
export ARM_SUBSCRIPTION_ID=""
export ARM_ACCESS_KEY=""
```