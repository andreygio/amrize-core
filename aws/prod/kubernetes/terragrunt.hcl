include "root" {
  path = find_in_parent_folders()
}

include "provider" {
  path           = find_in_parent_folders("provider.hcl")
  expose         = true
  merge_strategy = "deep"
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders())}/_envcommon/aws/kubernetes.hcl"
  expose         = true
  merge_strategy = "deep"
}

inputs = {
  node_instance_type    = "m5.xlarge"
  node_min_count        = 3
  node_max_count        = 10
  node_desired_count    = 3
  enable_private_access = true
  enable_public_access  = false
}
