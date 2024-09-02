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

variable "replica_count" {
  type        = number
  description = "The deployment replica count"
  default = 1
}
