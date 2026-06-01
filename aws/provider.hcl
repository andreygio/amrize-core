locals {
  # Relative to aws/ → e.g. "dev/networking"
  path_components = split("/", path_relative_to_include())
  env_name        = local.path_components[0]
  module_name     = local.path_components[1]

  env_vars       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  aws_region     = local.env_vars.locals.aws_region
  aws_account_id = local.env_vars.locals.aws_account_id
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = "terraform-state-${local.aws_account_id}-${local.aws_region}-an"
    key            = "${local.env_name}/${local.module_name}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "terraform-locks-${local.env_name}"
  }
}

inputs = {
  env            = local.env_name
  aws_region     = local.aws_region
  aws_account_id = local.aws_account_id
}
