# aws-terraf-new-s3-lockfile

Team-managed Terraform IaC repo — Node.js 22 Lambda exposed via API Gateway HTTP API on AWS.

## Architecture

```
API Gateway HTTP API
  └── GET /health  →  Lambda (Node.js 22, arm64)
                         └── CloudWatch Logs log group
```

State is stored in S3 with **native S3 lock files** (`use_lockfile = true`).
No DynamoDB is used for locking.

---

## Repository layout

```
.
├── stacks/
│   ├── bootstrap/          # One-time: creates S3 state bucket (apply manually first)
│   └── app/                # Per-environment application stack
├── lambda/
│   ├── src/index.mjs       # Lambda handler (Node.js 22 ESM)
│   ├── test/index.test.mjs # Unit tests (Node test runner)
│   └── package.json
├── backend-configs/
│   └── dev.s3.tfbackend.example   # Template — copy & fill for your AWS account
└── .github/workflows/
    └── ci.yml              # Terraform fmt/validate + npm test
```

---

## Prerequisites

| Tool       | Minimum version |
|------------|-----------------|
| Terraform  | 1.10+           |
| Node.js    | 22.x            |
| AWS CLI    | v2 (for apply)  |
| AWS account credentials | Exported in environment or via profile |

---

## First-time setup

### 1. Bootstrap the remote state bucket (once per AWS account/region)

The `stacks/bootstrap` stack creates the S3 bucket that holds all remote Terraform state.
**You must apply it locally before initialising the app stack.**

```bash
cd stacks/bootstrap

# Review variables — override via -var or a .tfvars file
terraform init       # uses local backend for bootstrap itself
terraform plan -var 'state_bucket_name=my-tf-state-ACCOUNT'
terraform apply -var 'state_bucket_name=my-tf-state-ACCOUNT'
```

> ⚠️  The bootstrap stack intentionally uses a **local backend** so it does not depend on the
> bucket it is creating.  After the first apply, you may optionally migrate it to the remote
> bucket manually.

Record the bucket name and key prefix from the outputs.

### 2. Create a backend config for your environment

```bash
cp backend-configs/dev.s3.tfbackend.example backend-configs/dev.s3.tfbackend
# Edit dev.s3.tfbackend — fill in the bucket name, state key, and region.
# Keep use_lockfile = true; no DynamoDB setting is used.
```

`*.s3.tfbackend` files are git-ignored to prevent accidental account-info leaks.

### Team and CI backend permissions

Grant the identity that runs Terraform only the state-bucket permissions it needs:

- `s3:ListBucket` on the bucket, restricted to the relevant state prefix.
- `s3:GetObject` and `s3:PutObject` on the state object.
- `s3:GetObject`, `s3:PutObject`, and `s3:DeleteObject` on the adjacent
  `<state-key>.tflock` object used by native S3 locking.

Do not grant `s3:DeleteObject` on the state object. Scope each environment's IAM role
or CI identity to its own prefix (for example, `app/dev/`), and use separate GitHub
Actions environments/roles for staging and production deployment workflows when those
are added.

### 3. Initialise the app stack

```bash
cd stacks/app
terraform init -backend-config=../../backend-configs/dev.s3.tfbackend
```

The backend uses `use_lockfile = true` (requires Terraform ≥ 1.10 and `s3:GetObject`/
`s3:PutObject`/`s3:DeleteObject` on the lock key).

### 4. Plan and apply (dev example)

```bash
cp ../../backend-configs/dev.tfvars.example ../../backend-configs/dev.tfvars
# Edit dev.tfvars to override the non-secret defaults if needed.
terraform plan  -var-file=../../backend-configs/dev.tfvars
terraform apply -var-file=../../backend-configs/dev.tfvars
```

`*.tfvars` files with real environment values are git-ignored. Do not put secrets in
Terraform variable files or state; use a managed secret reference when application
secrets are introduced.

---

## Lambda development

```bash
cd lambda
npm ci
npm test
```

---

## CI

GitHub Actions runs on every push/PR:

- `terraform fmt -check` for each stack
- `terraform init -backend=false && terraform validate` for each stack
- `npm ci && npm test` for the Lambda

No AWS credentials are required for CI validation.

---

## Inputs (stacks/app)

| Variable              | Default     | Description                              |
|-----------------------|-------------|------------------------------------------|
| `aws_region`          | `us-east-1` | AWS region                               |
| `environment`         | `dev`        | Environment name (used in resource names/tags) |
| `project`             | `aws-terraf-new-s3-lockfile` | Project name (used in tags) |
| `lambda_memory_mb`    | `256`        | Lambda memory in MB                      |
| `lambda_timeout_sec`  | `10`         | Lambda timeout in seconds                |
| `log_retention_days`  | `14`         | CloudWatch log retention in days         |

## Outputs (stacks/app)

| Output            | Description                         |
|-------------------|-------------------------------------|
| `api_endpoint`    | Base URL of the HTTP API            |
| `health_url`      | Full URL for GET /health            |
| `lambda_arn`      | Lambda function ARN                 |
| `lambda_role_arn` | IAM role ARN of the Lambda          |
