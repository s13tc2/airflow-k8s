# providers.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    # Don't specify these values here - they will be passed via CLI
    # bucket = "your-terraform-state-bucket"
    # key    = "environment/terraform.tfstate"
    # region = "us-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "random" {}

# Add to providers.tf
provider "aws" {
  alias  = "monitoring"
  region = var.aws_region
}

# Add new file: monitoring.tf
resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 30
}

resource "aws_cloudwatch_metric_alarm" "node_cpu" {
  alarm_name          = "${var.cluster_name}-node-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "cpu_utilization_over_pod_limit"
  namespace          = "AWS/EKS"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors EKS node CPU utilization"
  alarm_actions      = [aws_sns_topic.eks_alerts.arn]
  
  dimensions = {
    ClusterName = aws_eks_cluster.cluster.name
  }
}