output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.this.name
}

output "network_self_link" {
  description = "VPC network self link"
  value       = google_compute_network.this.self_link
}

output "pod_range_name" {
  description = "Secondary range name for pods"
  value       = "${var.env}-pods"
}

output "services_range_name" {
  description = "Secondary range name for services"
  value       = "${var.env}-services"
}

output "subnetwork_name" {
  description = "Subnetwork name"
  value       = google_compute_subnetwork.this.name
}

output "subnetwork_self_link" {
  description = "Subnetwork self link"
  value       = google_compute_subnetwork.this.self_link
}
