# variables.tf
variable "aws_region" {
  default = "us-west-2"
}

variable "cluster_name" {
  default = "airflow-cluster"
}

variable "environment" {
  default = "production"
}