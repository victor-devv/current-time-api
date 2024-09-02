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

variable "pods_range_name" {
  type        = string
  description = "The _name_ of the secondary subnet ip range to use for pods"
}

variable "svc_range_name" {
  type        = string
  description = "The _name_ of the secondary subnet range to use for services"
}

variable "subnet_cidr_block" {
  type        = string
  description = "The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet. This field only applies to private clusters, when enable_private_nodes is true"
  default     = "10.0.0.0/28"
}

variable "pods_cidr_range" {
  description = "The IP range in CIDR notation to use for the pods"
  type        = string
}

variable "svc_cidr_range" {
  description = "The IP range in CIDR notation to use for the services"
  type        = string
}
