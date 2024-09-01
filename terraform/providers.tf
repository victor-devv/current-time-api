terraform {
  required_version = ">=0.13"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.0.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "6.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.1"
    }
  }
  # provider_meta "google-beta" {
  #   module_name = "blueprints/terraform/terraform-google-kubernetes-engine:beta-autopilot-private-cluster/v27.0.0"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
