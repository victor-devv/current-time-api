output "network_name" {
  description = "vpc network name"
  value = google_compute_network.vpc_network.name
}

output "subnet_name" {
  description = "subnet name"
  value = google_compute_subnetwork.subnet.name
}

output "vpc_self_link" {
  description = "The URI of the created VPC"
  value       = google_compute_network.vpc_network.self_link
}

output "subnet_self_link" {
  description = "The URI of the created subnet"
  value       = google_compute_subnetwork.subnet.self_link
}

output "nat_router_name" {
  description = "The URI of the created subnet"
  value       = google_compute_subnetwork.subnet.self_link
}
