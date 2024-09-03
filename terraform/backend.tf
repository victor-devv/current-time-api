terraform {
  backend "gcs" {
    bucket  = "current-time-api-terraform-remote-backend"
    prefix  = "tfstate"
  }
}
