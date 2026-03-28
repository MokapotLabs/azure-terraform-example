# Azure Terraform Interview Repo

This repository provisions a reusable Azure Virtual Network module and two sample environments, `dev` and `prod`, using Terraform and GitHub Actions.

## Architecture

- `bootstrap/`: one-time stack that creates the Azure Storage backend used for remote Terraform state.
- `modules/vnet/`: reusable VNet module with subnet, NSG, and subnet association support.
- `environments/dev/`: sample development environment in `eastus`.
- `environments/prod/`: sample production environment in `westeurope`.
- `.github/workflows/terraform.yml`: CI/CD pipeline for validation, planning, and gated deployment.

Each environment provisions:

- one resource group
- one VNet built from the reusable module
- one Linux VM
- one Storage Account plus a Blob container

## Why Resource Groups Instead Of Separate Subscriptions?

For this interview sample, `dev` and `prod` live in separate resource groups inside a single Azure subscription. That keeps the implementation easy to review and practical to run in a demo tenant while still showing clear environment boundaries and naming.

In a larger production estate, separate subscriptions are usually stronger because they improve:

- blast-radius isolation
- policy separation
- budget ownership
- RBAC boundaries
- quota management

The environment roots in this repo are intentionally structured so they can be moved to separate subscriptions later with minimal code changes.

## Prerequisites

- Terraform `>= 1.6`
- Azure subscription access with permissions to create resource groups, networking, compute, and storage resources
- GitHub repository with Actions enabled
- GitHub OIDC trust configured for Azure authentication
- An SSH public key available for VM access

Repository-level GitHub variables expected by the workflow:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT`
- `TFSTATE_CONTAINER`
- `TF_DEV_ADMIN_CIDRS`
  - Example: `["203.0.113.10/32"]`
- `TF_PROD_ADMIN_CIDRS`
  - Example: `[]`

Repository-level GitHub secrets expected by the workflow:

- `TF_ADMIN_SSH_PUBLIC_KEY`

GitHub Environments:

- `dev`: optional environment boundary for the automatic development deployment
- `prod`: protected environment used to gate the manual production deployment

## Bootstrap Remote State

The `bootstrap` stack intentionally uses local state because it creates the remote backend that the environment stacks depend on.

```bash
cd bootstrap
az login
terraform init
terraform plan
terraform apply
```

Capture these outputs after apply:

- state resource group name
- storage account name
- blob container name

Store them in the repository variables listed above.

## Environment Usage

Initialize an environment with backend settings from your bootstrap resources:

```bash
cd environments/dev
terraform init \
  -backend-config="resource_group_name=<tfstate-rg>" \
  -backend-config="storage_account_name=<tfstate-sa>" \
  -backend-config="container_name=<tfstate-container>" \
  -backend-config="key=dev.tfstate"
terraform plan
```

Repeat the same pattern for `prod`, using `key=prod.tfstate`.

Terraform variables that commonly change per environment:

- `project_name`
- `location`
- `location_short`
- `address_space`
- `workload_subnet_cidr`
- `private_subnet_cidr`
- `vm_size`
- `admin_cidrs`
- `enable_public_ip`

## Release Lifecycle

The GitHub Actions workflow models a simple release lifecycle:

1. Pull requests run `fmt`, `validate`, `tflint`, `terraform-docs` checks, plus `plan` for both `dev` and `prod`.
2. A merge to `main` automatically applies `dev`.
3. `prod` is deployed manually with `workflow_dispatch` and should be protected by a GitHub Environment approval gate.

This gives fast feedback for development while keeping production promotion explicit and reviewable.

## Security Notes

- The VNet module supports subnet-specific NSGs and optional service delegation.
- The `dev` VM is reachable only from the configured admin CIDRs.
- The `prod` VM has no public IP by default.
- Blob public access is disabled.
- Minimum TLS for the Storage Account is enforced.
- Tags are standardized to improve ownership and cost tracking.

## Module Documentation

The module README is designed to be updated with `terraform-docs`.

```bash
terraform-docs markdown table --config .terraform-docs.yml modules/vnet
```

The CI workflow checks that generated module documentation stays in sync.

## Terraform Cloud Compatibility

This implementation uses Azure-native remote state because it keeps the submission self-contained and directly aligned to Azure plus GitHub.

Terraform Cloud remains a compatible future option. The environment roots can be moved to a Terraform Cloud backend without redesigning the module or environment composition. If you wanted to extend this into a broader platform setup, Terraform Cloud would be a reasonable place to add centralized runs, policy enforcement, workspace management, and team workflows.
