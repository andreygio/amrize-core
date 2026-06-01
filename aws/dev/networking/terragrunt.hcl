include "root" {
  path = find_in_parent_folders()
}

include "provider" {
  path           = find_in_parent_folders("provider.hcl")
  expose         = true
  merge_strategy = "deep"
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders())}/_envcommon/aws/networking.hcl"
  expose         = true
  merge_strategy = "deep"
}

inputs = {
  vpc_cidr           = "10.0.0.0/16"
  single_nat_gateway = true
}
