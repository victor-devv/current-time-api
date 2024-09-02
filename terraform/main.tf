// Enable the required service apis 
locals {
  apis = [
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
  for_each           = toset(local.apis)
  service            = each.value
  disable_on_destroy = false
  project            = var.project_id
}

resource "null_resource" "prep" {
  depends_on = [ google_project_service.enabled_apis ]
}

data "google_client_config" "current" {
}

# VPC
# ================================================================================

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

  depends_on = [ null_resource.prep ]
}

# FIREWALL
# ================================================================================

module "firewall" {
  source                  = "./modules/firewall"

  project_id              = var.project_id
  cluster_name            = var.cluster_name
  region                  = var.region
  network_name            = module.vpc.network_name
  subnet_name             = module.vpc.subnet_name
  network_project_id      = var.network_project_id
  pods_range_name         = var.pods_range_name
  master_ipv4_cidr_block  = "172.10.0.0/28"
}

# IAM & SERVICE ACCOUNTS
# ================================================================================

module "iam" {
  source                  = "./modules/iam"

  project_id              = var.project_id
  cluster_name            = var.cluster_name
  grant_registry_access   = true
}

# BASTION NODE - deploys a Bastion host which helps grant access to the private Control plane, limiting the possible attack surface area
# ================================================================================

module "bastion" {
  source              = "./modules/bastion"

  project_id          = var.project_id
  cluster_name        = var.cluster_name
  region              = var.region
  vpc_self_link       = module.vpc.vpc_self_link
  subnet_self_link    = module.vpc.subnet_self_link 
}

# GKE CLUSTER
# ================================================================================

module "cluster" {
  source                      = "./modules/cluster"

  project_id                  = var.project_id
  cluster_name                = var.cluster_name
  regional                    = true
  region                      = var.region

  network_name                = module.vpc.network_name
  network_project_id          = var.network_project_id
  subnet_name                 = module.vpc.subnet_name
  subnet_self_link            = module.vpc.subnet_self_link
  pods_range_name             = var.pods_range_name
  svc_range_name              = var.svc_range_name

  release_channel             = var.release_channel
  maintenance_start_time      = var.maintenance_start_time
  maintenance_end_time        = var.maintenance_end_time
  maintenance_recurrence      = var.maintenance_recurrence

  enable_vertical_pod_autoscaling = true
  enable_private_endpoint         = true
  enable_private_nodes            = true
  
  master_ipv4_cidr_block          = "172.10.0.0/28"
  master_authorized_networks  = [{
    cidr_block        = "${module.bastion.bastion_public_ip_address}/32"
    display_name      = "Bastion Node"
  }]

  http_load_balancing         = false #NGINX ingress instead

  depends_on = [ module.enabled_google_apis ]
}

# NGINX INGRESS CONTROLLER
# ================================================================================

module "ingress-nginx" {
  source = "./modules/ingress-nginx/"

  depends_on = [ 
    module.cluster
  ]
}

# CERT MANAGER (letsencrypt)
# ================================================================================

module "certmanager" {
  source = "./modules/cert-manager/"

  depends_on = [ 
    module.cluster
  ]
}

# simple nginx container with an ingress
# ================================================================================

module "shortlet_current_time_app" {
  source              = "./modules/app/"

  image_repository    = var.image_repository
  image_tag           = var.image_tag
  app_env             = var.app_env
  replica_count       = var.replica_count  

  depends_on = [
    module.ingress-nginx,
    module.certmanager
  ]
}
