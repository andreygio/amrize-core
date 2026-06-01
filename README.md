# amrize-core — Multi-Cloud Infrastructure

## Overview

This repository provisions and manages multi-cloud infrastructure across **AWS** and **GCP** using **Terragrunt** and **Terraform**. It is structured around three environments (`dev`, `stage`, `prod`) and two infrastructure domains (`networking`, `kubernetes`), deployed on both providers.

### Architectural Summary

```
amrize-core/
├── aws/                        # AWS provider root
│   ├── provider.hcl            # S3 remote state + AWS inputs
│   ├── dev | stage | prod/
│   │   ├── env.hcl             # Account ID, region
│   │   ├── networking/         # VPC, subnets, NAT, route tables
│   │   └── kubernetes/         # EKS cluster + managed node group
├── gcp/                        # GCP provider root
│   ├── provider.hcl            # GCS remote state + GCP inputs
│   ├── dev | stage | prod/
│   │   ├── env.hcl             # Project ID, region, state bucket
│   │   ├── networking/         # VPC, subnet, Cloud NAT
│   │   └── kubernetes/         # GKE cluster + node pool
├── modules/
│   ├── aws/{networking,kubernetes}/   # Reusable Terraform modules
│   └── gcp/{networking,kubernetes}/
├── _envcommon/
│   ├── aws/{networking,kubernetes}.hcl  # Shared module source + defaults
│   └── gcp/{networking,kubernetes}.hcl  # Dependency wiring (networking → kubernetes)
└── .github/workflows/
    ├── ci.yml        # Validate + plan on pull requests
    ├── cd.yml        # Apply on merge to main
    └── cleanup.yml   # Destroy with explicit confirmation guard
```

**Key properties:**
- **Provider-first layout** (`aws/<env>/<module>`) — all AWS resources grouped together, all GCP resources grouped together
- **Separate remote backends** — AWS uses S3 + DynamoDB locking; GCP uses GCS
- **Layered includes** — each module merges root → provider → envcommon → environment overrides
- **OIDC authentication** — no long-lived credentials; GitHub Actions assumes scoped IAM roles and GCP Workload Identities

---

## Setup Instructions

### Prerequisites

| Tool | Version |
|---|---|
| Terraform | >= 1.9.0 |
| Terragrunt | >= 0.67.0 |
| Docker | any recent |
| AWS CLI | >= 2.x |
| gcloud CLI | >= 450.x |

### 1. Bootstrap remote state resources

These must exist before the first `terragrunt init`.

**AWS (per environment)**
```bash
aws s3api create-bucket \
  --bucket terraform-state-<ACCOUNT_ID>-us-east-1 \
  --region us-east-1

aws dynamodb create-table \
  --table-name terraform-locks-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

**GCP (per environment)**
```bash
gsutil mb -p <PROJECT_ID> gs://terraform-state-<PROJECT_ID>
```

### 2. Configure OIDC authentication

**AWS** — create an OIDC provider and three IAM roles in each account:

| Role | Used by | Trust scope |
|---|---|---|
| `GitHubCIRole` | `ci.yml` | `pull_request` events |
| `GitHubCDRole` | `cd.yml` | `ref:refs/heads/main` |
| `GitHubTerraformCleanUp` | `cleanup.yml` | `ref:refs/heads/main` |

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com
```

**GCP** — create a Workload Identity Pool and Provider, then bind a service account per environment. See [GCP Workload Identity Federation docs](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines).

### 3. Configure GitHub Environments

In the repository under **Settings → Environments**, create `dev`, `stage`, and `prod`. Add the following secrets and variables to each:

| Key | Type | Description |
|---|---|---|
| `AWS_CI_ROLE_ARN` | Secret | ARN of `GitHubCIRole` for this account |
| `AWS_CD_ROLE_ARN` | Secret | ARN of `GitHubCDRole` for this account |
| `AWS_CLEANUP_ROLE_ARN` | Secret | ARN of `GitHubTerraformCleanUp` for this account |
| `GCP_WORKLOAD_PROVIDER` | Secret | Workload Identity Provider resource name |
| `GCP_SERVICE_ACCOUNT` | Secret | Service account email |
| `AWS_REGION` | Variable | AWS region (e.g. `us-east-1`) |

Enable **required reviewers** on `stage` and `prod` environments to gate deployments.

### 4. Update environment variables

Edit each `*/env.hcl` with real values:

```
aws/dev/env.hcl   → aws_account_id, aws_region
gcp/dev/env.hcl   → gcp_project_id, gcp_region, gcp_state_bucket
```

Repeat for `stage` and `prod`.

### 5. Deployment

```bash
# Plan a single module
cd aws/dev/networking && terragrunt plan

# Apply a full environment
cd aws/dev && terragrunt run-all apply

# Apply all environments for one provider
cd aws && terragrunt run-all apply
```

The CI pipeline runs validate + plan automatically on every PR. The CD pipeline applies to the target environment on merge to `main`. Provider and environment are selectable via `workflow_dispatch`.

### Cleanup

Destroy is gated by an explicit confirmation step. Trigger via **Actions → Cleanup → Run workflow**, select the provider and environment, and type `destroy` in the confirmation field. GitHub Environment required reviewers apply as a second gate for `prod`.

---

## Design Decisions

### Provider-first directory structure

The layout is `provider/env/module` rather than the more common `env/provider/module`. This decision was made because:

- **Team alignment** — cloud providers are typically owned by separate platform sub-teams. Grouping by provider makes ownership clearer and simplifies access control at the directory level.
- **Targeted operations** — `cd aws && terragrunt run-all plan` targets all AWS infrastructure across all environments in one command, which is useful for provider-wide changes (e.g. upgrading the AWS provider version).
- **Tradeoff** — environment-level governance (e.g. restricting who can touch prod) is slightly harder to express since prod resources are split across `aws/prod` and `gcp/prod`. Required reviewers on GitHub Environments compensate for this.

### Separate backends per provider

AWS modules use **S3 + DynamoDB**; GCP modules use **GCS**. A single S3 backend for everything was considered but rejected because:

- Giving GCP pipelines an AWS key solely for state access adds unnecessary cross-cloud credential exposure.
- GCS state access uses GCP Workload Identity natively, improving the audit trail separation.
- `remote_state` is used for AWS (enables auto-creation of the S3 bucket and DynamoDB table on `init`). GCP uses `remote_state` too but the GCS bucket must be pre-created.

### OIDC over static credentials

All three GitHub Actions roles authenticate via OIDC/Workload Identity Federation — no `AWS_ACCESS_KEY_ID` or service account JSON files are stored in GitHub. The trust policies are scoped as tightly as possible:

- CI role: `pull_request` events only
- CD and cleanup roles: `ref:refs/heads/main` only

### Three separate IAM roles

`GitHubCIRole`, `GitHubCDRole`, and `GitHubTerraformCleanUp` are intentionally distinct even though the CD and cleanup policies are identical. Separate roles provide:

- A clean CloudTrail audit trail (which pipeline ran which operation)
- The ability to tighten permissions independently over time (e.g. add MFA condition to cleanup)
- Clear blast radius isolation if a role is compromised

### `_envcommon` pattern

Common module configuration (Terraform source, default inputs, `dependency` wiring) lives once in `_envcommon/`. Per-environment files only override what differs (CIDR ranges, node sizes, HA settings). This avoids duplication across 12 module directories while keeping each leaf file small and readable.

### IAM policy variables (`${aws:AccountId}`)

IAM policies use the `${aws:AccountId}` policy variable in resource ARNs rather than hardcoded account IDs. The same policy document is deployed to all three accounts unchanged, and AWS resolves the variable to the correct account at evaluation time.

### Reusable platform capabilities

The following components are strong candidates for standardisation as shared platform modules:

| Capability | Current state | Platform module candidate |
|---|---|---|
| OIDC provider + IAM roles | Manual setup per account | `platform/aws-oidc-bootstrap` module |
| S3 state backend + DynamoDB | Manual pre-creation | `platform/terraform-backend` module |
| GCS state bucket | Manual pre-creation | `platform/gcp-terraform-backend` module |
| GitHub Environment secrets | Manual configuration | Automated via GitHub Terraform provider |
| `_envcommon` defaults | Per-repo | Shared registry module with org defaults |

---

## Limitations & Future Improvements

### What would be done differently with more time

**EKS encryption at rest**
The EKS cluster does not configure a KMS key for Kubernetes Secrets encryption. A production-grade cluster should include an `encryption_config` block with a dedicated KMS key per environment.

**VPC Flow Logs**
The AWS networking module does not enable VPC Flow Logs. These are essential for network-level audit and incident response and should be enabled by default, shipping logs to CloudWatch or S3.

**Terraform tests**
No `.tftest.hcl` test files exist. The `terraform-code-generation:terraform-test` skill provides the patterns for unit-testing module outputs and mocking providers — adding a test suite per module would catch regressions before plan runs.

**Drift detection pipeline**
There is no scheduled pipeline to detect configuration drift between Terraform state and actual cloud resources. A nightly `terragrunt run-all plan` job that fails on non-empty diff would surface unmanaged changes.

**Cost estimation**
Infracost or OpenCost could be integrated as a CI step to post a cost breakdown comment on every PR before apply.

**Policy as code**
No Sentinel or OPA policies enforce guardrails (e.g. required tags, restricted regions, encryption mandates). These would prevent non-compliant resources from being planned at all.

**Module versioning**
Terraform module sources currently point to a local path (`modules/aws/networking`). For a multi-team organisation the modules should be published to a private registry with semantic versioning so consumers can pin and upgrade independently.

**GKE private endpoint**
In `dev`, `enable_private_endpoint = false` for easier access. A production hardening pass should enable it and provision bastion/IAP access instead.

**`master_ipv4_cidr_block` per environment**
The GKE master CIDR is currently the same default (`172.16.0.0/28`) across all environments. In a real deployment each environment should use a non-overlapping range, configured explicitly in `env.hcl` rather than relying on the module default.
