resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
  }
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}

resource "helm_release" "app" {
  name      = "shortlet-current-time"
  chart     = "./modules/app/helm"
  namespace = "production"

  set {
    name  = "nameOverride"
    value = var.app_name
  }

  set {
    name  = "fullnameOverride"
    value = var.app_name
  }

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

resource "kubernetes_ingress" "prod_ingress" {
  metadata {
    name      = "nodejs-ingress"
    namespace = kubernetes_namespace.production.metadata[0].name
  }

  spec {
    backend {
      service_name = var.app_name
      service_port = 80
    }

    rule {
      http {
        path {
          path = "/"
          backend {
            service_name = var.app_name
            service_port = 80
          }
        }
      }
    }
  }
}
