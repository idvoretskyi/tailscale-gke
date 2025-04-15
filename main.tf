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

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  }
}

data "google_client_config" "default" {}

module "gke" {
  source                = "./modules/gke"
  project_id            = var.project_id
  region                = var.region
  zone                  = var.zone # Pass zone for zonal clusters (cost-effective)
  cluster_name          = var.cluster_name
  network               = var.network
  subnetwork            = var.subnetwork
  node_count            = var.node_count # Will be used if autoscaling is disabled
  min_node_count        = var.min_node_count
  max_node_count        = var.max_node_count
  machine_type          = var.machine_type
  use_preemptible_nodes = var.use_preemptible_nodes
  private_cluster       = var.private_cluster
  master_ipv4_cidr_block = var.master_ipv4_cidr_block
}

module "tailscale" {
  source     = "./modules/tailscale"
  auth_key   = var.tailscale_auth_key
  depends_on = [module.gke]
}