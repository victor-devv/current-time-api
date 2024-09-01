variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster (required)"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_name" {
  type        = string
  description = "The subnetwork to host the cluster in (required)"
}

variable "cidr_block" {
  description = "CIDR block for the subnetwork"
  type        = string
}

variable "regional" {
  type        = bool
  description = "Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)"
  default     = true
}

variable "region" {
  description = "Region for the VPC and subnetwork"
  type        = string
}

variable "network_project_id" {
  type        = string
  description = "The project ID of the shared VPC's host (for shared vpc support)"
  default     = ""
}

variable "nat_router_name" {
  description = "Name for cloud NAT router"
  type        = string
}

variable "nat_gateway_name" {
  description = "Name for cloud NAT gateway"
  type        = string
}

variable "ip_range_pods" {
  type        = string
  description = "The _name_ of the secondary subnet ip range to use for pods"
}

variable "ip_range_services" {
  type        = string
  description = "The _name_ of the secondary subnet range to use for services"
}

variable "service_account_roles" {
  type = list(string)

  description = "List of IAM roles to assign to the service account."
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/compute.osLogin",
  ]
}

variable "bastion_members" {
  type = list(string)

  description = "List of users, groups, SAs who need access to the bastion host"
  default     = []
}

