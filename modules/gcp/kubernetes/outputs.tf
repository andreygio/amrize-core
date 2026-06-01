output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate"
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_endpoint" {
  description = "GKE master endpoint"
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.this.name
}

output "cluster_version" {
  description = "Running master version"
  value       = google_container_cluster.this.master_version
}

output "node_service_account_email" {
  description = "Service account email used by GKE nodes"
  value       = google_service_account.gke_nodes.email
}
