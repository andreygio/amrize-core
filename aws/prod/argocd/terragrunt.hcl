include "root" {
  path = find_in_parent_folders()
}

include "provider" {
  path           = find_in_parent_folders("provider.hcl")
  expose         = true
  merge_strategy = "deep"
}

include "envcommon" {
  path           = "${dirname(find_in_parent_folders())}/_envcommon/aws/argocd.hcl"
  expose         = true
  merge_strategy = "deep"
}

inputs = {
  argocd_hostname = "argocd.prod.example.com"
}
