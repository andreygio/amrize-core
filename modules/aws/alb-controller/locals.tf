locals {
  service_account_name = "aws-load-balancer-controller"
  namespace            = "kube-system"
  oidc_issuer          = replace(var.oidc_issuer_url, "https://", "")

  tags = {
    Environment = var.env
    ManagedBy   = "terragrunt"
  }
}
