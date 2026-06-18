output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_node_group_role_arn" {
  value = aws_iam_role.eks_node_group.arn
}

output "irsa_sqs_role_arn" {
  value = aws_iam_role.irsa_sqs.arn
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}