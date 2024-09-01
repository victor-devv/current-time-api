// GENERAL VARIABLES
variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "region" {
  description = "The region the cluster in"
  default     = "europe-west2" #london, for reduced latency
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster (required)"
  type        = string
  default     = "shortlet-athena-private"
}

variable "network_project_id" {
  description = "The GCP project housing the VPC network to host the cluster in"
  type        = string
}


// VPC VARIABLES  
variable "network_name" {
  description = "The VPC network to host the cluster in (required)"
  type        = string
  default     = ""
}
variable "subnet_name" {
  description = "The subnetwork to host the cluster in (required)"
  type        = string
  default     = ""
}

variable "pods_range_name" {
  description = "The name of the secondary subnet ip range to use for pods"
  type        = string
}

variable "svc_range_name" {
  description = "The name of the secondary subnet range to use for services"
  type        = string
}

variable "nat_router_name" {
  description = "Name for cloud NAT router"
  type        = string
}

variable "nat_gateway_name" {
  description = "Name for cloud NAT gateway"
  type        = string
}

// CLUSTER VARIABLES
variable "maintenance_start_time" {
  description = "Time window specified for daily or recurring maintenance operations in RFC3339 format"
  type        = string
  default     = "2024-12-08T00:00:00Z"
}

variable "maintenance_end_time" {
  description = "Time window specified for recurring maintenance operations in RFC3339 format"
  type        = string
  default     = "2024-12-08T05:00:00Z"
}

variable "maintenance_recurrence" {
  description = "Frequency of the recurring maintenance window in RFC5545 format"
  type        = string
  default     = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH"
}

// Variables for Bastion

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

// KMS
variable "keyring" {
  description = "Keyring name."
  type        = string
}

variable "keys" {
  description = "Key names."
  type        = list(string)
  default     = []
}
