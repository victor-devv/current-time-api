/******************************************
  Create Container Cluster
 *****************************************/
resource "google_container_cluster" "primary" {
  provider = google-beta

  name            = var.cluster_name
  description     = var.description
  project         = var.project_id
  resource_labels = var.cluster_resource_labels

  location          = local.location
  node_locations    = local.node_locations
  cluster_ipv4_cidr = var.cluster_ipv4_cidr
  network           = "projects/${local.network_project_id}/global/networks/${var.network_name}"

  subnetwork = "projects/${local.network_project_id}/regions/${local.region}/subnetworks/${var.subnet_name}"
}
