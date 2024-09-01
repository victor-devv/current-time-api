resource "google_compute_instance" "bastion" {
  project      = var.project_id
  name         = local.bastion_name
  machine_type = var.bastion_machine_type
  zone         = "${var.region}-a"
  boot_disk {
    initialize_params {
      image = var.bastion_image
    }
  }
  network_interface {
    network    = var.vpc_self_link
    subnetwork = var.subnet_self_link
  }
  metadata_startup_script = data.template_file.startup_script.rendered
  tags         = ["bastion"]
}
