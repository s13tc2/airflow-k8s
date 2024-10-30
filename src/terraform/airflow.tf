# airflow.tf
resource "helm_release" "airflow" {
  name       = "airflow"
  repository = "https://airflow.apache.org"
  chart      = "airflow"
  namespace  = "airflow"
  create_namespace = true

  set {
    name  = "executor"
    value = "CeleryExecutor"
  }

  set {
    name  = "webserver.service.type"
    value = "LoadBalancer"
  }

  depends_on = [
    aws_eks_cluster.cluster,
    aws_eks_node_group.node_group
  ]
}