resource "kubernetes_namespace" "app" {
  metadata {
    name = var.app_namespace
  }
}

resource "helm_release" "app" {
  name      = var.app_name
  chart     = "./modules/app/helm"
  namespace = var.app_namespace

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

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = kubernetes_namespace.app.metadata[0].name
    namespace = kubernetes_namespace.app.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer"              = "letsencrypt"
      "kubernetes.io/ingress.class"                 = "nginx"
      "nginx.ingress.kubernetes.io/limit-rps"       = "4"
      "nginx.ingress.kubernetes.io/rewrite-target"  = "/api/v1$uri"
      "nginx.ingress.kubernetes.io/ssl-redirect"    = "false"
      "nginx.ingress.kubernetes.io/use-regex"       = "true"
    }
  }

  spec {
    default_backend {
      service {
        name = var.app_name
        port {
          number = 80
        }
      }
    }

    rule {
      http {
        path {
          path = "/"
          backend {
            service {
              name = var.app_name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
