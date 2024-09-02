output "name" {
  description = "Cluster name"
  value       = module.cluster.name
}

output "kubernetes_endpoint" {
  sensitive = true
  value     = module.cluster.endpoint
}

output "ca_certificate" {
  value     = module.cluster.ca_certificate
  sensitive = true
}

output "service_account" {
  description = "The default service account used for running nodes."
  value       = module.cluster.service_account
}

output "nat_router_name" {
  description = "Name of the NAT router that was created"
  value       = module.vpc.nat_router_name
}

output "bastion_ip_address" {
  description = "Bastion private IP address"
  value       = module.bastion.bastion_ip_address
}

# output "bastion_public_ip_address" {
#   description = "The public IP of the bastion node"
#   value       = module.bastion.bastion_public_ip_address
# }

output "ingress_loadbalancer_ip" {
  description = "load balancer ip"
  value       = module.ingress-nginx.load_balancer_ip
}
