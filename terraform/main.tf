terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source       = "./modules/vpc"
  vpc_cidr     = var.vpc_cidr
  cluster_name = var.cluster_name
  environment  = var.environment
}

module "ecr" {
  source      = "./modules/ecr"
  environment = var.environment
}

module "sqs" {
  source      = "./modules/sqs"
  environment = var.environment
}

module "iam" {
  source        = "./modules/iam"
  cluster_name  = var.cluster_name
  aws_region    = var.aws_region
  account_id    = data.aws_caller_identity.current.account_id
  queue_arn     = module.sqs.queue_arn
  oidc_provider = module.eks.oidc_provider
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_group_role_arn = module.iam.eks_node_group_role_arn
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  environment         = var.environment
}