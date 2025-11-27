resource "kubernetes_secret" "argocd_repo" {
  metadata {
    name      = var.repo_name
    namespace = var.argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"

  data = {
    name     = var.repo_name
    url      = var.repo_url
    username = var.repo_username
    password = var.repo_password
    type     = "git"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.destination_namespace
  }
}

resource "kubectl_manifest" "argocd_application" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.app_name
      namespace = var.argocd_namespace
    }
    spec = {
      project = var.project

      source = {
        repoURL        = var.repo_url
        targetRevision = var.target_revision
        path           = var.path
      }

      destination = {
        server    = var.destination_server
        namespace = var.destination_namespace
      }

      syncPolicy = var.automated_sync ? {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      } : null
    }
  })

  depends_on = [
    kubernetes_secret.argocd_repo
  ]
}
