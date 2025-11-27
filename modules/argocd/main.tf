resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argocd" {
  name       = var.release_name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = var.chart_version
  wait       = true

  # Server configuration
  set {
    name  = "server.service.type"
    value = var.service_type
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  # Additional dynamic values
  dynamic "set" {
    for_each = var.additional_set_values
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  # Use values file if provided
  values = var.values_file != "" ? [file(var.values_file)] : []

  depends_on = [
    kubernetes_namespace.argocd
  ]
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  depends_on = [helm_release.argocd]
}

# -----------------------------
resource "aws_route53_record" "argocd_dns" {
  zone_id = "Z3TADX5O06BGH6"  # Your hosted zone ID
  name    = "argocd.${var.root_domain_name}"  # e.g. argocd.example.com
  type    = "CNAME"
  ttl     = 300

  records = [
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname
  ]

  depends_on = [helm_release.argocd]
}

# -----------------------------
# Outputs
# -----------------------------
output "argocd_loadbalancer_hostname" {
  value       = data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname
  description = "The LoadBalancer hostname for ArgoCD server"
}

output "argocd_dns_name" {
  value       = aws_route53_record.argocd_dns.fqdn
  description = "The full domain name pointing to ArgoCD"
}

