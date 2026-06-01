resource "google_service_account" "gke_nodes" {
  account_id   = "${var.env}-gke-nodes"
  display_name = "${var.env} GKE node service account"
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "gke_nodes_log_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_metric_writer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_artifact_reader" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_container_cluster" "this" {
  name     = local.cluster_name
  location = var.gcp_region
  project  = var.gcp_project_id

  remove_default_node_pool = true
  initial_node_count       = 1

  min_master_version = var.kubernetes_version

  network    = var.network_name
  subnetwork = var.subnetwork_name

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.env}-pods"
    services_secondary_range_name = "${var.env}-services"
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  resource_labels = local.labels
}

resource "google_container_node_pool" "this" {
  name     = "${local.cluster_name}-nodes"
  cluster  = google_container_cluster.this.name
  location = var.gcp_region
  project  = var.gcp_project_id

  initial_node_count = var.node_desired_count

  autoscaling {
    min_node_count = var.node_min_count
    max_node_count = var.node_max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.node_machine_type
    service_account = google_service_account.gke_nodes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = local.labels
  }
}
