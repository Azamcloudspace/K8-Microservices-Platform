variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "queue_arn" {
  description = "SQS queue ARN"
  type        = string
}

variable "oidc_provider" {
  description = "EKS OIDC provider URL"
  type        = string
}