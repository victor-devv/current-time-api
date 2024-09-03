variable "app_name" {
  type        = string
  description = "The name for the application deployment"
}

variable "image_repository" {
  type        = string
  description = "GCR image repository for containing the application image"
}

variable "image_tag" {
  type        = string
  description = "GCR image repository tag"
}

variable "app_env" {
  type        = string
  description = "The application environment"
}

variable "app_namespace" {
  type        = string
  description = "The kubernetes namespace to deploy the application to"
}

variable "replica_count" {
  type        = number
  description = "The deployment replica count"
  default = 1
}
