//BASTION HOST DATA
data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin
  sudo apt-get install -y kubectl
  sudo apt-get install -y tinyproxy
  sudo apt-get install -yq git
  EOF
}

locals {
  bastion_name = format("%s-bastion", var.cluster_name)
  bastion_zone = format("%s-a", var.region)
}
