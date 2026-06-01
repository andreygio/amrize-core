variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "enable_private_access" {
  description = "Enable private API endpoint access"
  type        = bool
  default     = true
}

variable "enable_public_access" {
  description = "Enable public API endpoint access"
  type        = bool
  default     = false
}

variable "env" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.env)
    error_message = "env must be one of: dev, stage, prod."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes (EKS) version"
  type        = string
  default     = "1.30"

  validation {
    condition     = can(regex("^\\d+\\.\\d+$", var.kubernetes_version))
    error_message = "kubernetes_version must be in the format \"X.Y\" (e.g. \"1.30\")."
  }
}

variable "node_desired_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_max_count" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "node_min_count" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where worker nodes will run"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}
