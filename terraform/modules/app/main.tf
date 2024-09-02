resource "helm_release" "shortlet-current-time" {
  name      = "shortlet-current-time"
  chart     = "./modules/app/helm"
  namespace = "production"

  set {
    name  = "image.repository"
    value = var.image_repository
  }

  set {
    name  = "image.tag"
    value = var.image_tag
  }

  set {
    name  = "app.node_env"
    value = var.app_env
  }

  set {
    name  = "replicaCount"
    value = var.replica_count
  }

  timeout = 60
}
