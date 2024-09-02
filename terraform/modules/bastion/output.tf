# output "bastion_public_ip_address" {
#   description = "The public IP of the bastion node"
#   value       = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
# }

output "bastion_ip_address" {
  description = "The private IP of the bastion node"
  value       = google_compute_instance.bastion.network_interface.0.network_ip
}

output "bastion_self_link" {
  description = "The self link of the bastion node"
  value       = google_compute_instance.bastion.self_link
}

output "bastion_instance_id" {
  description = "The server-assigned unique identifier of this instance."
  value       = google_compute_instance.bastion.self_link
}

output "bastion_id" {
  description = "The identifier of this instance."
  value       = google_compute_instance.bastion.id
}
