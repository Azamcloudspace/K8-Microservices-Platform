resource "aws_eks_cluster" "main" {
  name     = "${var.environment}-eks-cluster"
  role_arn = var.cluster_role_arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.environment}-node-group"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t2.micro"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Environment = var.environment
  }
}