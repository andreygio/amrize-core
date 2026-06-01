variable "availability_zones" {
  description = "List of AZ suffixes (e.g. [\"a\",\"b\",\"c\"])"
  type        = list(string)
  default     = ["a", "b", "c"]
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Provision NAT gateway(s)"
  type        = bool
  default     = true
}

variable "env" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.env)
    error_message = "env must be one of: dev, stage, prod."
  }
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
  default     = 3
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 3
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway (false = one per AZ)"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
