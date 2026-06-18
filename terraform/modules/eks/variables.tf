variable "cluster_role_arn" {
  type        = string
}

variable "node_group_role_arn" {
  type        = string
}

variable "private_subnet_ids" {
  type        = list(string)
}

variable "public_subnet_ids" {
  type        = list(string)
}

variable "environment" {
  type        = string
}

variable "github_actions_role_arn" {
  type        = string
}