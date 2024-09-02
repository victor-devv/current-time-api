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

variable "image_repository" {
  type        = string
  description = "GCR image repository for containing the application image"
}

variable "image_tag" {
  type        = string
  description = "Application image tag"
}

variable "app_name" {
  type        = string
  description = "The name for the application deployment"
}

variable "app_env" {
  type        = string
  description = "The application environment (production | staging)"
}

variable "replica_count" {
  type        = number
  description = "The pod replica count for the deployment"
  default = 1
}
