variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod). Used in resource names and tags."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "project" {
  description = "Project name. Used in resource names and tags."
  type        = string
  default     = "aws-terraf-new-s3-lockfile"
}

variable "lambda_memory_mb" {
  description = "Lambda function memory size in MB."
  type        = number
  default     = 256

  validation {
    condition     = var.lambda_memory_mb >= 128 && var.lambda_memory_mb <= 10240
    error_message = "lambda_memory_mb must be between 128 and 10240."
  }
}

variable "lambda_timeout_sec" {
  description = "Lambda function timeout in seconds."
  type        = number
  default     = 10

  validation {
    condition     = var.lambda_timeout_sec >= 1 && var.lambda_timeout_sec <= 900
    error_message = "lambda_timeout_sec must be between 1 and 900."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days."
  type        = number
  default     = 14

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "log_retention_days must be a value accepted by CloudWatch Logs."
  }
}
