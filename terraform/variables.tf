// GENERAL VARIABLES
variable "project_id" {
  description = "The GCP project ID to host the cluster in"
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "europe-west2" #london, for reduced latency
  type        = string
}

variable "cluster_name" {
  description = "The name to be assigned to the GKE cluster"
  type        = string
}

variable "network_project_id" {
  description = "The GCP project ID to house the VPC network. (for shared vpc support)"
  type        = string
}


// VPC VARIABLES  
variable "network_name" {
  description = "The name to be assigned to the VPC network"
  type        = string
  default     = ""
}

variable "subnet_name" {
  description = "The name to be assigned to the VPC sub-network"
  type        = string
  default     = ""
}

variable "pods_range_name" {
  description = "The name to be assigned to the secondary subnet ip range to use for the pods"
  type        = string
}

variable "svc_range_name" {
  description = "The name to be assigned to the secondary subnet range to use for services"
  type        = string
}

variable "nat_router_name" {
  description = "The name to be assigned to the Cloud NAT router"
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

variable "release_channel" {
  type        = string
  description = "The release channel of this cluster, which provides more control over automatic upgrades of your cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR`, `STABLE` and `EXTENDED`. Defaults to `REGULAR`."
  default     = "UNSPECIFIED"
}

// KMS
# variable "keyring" {
#   description = "Keyring name."
#   type        = string
# }

# variable "keys" {
#   description = "Key names."
#   type        = list(string)
#   default     = []
# }
