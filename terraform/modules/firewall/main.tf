/******************************************
  Match the gke-<CLUSTER>-<ID>-all INGRESS
  firewall rule created by GKE but for EGRESS

  Required for clusters when VPCs enforce
  a default-deny egress rule
 *****************************************/
resource "google_compute_firewall" "intra_egress" {
  count       = var.add_cluster_firewall_rules ? 1 : 0
  name        = "gke-${substr(var.cluster_name, 0, min(36, length(var.cluster_name)))}-intra-cluster-egress"
  description = "Managed by terraform: Allow pods to communicate with each other and the master"
  project     = local.network_project_id
  network     = var.network_name
  priority    = var.firewall_priority
  direction   = "EGRESS"

  target_tags = [local.cluster_network_tag]
  destination_ranges = concat([
    local.cluster_endpoint_for_nodes,
    local.cluster_subnet_cidr,
    ],
    local.pod_all_ip_ranges
  )

  # Allow all possible protocols
  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
  allow { protocol = "sctp" }
  allow { protocol = "esp" }
  allow { protocol = "ah" }

}


/******************************************
  Allow egress to the TPU IPv4 CIDR block

  This rule is defined separately from the
  intra_egress rule above since it requires
  an output from the google_container_cluster
  resource.
 *****************************************/
resource "google_compute_firewall" "tpu_egress" {
  count       = var.add_cluster_firewall_rules && var.enable_tpu ? 1 : 0
  name        = "gke-${substr(var.cluster_name, 0, min(36, length(var.cluster_name)))}-tpu-egress"
  description = "Managed by terraform: Allow pods to communicate with TPUs"
  project     = local.network_project_id
  network     = var.network_name
  priority    = var.firewall_priority
  direction   = "EGRESS"

  target_tags        = [local.cluster_network_tag]
  destination_ranges = [google_container_cluster.primary.tpu_ipv4_cidr_block]

  # Allow all possible protocols
  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
  allow { protocol = "sctp" }
  allow { protocol = "esp" }
  allow { protocol = "ah" }
}


/******************************************
  Allow GKE master to hit non 443 ports for
  Webhooks/Admission Controllers
 *****************************************/
resource "google_compute_firewall" "master_webhooks" {
  count       = var.add_cluster_firewall_rules || var.add_master_webhook_firewall_rules ? 1 : 0
  name        = "gke-${substr(var.cluster_name, 0, min(36, length(var.cluster_name)))}-webhooks"
  description = "Managed by terraform: Allow master to hit pods for admission controllers/webhooks"
  project     = local.network_project_id
  network     = var.network_name
  priority    = var.firewall_priority
  direction   = "INGRESS"

  source_ranges = [local.cluster_endpoint_for_nodes]
  source_tags   = []
  target_tags   = [local.cluster_network_tag]

  allow {
    protocol = "tcp"
    ports    = var.firewall_inbound_ports
  }
}


/******************************************
  Create shadow firewall rules to capture the
  traffic flow between the managed firewall rules
 *****************************************/
resource "google_compute_firewall" "shadow_allow_pods" {
  count = var.add_shadow_firewall_rules ? 1 : 0

  name        = "gke-shadow-${substr(var.cluster_name, 0, min(36, length(var.cluster_name)))}-all"
  description = "Managed by terraform: A shadow firewall rule to match the default rule allowing pod communication."
  project     = local.network_project_id
  network     = var.network_name
  priority    = var.shadow_firewall_rules_priority
  direction   = "INGRESS"

  source_ranges = local.pod_all_ip_ranges
  target_tags   = [local.cluster_network_tag]

  # Allow all possible protocols
  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
  allow { protocol = "sctp" }
  allow { protocol = "esp" }
  allow { protocol = "ah" }

  dynamic "log_config" {
    for_each = var.shadow_firewall_rules_log_config == null ? [] : [var.shadow_firewall_rules_log_config]
    content {
      metadata = log_config.value.metadata
    }
  }
}

resource "google_compute_firewall" "shadow_allow_master" {
  count = var.add_shadow_firewall_rules ? 1 : 0

  name        = "gke-shadow-${substr(var.cluster_name, 0, min(36, length(var.cluster_name)))}-master"
  description = "Managed by terraform: A shadow firewall rule to match the default rule allowing worker nodes communication."
  project     = local.network_project_id
  network     = var.network_name
  priority    = var.shadow_firewall_rules_priority
  direction   = "INGRESS"

  source_ranges = [local.cluster_endpoint_for_nodes]
  target_tags   = [local.cluster_network_tag]

  allow {
    protocol = "tcp"
    ports    = ["10250", "443"]
  }

  dynamic "log_config" {
    for_each = var.shadow_firewall_rules_log_config == null ? [] : [var.shadow_firewall_rules_log_config]
    content {
      metadata = log_config.value.metadata
    }
  }
}

resource "google_compute_firewall" "shadow_allow_nodes" {
  count = var.add_shadow_firewall_rules ? 1 : 0

  name        = "gke-shadow-${substr(var.cluster_name, 0, min(36, length(var.cluster_name)))}-vms"
  description = "Managed by terraform: A shadow firewall rule to match the default rule allowing worker nodes communication."
  project     = local.network_project_id
  network     = var.network_name
  priority    = var.shadow_firewall_rules_priority
  direction   = "INGRESS"

  source_ranges = [local.cluster_subnet_cidr]
  target_tags   = [local.cluster_network_tag]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  dynamic "log_config" {
    for_each = var.shadow_firewall_rules_log_config == null ? [] : [var.shadow_firewall_rules_log_config]
    content {
      metadata = log_config.value.metadata
    }
  }
}

resource "google_compute_firewall" "shadow_allow_inkubelet" {
  count = var.add_shadow_firewall_rules ? 1 : 0

  name        = "gke-shadow-${substr(var.cluster_name, 0, min(36, length(var.cluster_name)))}-inkubelet"
  description = "Managed by terraform: A shadow firewall rule to match the default rule allowing worker nodes & pods communication to kubelet."
  project     = local.network_project_id
  network     = var.network_name
  priority    = var.shadow_firewall_rules_priority - 1 # rule created by GKE robot have prio 999
  direction   = "INGRESS"

  source_ranges = local.pod_all_ip_ranges
  source_tags   = [local.cluster_network_tag]
  target_tags   = [local.cluster_network_tag]

  allow {
    protocol = "tcp"
    ports    = ["10255"]
  }

  dynamic "log_config" {
    for_each = var.shadow_firewall_rules_log_config == null ? [] : [var.shadow_firewall_rules_log_config]
    content {
      metadata = log_config.value.metadata
    }
  }
}

resource "google_compute_firewall" "shadow_deny_exkubelet" {
  count = var.add_shadow_firewall_rules ? 1 : 0

  name        = "gke-shadow-${substr(var.cluster_name, 0, min(36, length(var.cluster_name)))}-exkubelet"
  description = "Managed by terraform: A shadow firewall rule to match the default deny rule to kubelet."
  project     = local.network_project_id
  network     = var.network_name
  priority    = var.shadow_firewall_rules_priority # rule created by GKE robot have prio 1000
  direction   = "INGRESS"

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.cluster_network_tag]

  deny {
    protocol = "tcp"
    ports    = ["10255"]
  }

  dynamic "log_config" {
    for_each = var.shadow_firewall_rules_log_config == null ? [] : [var.shadow_firewall_rules_log_config]
    content {
      metadata = log_config.value.metadata
    }
  }
}

# Firewall rules for Bastion Node

resource "google_compute_firewall" "allow_ssh_bastion" {
  name    = "allow-ssh-bastion"
  project = local.network_project_id
  description = "Managed by terraform: A firewall rule to allow ssh traffic to the bastion node."

  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["bastion"]
}

resource "google_compute_firewall" "allow_http_https_rdp" {
  name    = "allow-http-https-rdp"
  project = local.network_project_id
  description = "Managed by terraform: A firewall rule to allow http and https traffic"
  network = var.network_name
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "3389"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["allow-http-https-rdp"]
}
