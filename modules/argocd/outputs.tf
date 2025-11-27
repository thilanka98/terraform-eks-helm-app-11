output "namespace" {
  description = "ArgoCD namespace"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "release_name" {
  description = "Helm release name"
  value       = helm_release.argocd.name
}

output "release_status" {
  description = "Status of the Helm release"
  value       = helm_release.argocd.status
}

output "chart_version" {
  description = "Chart version deployed"
  value       = helm_release.argocd.version
}
