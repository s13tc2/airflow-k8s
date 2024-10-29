# random.tf

# Random string for bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Local variable for bucket name construction
locals {
  airflow_bucket_name = "${var.company_prefix}-${var.bucket_prefix}-${var.environment}-${random_string.bucket_suffix.result}"
}