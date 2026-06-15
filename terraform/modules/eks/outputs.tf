output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "oidc_provider" {
  value = trimprefix(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://")
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}