# Azure Terraform Interview Repo

This repository provisions Azure infrastructure using **Terraform Stacks**, with a reusable component deployed to multiple environments (`dev` and `prod`).

## Architecture

- `components/environment/`: Reusable Terraform module that provisions a complete environment
- `stacks/`: Terraform Stacks configuration deploying the component to dev and prod
- `.github/workflows/terraform.yml`: CI workflow for validation and quality checks

Each environment provisions:

- One resource group
- One VNet (using a module from Terraform Registry)
- One Linux VM
- One Storage Account with a Blob container

## Terraform Stacks

This repository uses **Terraform Stacks** to manage multiple environment deployments from a single component configuration. Benefits include:

- **Single source of truth**: One component definition for all environments
- **Declarative configuration**: Environment-specific values in `.tfdeploy.hcl`
- **Native Terraform syntax**: HCL-based configuration (`.tfcomponent.hcl`, `.tfdeploy.hcl`)
- **Unified deployments**: Deploy multiple environments together or individually

### Stack Structure

```
stacks/
├── components.tfcomponent.hcl    # Component blocks sourcing modules
├── deployments.tfdeploy.hcl      # Deployment blocks with per-env inputs
├── providers.tfcomponent.hcl     # Provider configurations
└── variables.tfcomponent.hcl     # Variable definitions

components/environment/           # Reusable Terraform module
├── main.tf                       # Resources
├── variables.tf                  # Input variables
├── outputs.tf                    # Outputs
├── providers.tf                  # Provider requirements
└── versions.tf                   # Terraform and provider versions
```

### Configuration Files

**`components.tfcomponent.hcl`** - Defines infrastructure components:
```hcl
component "environment" {
  source = "../components/environment"
  inputs = {
    environment    = var.environment
    location       = var.location
    ...
  }
  providers = {
    azurerm = provider.azurerm.this
  }
}
```

**`deployments.tfdeploy.hcl`** - Defines environment-specific deployments:
```hcl
deployment "dev" {
  inputs = {
    environment      = "dev"
    location         = "eastus"
    enable_public_ip = true
  }
}

deployment "prod" {
  inputs = {
    environment      = "prod"
    location         = "westeurope"
    enable_public_ip = false
  }
}
```

## Prerequisites

- Terraform CLI `>= 1.10` (required for Stacks)
- Azure subscription access with permissions to create resource groups, networking, compute, and storage resources
- Azure credentials configured via one of:
  - Azure CLI (`az login`)
  - Service Principal with OIDC (recommended for CI/CD)
  - Service Principal with client secret/certificate

## Getting Started

### Initialize and Deploy via CLI

```bash
# Navigate to the stacks directory
cd stacks

# Initialize the stack (downloads providers)
terraform init

# Preview the plan for all deployments
terraform plan

# Apply the stack (deploys both dev and prod)
terraform apply

# Or deploy a specific deployment
terraform apply -target=deployment.dev
terraform apply -target=deployment.prod
```

### Required Variables

The following variables must be provided (either via `-var`, environment variables, or a `.tfvars` file):

| Variable | Type | Description |
|----------|------|-------------|
| `admin_ssh_public_key` | string | SSH public key for VM access (sensitive) |

You can provide this via environment variable:
```bash
export TF_VAR_admin_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"
```

### Pull Request Workflow

When you open a pull request, GitHub Actions runs:

1. **Format check**: `terraform fmt -check`
2. **Validation**: `terraform validate` on component module and stack
3. **Linting**: TFLint with custom rules

## Environment Configuration

### Development (`dev`)

| Variable | Value |
|----------|-------|
| `environment` | `dev` |
| `location` | `eastus` |
| `location_short` | `eus` |
| `address_space` | `10.10.0.0/16` |
| `workload_subnet_cidr` | `10.10.1.0/24` |
| `private_subnet_cidr` | `10.10.2.0/24` |
| `enable_public_ip` | `true` |
| `admin_cidrs` | `["203.0.113.10/32"]` |

### Production (`prod`)

| Variable | Value |
|----------|-------|
| `environment` | `prod` |
| `location` | `westeurope` |
| `location_short` | `weu` |
| `address_space` | `10.20.0.0/16` |
| `workload_subnet_cidr` | `10.20.1.0/24` |
| `private_subnet_cidr` | `10.20.2.0/24` |
| `enable_public_ip` | `false` |
| `admin_cidrs` | `[]` |

## Component Module Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `environment` | string | Environment name (required) | - |
| `project_name` | string | Project identifier | `acme` |
| `location` | string | Azure region | - |
| `location_short` | string | Short region code | - |
| `address_space` | list(string) | VNet CIDR blocks | - |
| `workload_subnet_cidr` | string | Workload subnet CIDR | - |
| `private_subnet_cidr` | string | Private subnet CIDR | - |
| `vm_size` | string | VM SKU | `Standard_B2s` |
| `admin_username` | string | VM admin username | `azureuser` |
| `admin_ssh_public_key` | string | SSH public key (sensitive) | - |
| `admin_cidrs` | list(string) | Allowed SSH CIDRs | `[]` |
| `enable_public_ip` | bool | Attach public IP to VM | `false` |
| `storage_container_name` | string | Blob container name | `appdata` |
| `ddos_protection_plan_id` | string | Optional DDoS plan ID | `null` |
| `extra_tags` | map(string) | Additional tags | `{}` |

## Security Notes

- The VNet module supports subnet-specific NSGs and optional service delegation
- The `dev` VM is reachable only from configured admin CIDRs
- The `prod` VM has no public IP by default
- Blob public access is disabled
- Minimum TLS 1.2 for the Storage Account is enforced
- Tags are standardized to improve ownership and cost tracking
- SSH public key authentication only (no passwords)

## CI/CD Pipeline

The GitHub Actions workflow performs quality checks on every PR and push:

1. **Format check**: `terraform fmt -check -recursive`
2. **Validation**: `terraform validate` on component module and stack
3. **Linting**: TFLint across all directories

Deployment is performed manually via `terraform apply` or can be integrated with CI/CD platforms that support Terraform Stacks.

## Migration from Environment Roots

This repository previously used separate `environments/dev/` and `environments/prod/` directories. The migration to Terraform Stacks provides:

- Eliminated code duplication (single component module)
- Centralized environment configuration in HCL
- Native Terraform syntax (no YAML)
- Simplified state management (per-deployment state files)

## Module Documentation

The VNet module is sourced from the Terraform Registry (`app.terraform.io/mbarcia/vnet/azurerm`). Refer to the module's documentation for detailed configuration options.

## Troubleshooting

### Terraform Version Error

Ensure you're using Terraform CLI >= 1.10:
```bash
terraform version
```

### Azure Authentication Errors

Verify your Azure credentials:
```bash
az login
az account show
```

Or configure service principal credentials via environment variables:
```bash
export ARM_CLIENT_ID=<client-id>
export ARM_CLIENT_SECRET=<client-secret>
export ARM_SUBSCRIPTION_ID=<subscription-id>
export ARM_TENANT_ID=<tenant-id>
```

### Provider Installation Fails

Clear the provider cache and reinitialize:
```bash
rm -rf .terraform
terraform init
```
