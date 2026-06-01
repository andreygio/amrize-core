variable "enable_private_endpoint" {
  description = "Disable public access to the master endpoint"
  type        = bool
  default     = false
}

variable "enable_private_nodes" {
  description = "Give nodes private IP addresses only"
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

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
}

variable "kubernetes_version" {
  description = "GKE master version (e.g. 1.30)"
  type        = string
  default     = "1.30"

  validation {
    condition     = can(regex("^\\d+\\.\\d+$", var.kubernetes_version))
    error_message = "kubernetes_version must be in the format \"X.Y\" (e.g. \"1.30\")."
  }
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the GKE master network (/28 required)"
  type        = string
  default     = "172.16.0.0/28"

  validation {
    condition     = can(cidrnetmask(var.master_ipv4_cidr_block))
    error_message = "master_ipv4_cidr_block must be a valid CIDR (e.g. \"172.16.0.0/28\")."
  }
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "node_desired_count" {
  description = "Initial nodes per zone"
  type        = number
  default     = 2
}

variable "node_machine_type" {
  description = "Machine type for worker nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "node_max_count" {
  description = "Maximum nodes per zone"
  type        = number
  default     = 3
}

variable "node_min_count" {
  description = "Minimum nodes per zone"
  type        = number
  default     = 1
}

variable "subnetwork_name" {
  description = "Subnetwork name"
  type        = string
}
