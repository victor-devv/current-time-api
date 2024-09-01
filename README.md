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
                |____iam                        # Sets up servicce accounts and configures role bindings
                        |____main.tf
                        |____data.tf
                        |____providers.tf
                        |____variables.tf
                        |____output.tf
                |____k8s                        # Sets up kubernetes resources in cluster
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


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name to be given to the GKE cluster | `string` | n/a | yes |

