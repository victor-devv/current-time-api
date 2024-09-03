# Current Time API

This repository contains a comprehensive setup for deploying a Node.js implementation of a simple API that returns the current time in JSON format, alongside a robust cloud infrastructure consisting of a private Google Kubernetes Engine cluster and others, built using terraform. The deployed cluster is monitored by Google Cloud's Stackdriver Kubernetes Engine Monitoring & Logging, as well as Managed Prometheus services.

The application and infrastructure deployment is automated using a GitHub Actions workflow which includes jobs that builds and tests the Node.js application, lints the helm charts, builds and pushes the application image to a private Google Container Registry, deploys the infrastructure, and exposes the API.

## Dependencies
- Google Cloud Platform account
- Google Cloud Storage Bucket (to store terraform state files)
- Google Cloud SDK
- Google Cloud Workload Identity Provider setup for GitHub OIDC authentication in pipelines
- Terraform
- Docker
- Docker Compose
- Node.js
- Yarn
- GitHub

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
                |____cluster                    # Creates GKE cluster
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

- `/api`: This directory contains the Node.js API, which serves a simple endpoint that returns the current server time in JSON format.

 - `/terraform`: This directory contains all Terraform configurations and modules necessary to deploy the required cloud infrastructure. The setup includes a private Google Kubernetes Engine (GKE) cluster, a bastion node, and various supporting services.

## How To Set Up OpenID Connect For GitHub Actions

- Install Google Cloud SDK
- Initialize gcloud CLI and authenticate: `gcloud init`
- Create storage bucket: `gcloud projects add-iam-policy-binding $PROJECT_ID --member="$OWNER_SERVICE_ACCOUNT" --role=storage.buckets.create`
- Create OIDC service account: `gcloud iam service-accounts create $OIDC_SERVICEACCOUNT_NAME --project="$PROJECT_ID" --description="$DESCRIPTION" --display-name="$DISPLAY_NAME"`
- Apply required roles to OIDC service account: `gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:$OIDC_SERVICEACCOUNT_ID" --role="$ROLE"`
- Roles include: `roles/compute.admin, roles/container.admin, roles/storage.admin, roles/iam.serviceAccountAdmin, roles/iam.roleAdmin, roles/resourcemanager.projectIamAdmin, roles/iam.serviceAccountTokenCreator and roles/iam.serviceAccountUser`
- Create workload identity pools: `gcloud iam workload-identity-pools create $POOL_NAME --project="$PROJECT_ID" --location="global" --display-name="$DISPLAY_NAME" --description="$DESCRIPTION"`
- Create workload identity pool provider: `gcloud iam workload-identity-pools providers create-oidc $PROVIDER_NAME --project="$PROJECT_ID" --location="global" --workload-identity-pool="$POOL_NAME" --display-name="$DISPLAY_NAME" --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.aud=assertion.aud,attribute.repository=assertion.repository" --issuer-uri="https://token.actions.githubusercontent.com"`
- Authorize Github Repository: `gcloud iam service-accounts add-iam-policy-binding $OIDC_SA_ID --project="$PROJECT_ID" --role="roles/iam.workloadIdentityUser" --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${REPO}"`


# Terraform

## How To Use This Automation

- Create a new branch with the format `deploy/${cluster-name}` 
- Fill in the required values at `terraform/config/config.tfvars`
- Add the REGISTRY, PROJECT_ID as secrets
- Create a merge request to the main branch, and ask for approval
- After approval, the cluster will be deployed 

## How To Run This Automation Locally

- Clone this repository
- Authorize docker to access GCR `gcloud auth configure-docker gcr.io`
- Build and push the docker image at `api`
- Update the terraform backend file at `terraform/backend.tf` with your cloud storage bucket name   
- Fill in the required variable values at `terraform/config/config.tfvars`
- In your terminal, change directory to the terraform root `cd terraform`
- Initialize Terraform `terraform init`
- Generate a Terraform execution plan `terraform plan -var-file="config/config.tfvars" -out="tfplan"`
- Apply the terraform plan: `terraform apply tfplan`
- Once deployed, copy the generated `ingress_loadbalancer_ip` and test the deployment by running `curl --fail http://$INGRESS_LOADBALANCER_IP/time || exit 1`

## Modules

| Name | Description | Source | Version |
|------|--------|---------|---------|
| <a name="vpc"></a> [vpc](#vpc) | Deploys a network, subnet, a Cloud NAT router and Gateway for the cluster | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/vpc | main |
| <a name="iam"></a> [iam](#iam) | Creates service accounts for the bastion node and cluster, and assigns required roles using the `least privilege` principle | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/iam | main |
| <a name="bastion"></a> [bastion](#bastion) | Deploys a bastion node with access to the private cluster | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/bastion | main |
| <a name="cluster"></a> [cluster](#cluster) | Deploys a private cluster (with public endpoints, for the purpose of this demo), also enables monitoring, logging and maintenance on the cluster | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/cluster | main |
| <a name="firewall"></a> [firewall](#firewall) | Applies firewall rules for security | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/firewall | main |
| <a name="ingress-nginx"></a> [ingress-nginx](#ingress-nginx) | Deploys an NGINX loadbalancer on the cluster | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/ingress-nginx | main |
| <a name="cert-manager"></a> [cert-manager](#cert-manager) | Deploys cert-manager which helps to manage ssl certificates via letsencrypt | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/cert-manager | main |
| <a name="app"></a> [app](#app) | Deploys the target namespace, deployment service and ingress resources, for the containerized application on the cluster | https://github.com/victor-devv/current-time-api/tree/main/terraform/modules/app | main |


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


# API

## How To Run Locally

- Clone this repository `git clone https://github.com/victor-devv/current-time-api.git`
- Change directory `cd api`
- Install dependencies `yarn install`
- Compile the TypeScript files `yarn build:tsc`
- Fill the environment variables in `.env` referencing `.env.example`
- Run the application `yarn start:tsc`
- Trigger a GET command to `http://localhost:3000/api/v1/time` assuming the selected port is 3000

## How To Run Using Docker Compose

- Clone this repository `git clone https://github.com/victor-devv/current-time-api.git`
- Change directory `cd api`
- Build and run the application `docker-compose up--build`
- Trigger a GET command to `http://localhost:3000/api/v1/time`
