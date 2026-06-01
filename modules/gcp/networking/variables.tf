variable "enable_private_access" {
  description = "Enable Google private access on the subnet"
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

variable "pod_cidr" {
  description = "Secondary range CIDR for pods"
  type        = string
}

variable "services_cidr" {
  description = "Secondary range CIDR for services"
  type        = string
}

variable "subnet_cidr" {
  description = "Primary subnet CIDR"
  type        = string
}
