locals {
  root_path = "${dirname(find_in_parent_folders())}/"
}

terraform {
  source = "${local.root_path}modules/gcp/networking"
}

inputs = {
  # Defaults overridable per environment
  subnet_cidr          = "10.10.0.0/20"
  pod_cidr             = "10.20.0.0/16"
  services_cidr        = "10.30.0.0/20"
  enable_private_access = true
}
