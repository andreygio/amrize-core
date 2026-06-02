locals {
  namespace = "argocd"

  tags = {
    Environment = var.env
    ManagedBy   = "terragrunt"
  }
}
