# Azure Terraform Interview Component

This repository publishes a reusable **Terraform Stack component configuration** to the HCP Terraform private registry. It is the versioned building block, not the live environment runner.

The actual `dev` and `prod` deployments should be created from a separate consumer Stack repository that references this published component.

## What This Component Provisions

Each deployment of this component creates:

- one Azure resource group
- one VNet from the published `vnet` module
- one Linux VM
- one Storage Account and private Blob container

## Repository Layout

```text
.
├── .terraform-version
├── .terraform.lock.hcl
├── components.tfcomponent.hcl
├── providers.tfcomponent.hcl
├── variables.tfcomponent.hcl
└── components/environment/
```

The root `*.tfcomponent.hcl` files define the published Stack component configuration. The `components/environment/` directory contains the reusable Terraform module logic used by that component configuration.

## Consumer Model

The intended operating model is:

1. Publish this repository to the HCP Terraform private registry as a Stack component configuration.
2. Create a second repository that consumes the published component with a `stack` block.
3. Define `dev` and `prod` in that second repository’s `*.tfdeploy.hcl` files.
4. Run plans and applies in HCP Terraform from the consumer Stack.

This keeps versioned infrastructure design separate from live environment orchestration.

## OIDC Inputs

This component is designed to receive Azure workload identity inputs from a consuming Stack:

- `client_id`
- `tenant_id`
- `subscription_id`
- `identity_token`

The root `azurerm` provider is configured for OIDC and expects the consuming Stack to generate the JWT with an `identity_token` block and pass it through as an ephemeral variable.

## Usage Shape

The consumer Stack should follow the private registry usage model:

```hcl
stack "environment" {
  source  = "<ORGANIZATION>/<COMPONENT_NAME>"
  version = "~> 2.0"

  inputs = {
    environment        = var.environment
    location           = var.location
    client_id          = var.client_id
    tenant_id          = var.tenant_id
    subscription_id    = var.subscription_id
    identity_token     = var.identity_token
    admin_ssh_public_key = var.admin_ssh_public_key
  }
}
```

Copy the exact `stack` block snippet from the registry UI when you publish a new version, since the final source address depends on the organization and component name you chose in HCP Terraform.

## Validation

Local validation for this component repo:

```bash
terraform stacks init
terraform stacks validate
terraform -chdir=components/environment init -backend=false
terraform -chdir=components/environment validate
```

Validation is intended to run locally via `pre-commit` for this published component configuration.

Install and enable it with:

```bash
pip install pre-commit
pre-commit install
```

The configured hooks run formatting, `tflint`, component validation, and Stack validation before commit.

## Notes

- The VNet module source remains `app.terraform.io/mbarcia/vnet/azurerm`; ensure the consuming Stack runs in an HCP Terraform organization that can resolve that private module.
- This repo no longer carries live `dev` and `prod` deployment definitions at root level.
