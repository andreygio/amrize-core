include "root" {
  path = find_in_parent_folders()
}

include "provider" {
  path           = find_in_parent_folders("provider.hcl")
  expose         = true
  merge_strategy = "deep"
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders())}/_envcommon/gcp/kubernetes.hcl"
  expose         = true
  merge_strategy = "deep"
}

inputs = {
  node_machine_type       = "e2-standard-8"
  node_min_count          = 3
  node_max_count          = 10
  node_desired_count      = 3
  enable_private_nodes    = true
  enable_private_endpoint = true
}
