variable "aws_region" {
  description = "AWS region where the state bucket will be created."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = <<-EOT
    Name of the S3 bucket that will hold Terraform remote state.
    Must be globally unique.  Use a pattern like:
      my-project-tf-state-<account_id>
    Do NOT hardcode an account-specific value in version control.
  EOT
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9\\-]{2,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must be 4-63 lowercase alphanumeric characters or hyphens, starting and ending with a letter or number."
  }
}

variable "project" {
  description = "Project tag applied to all resources."
  type        = string
  default     = "aws-terraf-new-s3-lockfile"
}
