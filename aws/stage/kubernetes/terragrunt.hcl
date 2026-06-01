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
  node_instance_type = "t3.large"
  node_min_count     = 1
  node_max_count     = 4
  node_desired_count = 2
}
