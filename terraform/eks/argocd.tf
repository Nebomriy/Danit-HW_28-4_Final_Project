resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"

    labels = merge(
      var.tags,
      {
        Name = "${var.name}-argocd"
      }
    )
  }

  depends_on = [
    aws_eks_node_group.danit
  ]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "7.7.3"

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  depends_on = [
    kubernetes_namespace.argocd,
    helm_release.nginx_ingress
  ]
}

resource "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd"
    namespace = kubernetes_namespace.argocd.metadata[0].name

    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "external-dns.alpha.kubernetes.io/hostname"      = "argocd.${local.domain_name}"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "argocd.${local.domain_name}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "argocd-server"

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.argocd
  ]
}
