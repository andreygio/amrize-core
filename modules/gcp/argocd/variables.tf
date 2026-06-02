variable "argocd_hostname" {
  description = "Hostname for the ArgoCD ingress (e.g. argocd.dev.example.com)"
  type        = string
}

variable "chart_version" {
  description = "Helm chart version for ArgoCD"
  type        = string
  default     = "7.4.4"
}

variable "cluster_name" {
  description = "GKE cluster name — used to fetch endpoint and CA via data source"
  type        = string
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

variable "gitops_repo_url" {
  description = "URL of the GitOps config repository containing ApplicationSet parameter files"
  type        = string
  default     = "https://github.com/andreygio/amrize-argocd-deployments"
}
