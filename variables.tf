variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1b"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "environment" {
  type    = string
  default = "terraform-project"
}
variable "route53_zone_id" {
  description = "The AWS Route53 Hosted Zone ID"
  type        = string
}

variable "root_domain_name" {
  description = "Your root domain name (e.g., nawaton.com)"
  type        = string
}

variable "git_username" {
  description = "Git username for ArgoCD private repository"
  type        = string
  sensitive   = true
}

variable "git_token" {
  description = "Git password or personal access token"
  type        = string
  sensitive   = true
}
# variable "cluster_oidc_issuer" {
#   type = string
# }
