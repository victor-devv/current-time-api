variable "project_id" {
  type        = string
  description = "The project ID to host the cluster in (required)"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster (required)"
}

variable "region" {
  type        = string
  description = "The region in which to host the bastion node"
  default     = "europe-west2"
}

variable "vpc_self_link" {
  description = "The URI of the created VPC"
  type        = string
}

variable "subnet_self_link" {
  description = "The URI of the created subnet"
  type        = string
}

variable "bastion_image" {
  type        = string
  description = "The image from which to initialize this disk."
  default     = "debian-cloud"
}

variable "bastion_machine_type" {
  type        = string
  description = "The machine type to create"
  default     = "g1-small"
}

