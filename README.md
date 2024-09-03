# Current Time API

This repository contains a Node.js implementation of a simple API that returns the current time in JSON format. It also contains a terraform template that creates a private Autopilot GKE cluster, sets up the cluster and deploys api on the cluster.

## Repository Sturcture

```bash
.
|____.github
        |____workflows
                |____deploy.yaml                # CI/CD pipeline
|____api                                        # Node.js app
|____terraform                                  # Terraform template and modules
        |____config
                |____config.tfvars              # Configuration
        |____modules                            # Terraform modules
                |____app                        # Sets up kubernetes resources in cluster
                        |____helm               # Helm chart for the app
                                |____templates
                                        |____deployment.yaml
                                        |____ingress.yaml
                                        |____service.yaml
                                |____Chart.yaml
                                |____values.yaml        
                        |____main.tf
                        |____providers.tf
                        |____variables.tf
                |____bastion                    # Sets up bastion node
                        |____main.tf
                        |____data.tf
                        |____providers.tf
                        |____variables.tf
                        |____output.tf
                |____cluster                    # Creates Autopilot GKE cluster
                        |____main.tf
                        |____data.tf
                        |____providers.tf
                        |____variables.tf
                        |____output.tf
                |____firewall                   # Configures firewall
                        |____main.tf
                        |____data.tf
                        |____providers.tf
                        |____variables.tf
                        |____output.tf
                |____iam                        # Sets up service accounts and configures role bindings
                        |____main.tf
                        |____data.tf
                        |____providers.tf
                        |____variables.tf
                        |____output.tf
                |____vpc                        # Sets up network, subnet, NAT 
                        |____main.tf
                        |____data.tf
                        |____providers.tf
                        |____variables.tf
                        |____output.tf
        |____main.tf
        |____providers.tf
        |____backend.tf
        |____data.tf
        |____variables.tf
        |____outputs.tf
|____README.md

```


## How to use this automation

- 

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="app"></a> [app](#vpc) | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/app | main |
| <a name="vpc"></a> [vpc](#vpc) | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/vpc | main |
| <a name="iam"></a> [iam](#iam) | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/iam | main |
| <a name="bastion"></a> [bastion](#bastion) | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/bastion | main |
| <a name="cluster"></a> [cluster](#cluster) | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/cluster | main |
| <a name="firewall"></a> [firewall](#firewall) | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/firewall | main |
| <a name="cert-manager"></a> [cert-manager](#cert-manager) | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/cert-manager | main |
| <a name="ingress-nginx"></a> [ingress-nginx](#ingress-nginx) | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/ingress-nginx | main |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name to be assigned to the GKE cluster | `string` | n/a | yes |
| <a name="project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID to host the cluster in | `string` | n/a | yes |
| <a name="network_project_id"></a> [network\_project\_id](#input\_network\_project\_id) | The GCP project ID to house the VPC network. (for shared vpc support) | `string` | n/a | yes |
| <a name="region"></a> [region](#input\_region) | The region to host the cluster in | `string` | europe-west2 | no |
| <a name="release_channel"></a> [release\_channel](#input\_release\_channel) | The release channel of this cluster, which provides more control over automatic upgrades of your cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR`, `STABLE` and `EXTENDED` | `string` | UNSPECIFIED | no |
| <a name="image_repository"></a> [image\_repository](#input\_image\_repository) | GCR image repository for containing the application image | `string` | n/a | yes |
| <a name="image_tag"></a> [image\_tag](#input\_image\_tag) | Application image tag | `string` | n/a | yes |
| <a name="app_name"></a> [app\_name](#input\_app\_name) | Application deployment name | `string` | n/a | yes |
| <a name="app_env"></a> [app\_env](#input\_app\_env) | Application environment (production or staging) | `string` | n/a | yes |
| <a name="app_namespace"></a> [app\_namespace](#input\_app\_namespace) | The kubernetes namespace to deploy the application to | `string` | n/a | yes |
| <a name="replica_count"></a> [replica\_count](#input\_replica\_count) | The pod replica count for the deployment | `number` | 1 | no |
