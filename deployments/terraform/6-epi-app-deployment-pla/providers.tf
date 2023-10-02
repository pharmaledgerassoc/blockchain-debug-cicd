# --- 6-epi-app-deployment-pla/providers.tf ---

terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
}
