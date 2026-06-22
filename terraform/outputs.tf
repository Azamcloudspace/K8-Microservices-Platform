output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_frontend_url" {
  value = module.ecr.frontend_repo_url
}

output "ecr_api_url" {
  value = module.ecr.api_repo_url
}

output "ecr_worker_url" {
  value = module.ecr.worker_repo_url
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}

output "irsa_sqs_role_arn" {
  value = module.iam.irsa_sqs_role_arn
}

output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
}

output "lb_controller_role_arn" {
  value = module.iam.lb_controller_role_arn
}