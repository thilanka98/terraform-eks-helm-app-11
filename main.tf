terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
  environment     = var.environment
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = "${var.environment}-eks-cluster"
  cluster_version    = "1.33"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets
  environment        = var.environment
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}


provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

resource "time_sleep" "wait_for_eks" {
  depends_on = [module.eks]
  create_duration = "60s"
}


module "argocd" {
  source = "./modules/argocd"

  namespace        = "argocd"
  release_name     = "argocd"
  chart_version    = "5.46.7"
  service_type     = "LoadBalancer"
  root_domain_name = "nawatan.com"

  route53_zone_id = "Z3TADX5O06BGH6"   # ✅ important

  values_file = ""

  additional_set_values = [
    {
      name  = "server.ingress.enabled"
      value = "true"
    }
  ]
}


module "argocd_app_backend" {
  source = "./modules/argocd_app"

  providers = {
    kubectl   = kubectl
    kubernetes = kubernetes
  }

  argocd_namespace      = "argocd"
  app_name              = "nginx"
  project               = "default"
  repo_name             = "nginx-repo"
  repo_url              = "https://gitlab.com/incubatelabs/dev-ops/terraform-test-app.git"
  repo_username         = var.git_username
  repo_password         = var.git_token
  path                  = "./"
  target_revision       = "main"
  destination_namespace = "nginx"
  automated_sync        = true

  depends_on = [module.argocd]
}

module "ebs_csi" {
  source = "./modules/ebs-csi"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn
  region            = var.region
  environment       = var.environment

  depends_on = [
    aws_iam_openid_connect_provider.eks
  ]
}



