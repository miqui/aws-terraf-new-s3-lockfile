##############################################################################
# Application stack — Lambda + API Gateway HTTP API
#
# Remote state backend.  Initialise with:
#   terraform init -backend-config=../../backend-configs/dev.s3.tfbackend
#
# IMPORTANT: Run the bootstrap stack and apply it first to create the S3
# state bucket before running `terraform init` here.
#
# use_lockfile = true enables native S3 lock files (Terraform >= 1.10).
# No DynamoDB table is required.
##############################################################################

terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    # Values supplied via -backend-config flag or a *.s3.tfbackend file.
    # Do NOT hardcode bucket name or account-specific values here.
    # Required keys:
    #   bucket         = "your-tf-state-bucket-name"
    #   key            = "app/dev/terraform.tfstate"
    #   region         = "us-east-1"
    #   encrypt        = true
    #   use_lockfile   = true          # native S3 lock — NO DynamoDB needed
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.70.0, < 6.0.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.5.0, < 3.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
      Stack       = "app"
    }
  }
}
