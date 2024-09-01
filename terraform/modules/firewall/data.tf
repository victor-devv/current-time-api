locals {
  // ID of the cluster
  # cluster_id = google_container_cluster.primary.id

  // location
  # location = var.regional ? var.region : var.zones[0]
  region   = var.regional ? var.region : join("-", slice(split("-", var.zones[0]), 0, 2))

  network_project_id         = var.network_project_id != "" ? var.network_project_id : var.project_id
  cluster_network_tag        = "gke-${var.cluster_name}"
  cluster_endpoint_for_nodes = var.master_ipv4_cidr_block
  cluster_subnet_cidr        = var.add_cluster_firewall_rules ? data.google_compute_subnetwork.gke_subnetwork[0].ip_cidr_range : null

  cluster_alias_ranges_cidr = var.add_cluster_firewall_rules ? { for range in toset(data.google_compute_subnetwork.gke_subnetwork[0].secondary_ip_range) : range.range_name => range.ip_cidr_range } : {}

  pod_all_ip_ranges = var.add_cluster_firewall_rules ? [local.cluster_alias_ranges_cidr[var.pods_range_name]] : []
}

data "google_compute_subnetwork" "gke_subnetwork" {
  count   = var.add_cluster_firewall_rules ? 1 : 0
  name    = var.subnet_name
  region  = local.region
  project = local.network_project_id
}
