# airflow.tf
resource "kubernetes_namespace" "airflow" {
  metadata {
    name = "airflow"
  }

  depends_on = [
    aws_eks_cluster.cluster,
    aws_eks_node_group.node_group
  ]
}

resource "helm_release" "airflow" {
  name             = "airflow"
  repository       = "https://airflow.apache.org"
  chart            = "airflow"
  namespace        = kubernetes_namespace.airflow.metadata[0].name
  create_namespace = false
  timeout          = 1200 # 20 minutes
  wait             = true
  wait_for_jobs    = true

  values = [
    <<-EOT
    executor: CeleryExecutor

    # Simplified configuration for initial deployment
    webserver:
      service:
        type: LoadBalancer
      resources:
        requests:
          cpu: "500m"
          memory: "1Gi"
        limits:
          cpu: "1000m"
          memory: "2Gi"

    scheduler:
      resources:
        requests:
          cpu: "500m"
          memory: "1Gi"
        limits:
          cpu: "1000m"
          memory: "2Gi"

    workers:
      replicas: 1
      resources:
        requests:
          cpu: "500m"
          memory: "1Gi"
        limits:
          cpu: "1000m"
          memory: "2Gi"

    EOT
  ]

  depends_on = [
    kubernetes_namespace.airflow,
    aws_eks_cluster.cluster,
    aws_eks_node_group.node_group
  ]
}
