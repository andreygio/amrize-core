locals {
  network_name    = "${var.env}-vpc"
  subnetwork_name = "${var.env}-subnet"

  labels = {
    environment = var.env
    managed_by  = "terragrunt"
  }
}
