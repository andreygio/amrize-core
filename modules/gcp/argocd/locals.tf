locals {
  namespace = "argocd"

  labels = {
    environment = var.env
    managed-by  = "terragrunt"
  }
}
