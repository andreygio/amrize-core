locals {
  cluster_name = "${var.env}-eks"

  tags = {
    Environment = var.env
    ManagedBy   = "terragrunt"
  }
}
