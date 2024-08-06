# DevOps Infrastructure

This repository contains the Terraform configuration for setting up the infrastructure for the PR Service.

## Setup

1. Install Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli
2. Configure AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html

## Steps

1. Clone the repository.
2. Initialize Terraform:

```sh
terraform init
```

3. Apply the Terraform configuration:

```sh
terraform apply
```

## Variables

- `github_token`: GitHub token for accessing the repository.