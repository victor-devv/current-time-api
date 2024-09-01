resource "google_compute_network" "vpc_network" {
  name = var.network_name
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = var.cidr_block
  region        = var.region
  private_ip_google_access = true
  secondary_ip_range {
    range_name    = var.ip_range_pods
  }
  secondary_ip_range {
    range_name    = var.ip_range_services
  }
  depends_on = [
    google_compute_network.vpc_network,
  ]
}

resource "google_compute_address" "global_ip" {
  name         = "${var.network_name}-global-ip"
  address_type = "EXTERNAL"
  region       = var.region
}

resource "null_resource" "wait_for_ip" {
  depends_on = [google_compute_address.global_ip]
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "google_compute_router" "nat_router" {
  project = var.network_project_id
  name    = var.nat_router_name
  network = google_compute_network.vpc_network.name
  region  = var.region
}

resource "google_compute_router_nat" "nat_gateway" {
  name                               = var.nat_gateway_name
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.global_ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  depends_on = [
    google_compute_address.global_ip,
    google_compute_router.nat_router,
    null_resource.wait_for_ip,
  ]
}
