locals {
  root_path = "${dirname(find_in_parent_folders())}/"
}

terraform {
  source = "${local.root_path}modules/aws/kubernetes"
}

dependency "networking" {
  config_path = "../networking"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id             = "vpc-mock"
    private_subnet_ids = ["subnet-mock-a", "subnet-mock-b", "subnet-mock-c"]
  }
}

inputs = {
  vpc_id             = dependency.networking.outputs.vpc_id
  private_subnet_ids = dependency.networking.outputs.private_subnet_ids

  # Defaults overridable per environment
  kubernetes_version    = "1.30"
  node_instance_type    = "t3.medium"
  node_min_count        = 1
  node_max_count        = 3
  node_desired_count    = 2
  enable_private_access = true
  enable_public_access  = false
}
