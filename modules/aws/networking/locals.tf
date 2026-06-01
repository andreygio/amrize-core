locals {
  azs = [for az in var.availability_zones : "${var.aws_region}${az}"]

  public_subnet_cidrs = [
    for i in range(var.public_subnet_count) :
    cidrsubnet(var.vpc_cidr, 4, i)
  ]

  private_subnet_cidrs = [
    for i in range(var.private_subnet_count) :
    cidrsubnet(var.vpc_cidr, 4, i + var.public_subnet_count)
  ]

  tags = {
    Environment = var.env
    ManagedBy   = "terragrunt"
  }
}
