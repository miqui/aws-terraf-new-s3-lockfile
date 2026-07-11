##############################################################################
# Bootstrap stack — creates the S3 remote-state bucket
#
# This stack intentionally uses a LOCAL backend so it does not depend on the
# bucket it is about to create.  Apply it manually once per AWS account+region
# BEFORE initialising the app stack with the S3 backend.
#
# Usage:
#   cd stacks/bootstrap
#   terraform init
#   terraform plan  -var 'state_bucket_name=my-tf-state-123456789'
#   terraform apply -var 'state_bucket_name=my-tf-state-123456789'
##############################################################################

terraform {
  required_version = ">= 1.10.0"

  # Bootstrap uses local state intentionally — it bootstraps the remote bucket.
  # After first apply you may migrate, but it is not required.
  backend "local" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.70.0, < 6.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      ManagedBy   = "terraform"
      Stack       = "bootstrap"
    }
  }
}
