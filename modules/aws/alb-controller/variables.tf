variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "chart_version" {
  description = "Helm chart version for the AWS Load Balancer Controller"
  type        = string
  default     = "1.8.1"
}

variable "cluster_ca_data" {
  description = "Base64-encoded cluster CA certificate"
  type        = string
  sensitive   = true
}

variable "cluster_endpoint" {
  description = "EKS API server endpoint"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "EKS cluster name"
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

variable "oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster runs"
  type        = string
}
