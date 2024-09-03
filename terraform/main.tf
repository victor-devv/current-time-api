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
  region              = var.region
  network_name        = "${var.cluster_name}-vpc"
  subnet_name         = "${var.cluster_name}-vpc-subnet"
  subnet_cidr_block   = "172.16.1.0/24"
  nat_router_name     = "${var.cluster_name}-vpc-nat-router"
  nat_gateway_name    = "${var.cluster_name}-vpc-nat-gateway"
  pods_range_name     = "${var.cluster_name}-vpc-pod-range"
  pods_cidr_range     = "172.20.0.0/16"
  svc_range_name      = "${var.cluster_name}-vpc-svc-range"
  svc_cidr_range      = "172.21.0.0/20"

  depends_on = [ null_resource.prep ]
}


# IAM & SERVICE ACCOUNTS
# ================================================================================

module "iam" {
  source                  = "./modules/iam"

  project_id              = var.project_id
  cluster_name            = var.cluster_name
  grant_registry_access   = true
}

# BASTION NODE 
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
  service_account             = module.iam.cluster_service_account.0.email

  network_name                = module.vpc.network_name
  network_project_id          = var.network_project_id
  subnet_name                 = module.vpc.subnet_name
  subnet_self_link            = module.vpc.subnet_self_link
  pods_range_name             = "${var.cluster_name}-vpc-pod-range"
  svc_range_name              = "${var.cluster_name}-vpc-svc-range"

  release_channel             = var.release_channel

  enable_vertical_pod_autoscaling = true
  enable_private_endpoint         = false
  enable_private_nodes            = true
  
  master_ipv4_cidr_block          = "172.10.0.0/28"
  # master_authorized_networks  = [{
  #   cidr_block        = "${module.bastion.bastion_ip_address}/32"
  #   display_name      = "Bastion Node"
  # }]

  http_load_balancing         = false #NGINX ingress instead
  nodepool_machine_type       = "e2-custom-8-32768"

  depends_on = [ google_project_service.enabled_apis ]
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
  pods_range_name         = "${var.cluster_name}-vpc-pod-range"
  master_ipv4_cidr_block  = "172.10.0.0/28"
  tpu_ipv4_cidr_block     = module.cluster.tpu_ipv4_cidr_block
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

# KUBERNETES RESOURCES - DEPLOYMENT, SERVICE, PODS
# ================================================================================

module "app" {
  source              = "./modules/app/"

  app_name            = var.app_name
  image_repository    = var.image_repository
  image_tag           = var.image_tag
  app_env             = var.app_env
  replica_count       = var.replica_count  

  depends_on = [
    module.ingress-nginx,
    module.certmanager,
    module.cluster
  ]
}
