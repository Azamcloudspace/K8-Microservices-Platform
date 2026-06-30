# K8s-Microservices-Platform
 
## Project Summary
 
Migrated a production microservices workload from AWS ECS Fargate to Amazon EKS, replacing AWS-native tooling with cloud-agnostic, industry-standard alternatives. Same application architecture, same SQS-based design — rebuilt on Kubernetes, Terraform, and GitHub Actions.
 
---
 
## Key Outcomes
 
- Migrated containerized microservices from ECS Fargate to Amazon EKS
- Replaced CloudFormation with modular Terraform
- Replaced CodePipeline/CodeBuild with GitHub Actions
- Implemented IRSA for keyless AWS authentication from pods
- Deployed AWS Load Balancer Controller to manage ALB provisioning from Kubernetes
- Multi-environment promotion strategy (dev → staging → prod) with manual approval gates
---
 
## Architecture
 
Three loosely coupled services communicating via Amazon SQS:
 
- **Frontend** — Nginx serving static UI, proxying `/api/*` requests to the API internally
- **API** — Python Flask exposing `/api/health` and `/api/job` endpoints
- **Worker** — Background processor polling SQS and executing jobs asynchronously
```
Internet → ALB (public subnet)
    → /api/* → API Service → Flask pod
    → /*     → Frontend Service → Nginx pod
                                      ↓
                              Nginx reverse proxy → API Service (internal)
 
Worker pod → SQS (outbound only, no Service needed)
```
 
---
 
## Infrastructure — Terraform
 
Modular Terraform replacing CloudFormation nested stacks.
 
```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── envs/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── modules/
    ├── vpc/       # VPC, subnets, IGW, NAT Gateways
    ├── eks/       # EKS cluster, node group, access entries
    ├── ecr/       # ECR repositories (frontend, api, worker)
    ├── sqs/       # SQS job queue
    └── iam/       # All IAM roles — cluster, node group, IRSA, GitHub Actions, LB Controller
```
 
Each environment has its own Terraform workspace and `.tfvars` file — isolated state stored in S3.
 
---
 
## Kubernetes Manifests
 
```
k8/
├── serviceaccount.yaml               # IRSA identity for app pods → SQS role
├── lb-controller-serviceaccount.yaml # IRSA identity for LB Controller → ALB role
├── frontend-deployment.yaml          # Deployment + ClusterIP Service
├── api-deployment.yaml               # Deployment + ClusterIP Service
├── worker-deployment.yaml            # Deployment only
└── ingress.yaml                      # ALB routing rules
```
 
### ECS → Kubernetes Mapping
 
| ECS | Kubernetes |
|---|---|
| Task Definition | Pod spec |
| ECS Service (desired count) | Deployment |
| ECS Service (load balancing) | ClusterIP Service |
| Task Role | ServiceAccount + IRSA |
| ALB + Target Groups | Ingress + AWS Load Balancer Controller |
| Cloud Map | Kubernetes DNS |
 
---
 
## CI/CD — GitHub Actions
 
Two workflows replacing CodePipeline + CodeBuild:
 
**`terraform.yml`** — Manual trigger. Choose action (`plan`, `apply`, `destroy`) and environment (`dev`, `staging`, `prod`) from a dropdown. Runs Terraform against the selected workspace and `.tfvars` file.
 
**`deploy.yml`** — Triggers automatically on push to `dev`, `staging`, or `main` branches.

 
##  Deployment Lifecycle (To be done for all environments i.e prod, staging, and main)

### Step 1 — Terraform Init

Initialize the project and configure the S3 backend:

![Terraform Init]()

### Step 2 — Terraform Plan

Review what will be created before applying:

![Terraform Plan]()

### Step 3 — Terraform Apply

Provision the full infrastructure — VPC, EKS cluster, node group, ECR repos, SQS queue, IAM roles, This 

![Terraform Apply Complete]()

### Step 4 - Add Secrets to GitHub
Add Github Actions workflow secrets to Github from Terraform outputs

![Secrets]()

### Step 5 - Add , Commit and Push to Git 

Triggers the deploy workflow to build the images, push images to ECR, Deploy Kubernetes Manifests to EKS , Installs Helm and Load Balancer Controller to route traffic to pods

![Terraform Apply Complete]()

```
Code pushed
    → OIDC authentication to AWS (no stored keys)
        → Docker build → tag with git commit SHA
            → Push to ECR
                → kubectl apply manifests
                  → kubectl rollout status
                    → Install Helm
                      → Install AWS LoadBAlancer Controller
                      
        
```
 
![CICD]()

Images are tagged with the git commit SHA for full traceability. A `sed` command substitutes the `IMAGE_TAG` placeholder in manifests before `kubectl apply` runs — no `latest` tag required.
 
Multi-environment promotion uses GitHub Environment protection rules — deployments pause for manual approval.
 
---
 
## Security
 
- No hardcoded credentials anywhere
- Pods authenticate to AWS via IRSA (OIDC token → IAM role)
- GitHub Actions authenticates via OIDC (no stored AWS keys)
- Worker nodes and pods in private subnets — ALB is the only public entry point
- Environment-scoped GitHub Secrets per environment
---
 
## Evolution from ECS Project
 
Direct migration of [ECS-Microservices-CICD-Platform](https://github.com/Azamcloudspace/ECS-Microservices-CICD-Platform).
 
| | ECS Project | This Project |
|---|---|---|
| Orchestration | ECS Fargate | Kubernetes (EKS) |
| IaC | CloudFormation | Terraform |
| CI/CD | CodePipeline + CodeBuild | GitHub Actions |
| Pod Identity | Task Role | IRSA |
| Load Balancing | ALB (CloudFormation) | ALB (Ingress + LB Controller) |
| Secrets | SSM Parameter Store | GitHub Secrets + K8s Secrets |
 
---
 
## Repository Structure
 
```
├── app/
│   ├── api/
│   ├── frontend/
│   └── worker/
├── k8/
├── terraform/
└── .github/workflows/
```