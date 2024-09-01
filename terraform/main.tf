// Enable the required service apis 
locals {
  enabled_apis = [
    "compute.googleapis.com",
    "cloudapis.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "iap.googleapis.com",
    "oslogin.googleapis.com",
    "cloudkms.googleapis.com",
    "container.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "gkehub.googleapis.com"
  ]
}

resource "google_project_service" "enabled_apis" {
  for_each           = toset(local.enabled_apis)
  service            = each.value
  disable_on_destroy = false
  project            = var.project_id
}

resource "null_resource" "prep" {
  depends_on = [google_project_service.enabled_apis]
}

//VPC MODULE: must depend on [null_resource.prep] resource
module "vpc" {
  source              = "./modules/vpc"

  project_id          = var.project_id
  cluster_name        = var.cluster_name
  network_name        = var.network_name
  subnet_name         = var.subnet_name
  region              = var.region
  nat_router_name     = var.nat_router_name
  nat_gateway_name    = var.nat_gateway_name
  pods_range_name     = var.pods_range_name
  svc_range_name      = var.svc_range_name
}

//IAM MODULE: must depend on [null_resource.pre]

//CLUSTER MODULE: must deoend on [module.iam]

//BASTION MODULE - deploys a Bastion host which helps grant access to the private Control plane, limiting the possible attack surface area

//FIREWALL MODULE