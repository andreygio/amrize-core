resource "google_compute_network" "this" {
  name                    = local.network_name
  auto_create_subnetworks = false
  project                 = var.gcp_project_id
}

resource "google_compute_subnetwork" "this" {
  name          = local.subnetwork_name
  network       = google_compute_network.this.self_link
  region        = var.gcp_region
  ip_cidr_range = var.subnet_cidr
  project       = var.gcp_project_id

  private_ip_google_access = var.enable_private_access

  secondary_ip_range {
    range_name    = "${var.env}-pods"
    ip_cidr_range = var.pod_cidr
  }

  secondary_ip_range {
    range_name    = "${var.env}-services"
    ip_cidr_range = var.services_cidr
  }
}

resource "google_compute_router" "this" {
  name    = "${var.env}-router"
  network = google_compute_network.this.self_link
  region  = var.gcp_region
  project = var.gcp_project_id
}

resource "google_compute_router_nat" "this" {
  name                               = "${var.env}-nat"
  router                             = google_compute_router.this.name
  region                             = var.gcp_region
  project                            = var.gcp_project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
