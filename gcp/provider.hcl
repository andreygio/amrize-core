locals {
  # Relative to gcp/ → e.g. "dev/networking"
  path_components  = split("/", path_relative_to_include())
  env_name         = local.path_components[0]
  module_name      = local.path_components[1]

  env_vars         = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  gcp_project_id   = local.env_vars.locals.gcp_project_id
  gcp_region       = local.env_vars.locals.gcp_region
  gcp_state_bucket = local.env_vars.locals.gcp_state_bucket
}

remote_state {
  backend = "gcs"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = local.gcp_state_bucket
    prefix = "${local.env_name}/${local.module_name}"
  }
}

inputs = {
  env            = local.env_name
  gcp_project_id = local.gcp_project_id
  gcp_region     = local.gcp_region
}
