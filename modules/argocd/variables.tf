variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
}

variable "release_name" {
  description = "Helm release name for ArgoCD"
  type        = string
}

variable "chart_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
}

variable "service_type" {
  description = "Service type for ArgoCD server (LoadBalancer, ClusterIP, NodePort)"
  type        = string
  default     = "LoadBalancer"
}

variable "values_file" {
  description = "Path to custom values.yaml file"
  type        = string
  default     = ""
}

variable "additional_set_values" {
  description = "List of extra Helm values to set"
  type        = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "root_domain_name" {
  description = "Root domain name (e.g. example.com)"
  type        = string
}

variable "route53_zone_id" {
  description = "AWS Route53 hosted zone ID"
  type        = string
}
