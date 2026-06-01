locals {
  cluster_name = "${var.env}-gke"

  labels = {
    environment = var.env
    managed_by  = "terragrunt"
  }
}
