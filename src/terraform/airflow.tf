# airflow.tf
resource "helm_release" "airflow" {
  name             = "airflow"
  repository       = "https://airflow.apache.org"
  chart            = "airflow"
  namespace        = "airflow"
  create_namespace = true

  set {
    name  = "executor"
    value = "CeleryExecutor"
  }

  set {
    name  = "webserver.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "postgresql.enabled"
    value = "true"
  }

  values = [
    <<-EOT
    serviceAccount:
      create: true
      annotations:
        eks.amazonaws.com/role-arn: ${aws_iam_role.airflow_role.arn}
    
    env:
    - name: AIRFLOW__LOGGING__REMOTE_LOGGING
      value: "True"
    - name: AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER
      value: "s3://${var.airflow_bucket_name}/logs"
    - name: AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID
      value: "aws_default"
    
    extraEnv:
    - name: AWS_DEFAULT_REGION
      value: ${var.aws_region}
    EOT
  ]

  depends_on = [
    aws_eks_cluster.cluster,
    aws_eks_node_group.node_group,
    aws_iam_role.airflow_role
  ]
}