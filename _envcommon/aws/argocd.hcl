locals {
  root_path = "${dirname(find_in_parent_folders())}/"
}

terraform {
  source = "${local.root_path}modules/aws/argocd"
}

dependency "kubernetes" {
  config_path = "${get_original_terragrunt_dir()}/../kubernetes"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
}

dependency "alb_controller" {
  config_path = "${get_original_terragrunt_dir()}/../alb-controller"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    release_status = "deployed"
  }
}

inputs = {
  cluster_name = dependency.kubernetes.outputs.cluster_name
}
