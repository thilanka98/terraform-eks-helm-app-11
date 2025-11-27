variable "argocd_namespace" {
  type = string
}

variable "app_name" {
  type = string
}

variable "project" {
  type    = string
  default = "default"
}

variable "repo_name" {
  type = string
}

variable "repo_url" {
  type = string
}

variable "repo_username" {
  type      = string
  sensitive = true
}

variable "repo_password" {
  type      = string
  sensitive = true
}

variable "path" {
  type = string
}

variable "target_revision" {
  type    = string
  default = "main"
}

variable "destination_namespace" {
  type = string
}

variable "destination_server" {
  type    = string
  default = "https://kubernetes.default.svc"
}

variable "automated_sync" {
  type    = bool
  default = true
}
