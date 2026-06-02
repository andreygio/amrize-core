output "namespace" {
  description = "Kubernetes namespace where ArgoCD is installed"
  value       = local.namespace
}

output "release_name" {
  description = "Helm release name"
  value       = helm_release.argocd.name
}

output "release_status" {
  description = "Helm release status"
  value       = helm_release.argocd.status
}
