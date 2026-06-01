locals {
  root_path = "${dirname(find_in_parent_folders())}/"
}

terraform {
  source = "${local.root_path}modules/aws/networking"
}

inputs = {
  # Defaults overridable per environment
  availability_zones    = ["a", "b", "c"]
  public_subnet_count   = 3
  private_subnet_count  = 3
  enable_nat_gateway    = true
  single_nat_gateway    = false
}
