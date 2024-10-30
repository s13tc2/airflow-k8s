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

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# EKS Node Group Variables
variable "node_group_config" {
  description = "EKS node group configuration"
  type = object({
    desired_size    = number
    max_size        = number
    min_size        = number
    instance_types  = list(string)
    disk_size       = number
  })
  default = {
    desired_size    = 2
    max_size        = 3
    min_size        = 1
    instance_types  = ["t3.medium"]
    disk_size       = 20
  }
}

# Airflow Variables
variable "airflow_config" {
  description = "Airflow configuration settings"
  type = object({
    executor_type     = string
    worker_replicas   = number
    webserver_cpu     = string
    webserver_memory  = string
    scheduler_cpu     = string
    scheduler_memory  = string
    worker_cpu        = string
    worker_memory     = string
  })
  default = {
    executor_type     = "CeleryExecutor"
    worker_replicas   = 1
    webserver_cpu     = "500m"
    webserver_memory  = "1Gi"
    scheduler_cpu     = "500m"
    scheduler_memory  = "1Gi"
    worker_cpu        = "500m"
    worker_memory     = "1Gi"
  }
}

# Tags
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}