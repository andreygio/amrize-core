include "root" {
  path = find_in_parent_folders()
}

include "provider" {
  path           = find_in_parent_folders("provider.hcl")
  expose         = true
  merge_strategy = "deep"
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders())}/_envcommon/gcp/networking.hcl"
  expose         = true
  merge_strategy = "deep"
}

inputs = {
  subnet_cidr   = "10.0.0.0/20"
  pod_cidr      = "10.4.0.0/16"
  services_cidr = "10.8.0.0/20"
}
