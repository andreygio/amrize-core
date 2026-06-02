resource "kubernetes_namespace" "argocd" {
  metadata {
    name   = local.namespace
    labels = local.labels
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = local.namespace
  version    = var.chart_version

  values = [
    yamlencode({
      global = {
        domain = var.argocd_hostname
      }

      configs = {
        params = {
          "server.insecure" = true
        }
      }

      server = {
        ingress = {
          enabled          = true
          ingressClassName = "gce"
          annotations = {
            "kubernetes.io/ingress.global-static-ip-name" = "${var.env}-argocd-ip"
            "networking.gke.io/managed-certificates"      = "${var.env}-argocd-cert"
          }
          tls = true
        }
      }

      repoServer = {
        resources = {
          requests = { cpu = "100m", memory = "256Mi" }
          limits   = { cpu = "500m", memory = "512Mi" }
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_manifest" "appset" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "ApplicationSet"
    metadata = {
      name      = "platform-apps"
      namespace = local.namespace
    }
    spec = {
      generators = [
        {
          git = {
            repoURL  = var.gitops_repo_url
            revision = "main"
            files    = [{ path = "${var.env}/*.yaml" }]
          }
        }
      ]
      template = {
        metadata = {
          name = "{{appName}}"
        }
        spec = {
          project = "default"
          source = {
            repoURL        = "{{repoURL}}"
            targetRevision = "{{targetRevision}}"
            path           = "{{chartPath}}"
            helm = {
              valueFiles = ["{{valuesFile}}"]
            }
          }
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "{{namespace}}"
          }
          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = ["CreateNamespace=true"]
            retry = {
              limit = 3
              backoff = {
                duration    = "10s"
                factor      = 2
                maxDuration = "3m"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.argocd]
}
