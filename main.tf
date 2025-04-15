terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

# Use a local variable to determine if we should try to connect to the cluster
locals {
  cluster_exists = try(module.gke.endpoint != "", false)
}

# Kubernetes provider with ignore_errors to help with destroy operations
provider "kubernetes" {
  host                   = local.cluster_exists ? "https://${module.gke.endpoint}" : "https://localhost"
  token                  = local.cluster_exists ? data.google_client_config.default.access_token : ""
  cluster_ca_certificate = local.cluster_exists ? base64decode(module.gke.ca_certificate) : ""

  # This will ignore API errors when destroying resources that might not exist anymore
  ignore_annotations = [".*"]
  ignore_labels = [".*"]
}

provider "helm" {
  kubernetes {
    host                   = local.cluster_exists ? "https://${module.gke.endpoint}" : "https://localhost"
    token                  = local.cluster_exists ? data.google_client_config.default.access_token : ""
    cluster_ca_certificate = local.cluster_exists ? base64decode(module.gke.ca_certificate) : ""
  }
}

module "gke" {
  source                = "./modules/gke"
  project_id            = var.project_id
  region                = var.region
  zone                  = var.zone
  cluster_name          = var.cluster_name
  network               = var.network
  subnetwork            = var.subnetwork
  node_count            = var.node_count
  min_node_count        = var.min_node_count
  max_node_count        = var.max_node_count
  machine_type          = var.machine_type
  use_preemptible_nodes = var.use_preemptible_nodes
  private_cluster       = var.private_cluster
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
}

# Make Tailscale module resources optional for easier destruction
module "tailscale" {
  source     = "./modules/tailscale"
  auth_key   = var.tailscale_auth_key
  depends_on = [module.gke]
}