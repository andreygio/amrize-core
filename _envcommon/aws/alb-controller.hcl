locals {
  root_path = "${dirname(find_in_parent_folders())}/"
}

terraform {
  source = "${local.root_path}modules/aws/alb-controller"
}

dependency "networking" {
  config_path = "${get_original_terragrunt_dir()}/../networking"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id = "vpc-mock"
  }
}

dependency "kubernetes" {
  config_path = "${get_original_terragrunt_dir()}/../kubernetes"

  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    cluster_name      = "mock-cluster"
    cluster_endpoint  = "https://mock-endpoint"
    cluster_ca_data   = "bW9jaw=="
    oidc_issuer_url   = "https://oidc.eks.us-east-1.amazonaws.com/id/mock"
    oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/mock"
  }
}

inputs = {
  vpc_id            = dependency.networking.outputs.vpc_id
  cluster_name      = dependency.kubernetes.outputs.cluster_name
  cluster_endpoint  = dependency.kubernetes.outputs.cluster_endpoint
  cluster_ca_data   = dependency.kubernetes.outputs.cluster_ca_data
  oidc_issuer_url   = dependency.kubernetes.outputs.oidc_issuer_url
  oidc_provider_arn = dependency.kubernetes.outputs.oidc_provider_arn
}
