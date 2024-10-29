# s3.tf

# S3 bucket for Airflow logs
resource "aws_s3_bucket" "airflow_logs" {
  bucket = local.airflow_bucket_name  # Using the local variable instead of var.airflow_bucket_name

  tags = {
    Name        = local.airflow_bucket_name
    Environment = var.environment
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "airflow_logs" {
  bucket = aws_s3_bucket.airflow_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "airflow_logs" {
  bucket = aws_s3_bucket.airflow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable bucket logging
resource "aws_s3_bucket_logging" "airflow_logs" {
  bucket = aws_s3_bucket.airflow_logs.id

  target_bucket = aws_s3_bucket.airflow_logs.id
  target_prefix = "log/"
}

# Block public access
resource "aws_s3_bucket_public_access_block" "airflow_logs" {
  bucket = aws_s3_bucket.airflow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket lifecycle rule
resource "aws_s3_bucket_lifecycle_configuration" "airflow_logs" {
  bucket = aws_s3_bucket.airflow_logs.id

  rule {
    id     = "log_lifecycle"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

# Bucket Policy
resource "aws_s3_bucket_policy" "airflow_logs" {
  bucket = aws_s3_bucket.airflow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceHTTPS"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.airflow_logs.arn,
          "${aws_s3_bucket.airflow_logs.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}