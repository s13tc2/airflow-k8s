# variables.tf
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "airflow-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "airflow_bucket_name" {
  description = "Name of the S3 bucket for Airflow logs and DAGs"
  type        = string
  default     = "airflow-bucket-name"
}

variable "node_group_desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
  default     = 3
}

variable "node_group_min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
  default     = 1
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "airflow-logs"
}

variable "company_prefix" {
  description = "Company prefix for resources"
  type        = string
  default     = "company"  # Change this to your company name/prefix
}

# Add to variables.tf
variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Environment = "production"
    ManagedBy  = "terraform"
    Owner      = "platform-team"
    Project    = "airflow"
  }
}

# Update all resource tags to include the common tags
locals {
  common_tags = merge(
    var.tags,
    {
      ClusterName = var.cluster_name
    }
  )
}