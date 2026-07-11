output "state_bucket_name" {
  description = "Name of the S3 state bucket. Use in backend-configs/*.s3.tfbackend."
  value       = aws_s3_bucket.state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the S3 state bucket."
  value       = aws_s3_bucket.state.arn
}

output "state_bucket_region" {
  description = "Region of the S3 state bucket."
  value       = aws_s3_bucket.state.region
}
