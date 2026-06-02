provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

data "google_client_config" "this" {}

data "google_container_cluster" "this" {
  name     = var.cluster_name
  location = var.gcp_region
  project  = var.gcp_project_id
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.this.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.this.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.this.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.this.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.this.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.this.access_token
  }
}
