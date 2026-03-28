# Azure Terraform Interview Repo

This repository provisions Azure infrastructure using **Terraform Cloud Stacks**, with a reusable component deployed to multiple environments (`dev` and `prod`).

## Architecture

- `components/environment/`: Reusable Terraform component that provisions a complete environment
- `stacks/acme.stack.yaml`: Stack definition deploying the component to dev and prod workspaces
- `.github/workflows/terraform.yml`: CI workflow for validation and quality checks

Each environment provisions:

- One resource group
- One VNet (using a module from Terraform Registry)
- One Linux VM
- One Storage Account with a Blob container

## Terraform Cloud Stacks

This repository uses **Terraform Cloud Stacks** to manage multiple environment deployments from a single component configuration. Benefits include:

- **Single source of truth**: One component definition for all environments
- **Declarative configuration**: Environment-specific values in YAML
- **Unified state management**: Terraform Cloud manages state for all workspaces
- **Atomic deployments**: Deploy multiple environments together or individually

### Stack Structure

```
stacks/acme.stack.yaml       # Stack definition
├── dev deployment           → workspace: acme-dev (East US)
└── prod deployment          → workspace: acme-prod (West Europe)

components/environment/      # Reusable component
├── main.tf                  # Resources
├── variables.tf             # Input variables
├── outputs.tf               # Outputs
├── providers.tf             # Provider configuration
└── versions.tf              # Terraform and provider versions
```

## Prerequisites

### Terraform Cloud Setup

1. **Create an organization** in Terraform Cloud (e.g., `mokapot`)

2. **Connect VCS provider** (GitHub) to your organization:
   - Go to Organization Settings → VCS Connections
   - Add GitHub connection and authorize the repository

3. **Configure Azure credentials** via OIDC:
   - Go to Organization Settings → Authentication → Azure
   - Configure OIDC authentication with your Azure AD application
   - Required Azure AD app permissions:
     - `Contributor` role on the target subscription

4. **Create stack variables** in Terraform Cloud:
   - Navigate to the stack after initial run
   - Set the following variables:
     - `admin_ssh_public_key` (sensitive): Your SSH public key for VM access
     - `admin_cidrs_dev` (optional): CIDR ranges for dev VM SSH access

### Local Setup (Optional)

- Terraform CLI `>= 1.10` (required for Stacks)
- Terraform Cloud API token configured via `terraform login` or `TF_CLOUD_TOKEN`

## Getting Started

### Initialize and Deploy via Terraform Cloud UI

1. Push your changes to the `main` branch
2. Terraform Cloud will automatically detect the stack configuration
3. Review and apply deployments in the Terraform Cloud UI

### Initialize and Deploy via CLI

```bash
# Navigate to the stack directory
cd stacks

# Initialize the stack
terraform init

# Preview the plan for all deployments
terraform stack plan

# Apply the stack (deploys both dev and prod)
terraform stack apply

# Or deploy a specific deployment
terraform stack apply -target=deployment.dev
terraform stack apply -target=deployment.prod
```

### Pull Request Workflow

When you open a pull request:

1. GitHub Actions runs quality checks (fmt, validate, tflint)
2. Terraform Cloud automatically creates plans for review (if VCS integration is enabled)
3. Plans are posted as comments on the PR

### Production Deployment Gates

For production deployments with approval gates:

1. Configure workspace-level run triggers in Terraform Cloud
2. Set up team permissions and required approvals
3. Production changes require manual approval before apply

## Environment Configuration

### Development (`dev`)

| Variable | Value |
|----------|-------|
| `location` | `eastus` |
| `address_space` | `10.10.0.0/16` |
| `workload_subnet_cidr` | `10.10.1.0/24` |
| `private_subnet_cidr` | `10.10.2.0/24` |
| `enable_public_ip` | `true` |
| `admin_cidrs` | Configured via stack variable |

### Production (`prod`)

| Variable | Value |
|----------|-------|
| `location` | `westeurope` |
| `address_space` | `10.20.0.0/16` |
| `workload_subnet_cidr` | `10.20.1.0/24` |
| `private_subnet_cidr` | `10.20.2.0/24` |
| `enable_public_ip` | `false` |
| `admin_cidrs` | `[]` (no public access) |

## Component Variables

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

1. **Format check**: `terraform fmt -check`
2. **Validation**: `terraform validate` on component and stack
3. **Linting**: TFLint with custom rules
4. **Documentation**: Ensures generated docs are in sync (for modules)

Terraform Cloud handles plan and apply operations via VCS integration.

## Migration from Environment Roots

This repository previously used separate `environments/dev/` and `environments/prod/` directories. The migration to Stacks provides:

- Eliminated code duplication
- Centralized environment configuration
- Terraform Cloud native state management
- Simplified CI/CD (no Azure backend bootstrap needed)

## Module Documentation

The VNet module is sourced from the Terraform Registry (`app.terraform.io/mbarcia/vnet/azurerm`). Refer to the module's documentation for detailed configuration options.

## Troubleshooting

### Stack Initialization Fails

Ensure you're using Terraform CLI >= 1.10:
```bash
terraform version
```

### Azure Authentication Errors

Verify OIDC configuration in Terraform Cloud:
1. Check Azure AD app registration exists
2. Verify federated credentials are configured
3. Confirm Contributor role assignment on the subscription

### Workspace Not Created

Stack deployments create workspaces automatically on first apply. Ensure:
1. VCS integration is properly configured
2. You have permission to create workspaces in the organization
