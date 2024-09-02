locals {
  service_account_list = compact(
    concat(
      google_service_account.cluster_service_account.*.email,
      ["dummy"],
    ),
  )
  service_account_default_name = "gke-${substr(var.cluster_name, 0, min(15, length(var.cluster_name)))}-${random_string.cluster_service_account_suffix.result}"

  // if user set var.service_account it will be used even if var.create_service_account==true, so service account will be created but not used
  service_account = (var.service_account == "" || var.service_account == "create") && var.create_service_account ? local.service_account_list[0] : var.service_account

  registry_projects_list = length(var.registry_project_ids) == 0 ? [var.project_id] : var.registry_project_ids

  bastion_name = format("%s-bastion", var.cluster_name)
}
