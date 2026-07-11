##############################################################################
# S3 state bucket — encrypted, versioned, private, TLS-only
# Native S3 lock files (use_lockfile = true) — NO DynamoDB
##############################################################################

resource "aws_s3_bucket" "state" {
  bucket        = var.state_bucket_name
  force_destroy = false # protect state from accidental deletion

  lifecycle {
    prevent_destroy = true
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket-owner enforced ownership (disables ACLs)
resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Enable versioning for point-in-time recovery
resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption (SSE-S3; upgrade to SSE-KMS if your policy requires it)
resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enforce TLS-only access
resource "aws_s3_bucket_policy" "state_tls_only" {
  bucket = aws_s3_bucket.state.id

  # Wait for ownership controls and public-access-block to be set first
  depends_on = [
    aws_s3_bucket_public_access_block.state,
    aws_s3_bucket_ownership_controls.state,
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyNonTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.state.arn,
          "${aws_s3_bucket.state.arn}/*",
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}
