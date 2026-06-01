locals {
  root_path = "${dirname(find_in_parent_folders())}/"
}

terraform {
  source = "${local.root_path}modules/gcp/kubernetes"
}

dependency "networking" {
  config_path = "../networking"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    network_name    = "mock-network"
    subnetwork_name = "mock-subnetwork"
  }
}

inputs = {
  network_name    = dependency.networking.outputs.network_name
  subnetwork_name = dependency.networking.outputs.subnetwork_name

  # Defaults overridable per environment
  kubernetes_version    = "1.30"
  node_machine_type     = "e2-standard-2"
  node_min_count        = 1
  node_max_count        = 3
  node_desired_count    = 2
  enable_private_nodes  = true
  enable_private_endpoint = false
}
