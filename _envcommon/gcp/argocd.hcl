locals {
  root_path = "${dirname(find_in_parent_folders())}/"
}

terraform {
  source = "${local.root_path}modules/gcp/argocd"
}

dependency "kubernetes" {
  config_path = "${get_original_terragrunt_dir()}/../kubernetes"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
}

inputs = {
  cluster_name = dependency.kubernetes.outputs.cluster_name
}
